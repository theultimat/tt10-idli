`include "idli_pkg.svh"

// General purpose register 2R1W register file. Reads to R0 always return zero
// and writes are discarded.
module idli_grf_m import idli_pkg::*; (
  // Clock - no reset required.
  input  var logic        i_grf_gck,

  // Read port for operand B.
  input  var greg_t       i_grf_b,
  output var logic [3:0]  o_grf_b_data,

  // Read port for operand C.
  input  var greg_t       i_grf_c,
  output var logic [3:0]  o_grf_c_data,

  // Write port for operand A.
  input  var greg_t       i_grf_a,
  input  var logic        i_grf_a_vld,
  input  var logic [3:0]  i_grf_a_data,

  // Read/write port for the PC. This write port is only used if A is not also
  // the PC.
  input  var logic        i_grf_pc_vld,
  input  var logic [3:0]  i_grf_pc_data,
  output var logic [3:0]  o_grf_pc_data
);

  // Register storage for R1..R7. R0 is always zero so don't waste flops.
  logic [15:0] regs_q [1:7];

  // Values to be written to each register on each cycle.
  logic [3:0] regs_d [1:7];


  // Output data from each read port, replacing with zero where appropriate.
  always_comb begin
    o_grf_b_data = '0;

    for (int unsigned REG = 1; REG < 8; REG++) begin
      if (i_grf_b == greg_t'(REG)) begin
        o_grf_b_data = regs_q[REG][3:0];
      end
    end
  end

  always_comb begin
    o_grf_c_data = '0;

    for (int unsigned REG = 1; REG < 8; REG++) begin
      if (i_grf_c == greg_t'(REG)) begin
        o_grf_c_data = regs_q[REG][3:0];
      end
    end
  end

  always_comb o_grf_pc_data = regs_q[GREG_PC][3:0];

  for (genvar REG = 1; REG < 8; REG++) begin : num_regs_b
    // Rotate registers on each cycle, latching new data if writing is enabled.
    always_comb begin
      regs_d[REG] = regs_q[REG][3:0];

      // PC defaults to the dedicated write port but is overwritten by the
      // A write port.
      if ((REG == GREG_PC) & i_grf_pc_vld) begin
        regs_d[REG] = i_grf_pc_data;
      end

      // Write new value if enabled.
      if (i_grf_a_vld & (i_grf_a == REG)) begin
        regs_d[REG] = i_grf_a_data;
      end
    end

    // Flop the new value.
    always_ff @(posedge i_grf_gck) begin
      regs_q[REG] <= {regs_d[REG], regs_q[REG][15:4]};
    end
  end : num_regs_b

endmodule
