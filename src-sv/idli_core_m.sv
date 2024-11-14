`include "idli_pkg.svh"

// Top level of the core.
module idli_core_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic          i_core_gck,
  input  var logic          i_core_rst_n,

  // SQI memory control interface.
  output var logic          o_core_mem_sck,
  output var logic          o_core_mem_cs,
  output var logic          o_core_mem_io_mode,

  // SQI memory inputs and outputs.
  input  var logic  [3:0]   i_core_mem_sio,
  output var logic  [3:0]   o_core_mem_sio,

  // Data input interface.
  input  var logic  [3:0]   i_core_din,
  input  var logic          i_core_din_vld,
  output var logic          o_core_din_acp,

  // Data output interface.
  output var logic  [3:0]   o_core_dout,
  output var logic          o_core_dout_vld,
  input  var logic          i_core_dout_acp
);

  // TODO Make use of the signals.
  logic _unused_tie_off;

  always_comb o_core_mem_sck     = 1'b0;
  always_comb o_core_mem_cs      = 1'b1;
  always_comb o_core_mem_io_mode = SQI_IO_MODE_OUT;
  always_comb o_core_mem_sio     = 4'b0;
  always_comb o_core_din_acp     = 1'b0;
  always_comb o_core_dout        = 4'b0;
  always_comb o_core_dout_vld    = 1'b0;

  always_comb _unused_tie_off = &{
    i_core_gck, i_core_rst_n, i_core_mem_sio, i_core_din, i_core_dout_acp,
    i_core_din_vld, 1'b0
  };

endmodule
