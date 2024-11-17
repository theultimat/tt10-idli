`include "idli_pkg.svh"

// Top level of the core.
module idli_core_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic          i_core_gck,
  input  var logic          i_core_rst_n,

  // SQI memory control interface.
  output var logic          o_core_sqi_sck,
  output var logic          o_core_sqi_cs,
  output var sqi_mode_t     o_core_sqi_mode,

  // SQI memory inputs and outputs.
  input  var logic  [3:0]   i_core_sqi_data,
  output var logic  [3:0]   o_core_sqi_data,

  // Data input interface.
  input  var logic  [3:0]   i_core_din,
  input  var logic          i_core_din_vld,
  output var logic          o_core_din_acp,

  // Data output interface.
  output var logic  [3:0]   o_core_dout,
  output var logic          o_core_dout_vld,
  input  var logic          i_core_dout_acp
);

  // Whether this is the last cycle of the period.
  logic ctr_last_cycle;

  // Latched value of the program counter.
  logic [3:0] pc_q;


  // Control module.
  idli_ctrl_m ctrl_u (
    .i_ctrl_gck             (i_core_gck),
    .i_ctrl_rst_n           (i_core_rst_n),

    .o_ctrl_ctr_last_cycle  (ctr_last_cycle),

    .o_ctrl_sqi_sck         (o_core_sqi_sck),
    .o_ctrl_sqi_cs          (o_core_sqi_cs),
    .o_ctrl_sqi_mode        (o_core_sqi_mode),
    .o_ctrl_sqi_data        (o_core_sqi_data),
    .i_ctrl_sqi_rd          ('1),
    .i_ctrl_sqi_data        (pc_q)
  );


  // PC and increment/redirect logic.
  idli_pc_m pc_u (
    .i_pc_gck             (i_core_gck),
    .i_pc_rst_n           (i_core_rst_n),

    .i_pc_ctr_last_cycle  (ctr_last_cycle),

    .o_pc_q               (pc_q)
  );


  // TODO Make use of the signals.
  logic _unused;

  always_comb o_core_din_acp     = '0;
  always_comb o_core_dout        = '0;
  always_comb o_core_dout_vld    = '0;

  always_comb _unused = &{
    i_core_sqi_data, i_core_din, i_core_dout_acp, i_core_din_vld, 1'b0
  };

endmodule
