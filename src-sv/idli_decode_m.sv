`include "idli_pkg.svh"

// Instruction decoder. Operates on 4b of instruction at a time to generate
// the final control structure for execution.
module idli_decode_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic        i_dcd_gck,
  input  var logic        i_dcd_rst_n,

  // Encodings read from memory and their validity.
  input  var logic [3:0]  i_dcd_enc,
  input  var logic        i_dcd_enc_vld,

  // Decoded instruction.
  output var instr_t      o_dcd_instr
);

  // Decoding takes place 4b as a time as we fetch a 16b instruction over four
  // cycles from the SQI memory. As such we maintain a state machine to decode
  // the instruction over these four cycles, then present the final control
  // structure to the backend.
  typedef enum logic [3:0] {
    STATE_START,

    STATE_ADCS_SBBS,
    STATE_CMP_PUTP_OUT,
    STATE_ALU_SHIFT_IN_MEM,
    STATE_MEM,

    STATE_ABC,
    STATE_EQ_LT,
    STATE_GE_MASK,
    STATE_PUTP_OUT,
    STATE_SHIFT_IN,
    STATE_MEMWB,

    STATE_BC,
    STATE_C,
    STATE_SHIFT_IN_FINAL,
    STATE_MEMWB_FINAL
  } state_t;


  // Current and next state for the decoder.
  state_t state_q;
  state_t state_d;

  // State of the decoded instruction.
  instr_t instr_q;
  instr_t instr_d;

  // Whether to write registers. If the register is read over two cycles we
  // have two bits to keep write enables simple. We don't need to do any
  // decoding of the actual value to flop as this can be sliced directly from
  // the input bits.
  logic       op_p_wr_en;
  logic       op_q_wr_en;
  logic [1:0] op_a_wr_en;
  logic [1:0] op_b_wr_en;
  logic       op_c_wr_en;

  // ALU control signals and their write enables.
  alu_op_t  alu_op;
  logic     alu_op_wr_en;

  // Write enables decoded from the instruction for operands and whether they
  // are valid this cycle for decode.
  logic op_a_wr_en_;
  logic op_a_wr_en_wr_en;


  // Reset the state to START or flop the next state.
  always_ff @(posedge i_dcd_gck, negedge i_dcd_rst_n) begin
    if (!i_dcd_rst_n) begin
      state_q <= STATE_START;
    end else begin
      state_q <= state_d;
    end
  end

  // Determine which state to move into on the next cycle.
  always_comb begin
    state_d = state_q;

    case (state_q)
      STATE_START: begin
        // Only move out of the start state if the encoding is valid - this
        // should then stay valid for the next 3 cycles so we don't need to
        // check again.
        if (i_dcd_enc_vld) begin
          // Top 2b of the first cycle is always the execution predicate. The
          // next two bits are used to determine the next state to move into.
          case (i_dcd_enc[1:0])
            2'b00:   state_d = STATE_ADCS_SBBS;
            2'b01:   state_d = STATE_CMP_PUTP_OUT;
            2'b10:   state_d = STATE_ALU_SHIFT_IN_MEM;
            default: state_d = STATE_MEM;
          endcase
        end
      end
      STATE_ADCS_SBBS, STATE_MEM: begin
        // ADCS/SBBS and non-writeback memory operations all take the standard
        // set of A/B/C operands.
        state_d = STATE_ABC;
      end
      STATE_CMP_PUTP_OUT: begin
        // On this cycle we can determine the correct instruction group and
        // diverge into the appropriate state.
        case ({i_dcd_enc[3], i_dcd_enc[0]})
          2'b00:   state_d = STATE_EQ_LT;
          2'b01:   state_d = STATE_GE_MASK;
          default: state_d = STATE_PUTP_OUT;
        endcase
      end
      STATE_ALU_SHIFT_IN_MEM: begin
        // SHIFT/IN/MEM need further specialised decoding while ALU ops can
        // now take the standard A/B/C route.
        case (i_dcd_enc[3:1])
          3'b110:  state_d = STATE_SHIFT_IN;
          3'b111:  state_d = STATE_MEMWB;
          default: state_d = STATE_ABC;
        endcase
      end
      STATE_ABC, STATE_EQ_LT, STATE_GE_MASK: begin
        // Continue on to the last part of B and full value of C.
        state_d = STATE_BC;
      end
      STATE_PUTP_OUT: begin
        // We don't have any further decoding to do and just need to read C.
        state_d = STATE_C;
      end
      STATE_SHIFT_IN: begin
        // We only know the final operation type on the final cycle as it's
        // encoded in the space normally occupied by C.
        state_d = STATE_SHIFT_IN_FINAL;
      end
      STATE_MEMWB: begin
        // The width and writeback type is only known on the final cycle.
        state_d = STATE_MEMWB_FINAL;
      end
      default: begin
        // All states on the final cycle return to START.
        state_d = STATE_START;
      end
    endcase
  end

  // Update the decoded instruction state.
  always_comb begin
    instr_d = instr_q;

    if (op_p_wr_en) begin
      instr_d.op_p = preg_t'(i_dcd_enc[3:2]);
    end

    if (op_q_wr_en) begin
      instr_d.op_q = preg_t'(i_dcd_enc[2:1]);
    end

    if (op_a_wr_en[0]) begin
      instr_d.op_a[1:0] = i_dcd_enc[3:2];
    end

    if (op_a_wr_en[1]) begin
      instr_d.op_a[2] = i_dcd_enc[0];
    end

    if (op_b_wr_en[0]) begin
      instr_d.op_b[0] = i_dcd_enc[3];
    end

    if (op_b_wr_en[1]) begin
      instr_d.op_b[2:1] = i_dcd_enc[1:0];
    end

    if (op_c_wr_en) begin
      instr_d.op_c = greg_t'(i_dcd_enc[2:0]);
    end

    if (alu_op_wr_en) begin
      instr_d.alu_op = alu_op;
    end

    if (op_a_wr_en_wr_en) begin
      instr_d.op_a_wr_en = op_a_wr_en_;
    end
  end

  // Flop the instruction.
  always_ff @(posedge i_dcd_gck) begin
    instr_q <= instr_d;
  end

  // P is always written on the first cycle of decode. Save a little power by
  // only flopping when the input is actually valid. We don't need to do this
  // power optimisation on the other operands as we won't move out of START
  // unless the input is valid.
  always_comb op_p_wr_en = (state_q == STATE_START) & i_dcd_enc_vld;

  // Q is written on the second cycle of decode for operations with carry or
  // those that write predicate registers. We write Q for OUT even though it
  // isn't used as we can't know whether the instruction is PUTP or OUT until
  // the next cycle.
  always_comb begin
    case (state_q)
      STATE_ADCS_SBBS,
      STATE_CMP_PUTP_OUT: op_q_wr_en = '1;
      default:            op_q_wr_en = '0;
    endcase
  end

  // The top bit of A is written on the second cycle when in use.
  always_comb begin
    case (state_q)
      STATE_ADCS_SBBS,
      STATE_MEM,
      STATE_ALU_SHIFT_IN_MEM: op_a_wr_en[1] = '1;
      default:                op_a_wr_en[1] = '0;
    endcase
  end

  // A's bottom two bits are written on the third cycle.
  always_comb begin
    case (state_q)
      STATE_ABC,
      STATE_MEMWB,
      STATE_SHIFT_IN: op_a_wr_en[0] = '1;
      default:        op_a_wr_en[0] = '0;
    endcase
  end

  // Top 2b of B is written on the third cycle. As with Q and OUT, we have to
  // write the top bits even for IN as we don't know if we're an IN or a shift
  // at this point.
  always_comb begin
    case (state_q)
      STATE_ABC,
      STATE_EQ_LT,
      STATE_GE_MASK,
      STATE_MEMWB,
      STATE_SHIFT_IN: op_b_wr_en[1] = '1;
      default:        op_b_wr_en[1] = '0;
    endcase
  end

  // Final bit of B is written on the fourth and final cycle if present.
  always_comb begin
    case (state_q)
      STATE_BC,
      STATE_MEMWB_FINAL,
      STATE_SHIFT_IN_FINAL: op_b_wr_en[0] = '1;
      default:              op_b_wr_en[0] = '0;
    endcase
  end

  // The complete value of C is written on the final cycle.
  always_comb begin
    case (state_q)
      STATE_C,
      STATE_BC: op_c_wr_en = '1;
      default:  op_c_wr_en = '0;
    endcase
  end

  // Output the decoded instruction. We output the _d instead of the _q so
  // that signals decoded on the final cycle can immediately be flopped by the
  // execution unit.
  always_comb o_dcd_instr = instr_d;

  // Decode ALU operation and the write enable.
  always_comb begin
    case (state_q)
      STATE_ADCS_SBBS: begin
        // ADCS and SBBS both use ADD - we invert for SUB.
        alu_op       = ALU_OP_ADD;
        alu_op_wr_en = '1;
      end
      STATE_ALU_SHIFT_IN_MEM: begin
        // ALU ops are decoded. Shifts and IN don't need to use the ALU so
        // these are don't care. Memory ops always perform an ADD.
        case (i_dcd_enc[3:1])
          3'b110:  alu_op_wr_en = '0;
          default: alu_op_wr_en = '1;
        endcase

        casez (i_dcd_enc[3:1])
          3'b01?:  alu_op = ALU_OP_AND;
          3'b100:  alu_op = ALU_OP_OR;
          3'b101:  alu_op = ALU_OP_XOR;
          default: alu_op = ALU_OP_ADD;
        endcase
      end
      default: begin
        // Everything else is a don't care.
        alu_op       = alu_op_t'('x);
        alu_op_wr_en = '0;
      end
    endcase
  end

  // A should be written by all instructions that have the operand with the
  // exception of stores in which they are sources.
  always_comb begin
    case (state_q)
      STATE_ADCS_SBBS,
      STATE_ALU_SHIFT_IN_MEM: begin
        // All operations here write the A register except for stores with
        // writeback, but we'll overwrite the signal we decide here in the
        // final cycle for these anyway.
        op_a_wr_en_      = '1;
        op_a_wr_en_wr_en = '1;
      end
      STATE_CMP_PUTP_OUT: begin
        // These operations never write A.
        op_a_wr_en_      = '0;
        op_a_wr_en_wr_en = '1;
      end
      STATE_MEM: begin
        // Only loads write A for non-writeback memory operations.
        op_a_wr_en_      = ~i_dcd_enc[2];
        op_a_wr_en_wr_en = '1;
      end
      STATE_MEMWB_FINAL: begin
        // For writeback operations we don't know if it's a load or store
        // until the final cycle.
        op_a_wr_en_      = ~i_dcd_enc[1];
        op_a_wr_en_wr_en = '1;
      end
      default: begin
        op_a_wr_en_      = '0;
        op_a_wr_en_wr_en = '0;
      end
    endcase
  end

endmodule
