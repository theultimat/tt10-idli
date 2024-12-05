`include "idli_pkg.svh"

// 4b serial ALU.
module idli_alu_m import idli_pkg::*; (
  // Clock - no reset.
  input  var logic        i_alu_gck,

  // Control signals.
  input  var logic        i_alu_ctr_last_cycle,
  input  var alu_op_t     i_alu_op,

  // Operand values.
  input  var logic [3:0]  i_alu_lhs,
  input  var logic [3:0]  i_alu_rhs,

  // Results.
  output var logic [3:0]  o_alu_out,
  output var logic        o_alu_cout
);

  // Internal carry signal.
  logic carry_q;


  // Flop the new carry signal, resetting back to 0 for the first cycle of
  // a new instruction.
  always_ff @(posedge i_alu_gck) begin
    carry_q <= i_alu_ctr_last_cycle ? '0 : o_alu_cout;
  end

  // Compute the output value based on the input.
  always_comb begin
    o_alu_out  = 'x;
    o_alu_cout = 'x;

    case (i_alu_op)
      ALU_OP_ADD: begin
        {o_alu_cout, o_alu_out} = i_alu_lhs + i_alu_rhs + {3'b0, carry_q};
      end
      ALU_OP_AND: begin
        o_alu_out = i_alu_lhs & i_alu_rhs;
      end
      ALU_OP_OR_PUTP: begin
        o_alu_out  = i_alu_lhs | i_alu_rhs;
        o_alu_cout = o_alu_out[0];
      end
      default: begin // ALU_OP_XOR
        o_alu_out = i_alu_lhs ^ i_alu_rhs;
      end
    endcase
  end

endmodule
