`include "idli_pkg.svh"

// Predicate register file, 4x1b registers. P3 always returns one.
module idli_prf_m import idli_pkg::*; (
  // Clock - no reset required.
  input  var logic    i_prf_gck,

  // Read port for operand P.
  input  var preg_t   i_prf_p,
  output var logic    o_prf_p_data,

  // Read/write port for Q.
  input  var preg_t   i_prf_q,
  output var logic    o_prf_q_data,
  input  var logic    i_prf_q_wr_en,
  input  var logic    i_prf_q_data
);

  // 3x1b predicate registers. P3 is always one so doesn't need actual data.
  logic [2:0] regs_q;


  // Output data for each read port.
  always_comb o_prf_p_data = &i_prf_p ? '1 : regs_q[i_prf_p];
  always_comb o_prf_q_data = &i_prf_q ? '1 : regs_q[i_prf_q];

  // Write register if enabled.
  for (genvar IDX = 0; IDX < 3; IDX++) begin : num_regs_b
    localparam preg_t REG = preg_t'(IDX);

    always_ff @(posedge i_prf_gck) begin
      if (i_prf_q_wr_en & (i_prf_q == REG)) begin
        regs_q[REG] <= i_prf_q_data;
      end
    end
  end : num_regs_b

endmodule
