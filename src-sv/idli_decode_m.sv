`include "idli_pkg.svh"

// Instruction decoder. Operates on 4b of instruction at a time to generate
// the final control structure for execution.
module idli_decode_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic        i_dcd_gck,
  input  var logic        i_dcd_rst_n,

  // Encodings read from memory and their validity.
  input  var logic [3:0]  i_dcd_enc,
  input  var logic        i_dcd_enc_vld
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

endmodule
