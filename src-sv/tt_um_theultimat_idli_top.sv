/*
 * Copyright (c) 2024 Matt Woodhouse
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

`include "idli_pkg.svh"

module tt_um_theultimat_idli_top import idli_pkg::*; (
    input  var logic [7:0] ui_in,    // Dedicated inputs
    output var logic [7:0] uo_out,   // Dedicated outputs
    input  var logic [7:0] uio_in,   // IOs: Input path
    output var logic [7:0] uio_out,  // IOs: Output path
    output var logic [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  var logic       ena,      // always 1 when the design is powered, so you can ignore it
    input  var logic       clk,      // clock
    input  var logic       rst_n     // reset_n - low to reset
);

  // Whether SQI IO pins are currently inputs or outputs.
  sqi_mode_t mem_io_mode;

  // Used to tie off unused inputs.
  logic _unused;

  // Instantiate the top level of the core.
  idli_core_m core_u (
    .i_core_gck       (clk),
    .i_core_rst_n     (rst_n),

    .o_core_sqi_sck   (uio_out[0]),
    .o_core_sqi_cs    (uio_out[1]),
    .o_core_sqi_mode  (mem_io_mode),

    .i_core_sqi_data  (uio_in [7:4]),
    .o_core_sqi_data  (uio_out[7:4]),

    .i_core_din       (ui_in [7:4]),
    .i_core_din_vld   (ui_in [2]),
    .o_core_din_acp   (uo_out[0]),

    .o_core_dout      (uo_out[7:4]),
    .o_core_dout_vld  (uo_out[2]),
    .i_core_dout_acp  (ui_in [0])
  );

  // SCK and CS are always outputs, and the SIO pins are configured based on
  // the current IO mode. Unused pins are set to outputs and tied off as zero.
  always_comb uio_oe = {{4{mem_io_mode}}, 4'hf};

  // Tie off unused.
  always_comb uio_out[3:2] = '0;

  always_comb uo_out[1] = '0;
  always_comb uo_out[3] = '0;

  always_comb _unused = &{ena, ui_in[1], ui_in[3], uio_in[3:0], 1'b0};

endmodule
