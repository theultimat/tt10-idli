`include "idli_pkg.svh"

// Generates control signals for the core.
module idli_ctrl_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic        i_ctrl_gck,
  input  var logic        i_ctrl_rst_n,

  // Cycle counter interface.
  output var logic [1:0]  o_ctrl_ctr,
  output var logic        o_ctrl_ctr_last_cycle
);

  // Internal cycle counter. The core is 4b serial so each 16b operation takes
  // a multiple of four cycles to complete.
  logic [1:0] ctr_q;
  logic [1:0] ctr_d;


  // Latch the new cycle counter every cycle or reset back to zero.
  always_ff @(posedge i_ctrl_gck, negedge i_ctrl_rst_n) begin
    if (!i_ctrl_rst_n) begin
      ctr_q <= '0;
    end else begin
      ctr_q <= ctr_d;
    end
  end

  // Counter advances every cycle.
  always_comb ctr_d = ctr_q + 2'd1;

  // Some events only trigger on the transition between first and last cycle
  // i.e. when the counter wraps.
  always_comb o_ctrl_ctr_last_cycle = ctr_q == 2'd3;

  // Make current value of the counter externally visible.
  always_comb o_ctrl_ctr = ctr_q;

endmodule
