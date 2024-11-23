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

  // {{{ Control Signals

  // Counter value and whether it's the final cycle.
  logic [1:0] ctr;
  logic       ctr_last_cycle;

  // }}} Control Signals

  // {{{ SQI Signals

  // Data read from the SQI memory on this cycle.
  logic [3:0] sqi_rd_data;

  // }}} SQI Signals


  // {{{ Control Logic

  idli_ctrl_m ctrl_u (
    .i_ctrl_gck             (i_core_gck),
    .i_ctrl_rst_n           (i_core_rst_n),

    .o_ctrl_ctr             (ctr),
    .o_ctrl_ctr_last_cycle  (ctr_last_cycle)
  );

  // TODO Just add this so we only redirect on the initial cycle to get some
  // more interesting SQI read behaviour until we have a real PC.
  logic sqi_redirect;
  always_ff @(posedge i_core_gck, negedge i_core_rst_n) begin
    if (!i_core_rst_n) begin
      sqi_redirect <= '1;
    end else begin
      sqi_redirect <= '0;
    end
  end

  // }}} Control Logic

  // {{{ SQI Logic

  idli_sqi_ctrl_m sqi_ctrl_u (
    .i_sqi_gck            (i_core_gck),
    .i_sqi_rst_n          (i_core_rst_n),

    .i_sqi_ctr            (ctr),
    .i_sqi_ctr_last_cycle (ctr_last_cycle),
    .i_sqi_redirect       (sqi_redirect),
    .i_sqi_rd             ('1),

    .o_sqi_sck            (o_core_sqi_sck),
    .o_sqi_cs             (o_core_sqi_cs),
    .o_sqi_mode           (o_core_sqi_mode),
    .i_sqi_rd_data        (i_core_sqi_data),
    .o_sqi_rd_data        (sqi_rd_data),
    .o_sqi_wr_data        (o_core_sqi_data),
    .i_sqi_wr_data        ('0),
    .i_sqi_wr_data_vld    ('1)
  );

  // }}} SQI Logic




//  // Whether this is the last cycle of the period.
//  logic ctr_last_cycle;
//
//  // Incoming data from the SQI memory and whether it's valid.
//  logic       sqi_rd_data_vld_q;
//  logic       sqi_rd_data_vld_d;
//  logic [3:0] sqi_rd_data_q;
//
//  // Latched value of the program counter.
//  logic [3:0] pc_q;
//
//
//  // Control module.
//  idli_ctrl_m ctrl_u (
//    .i_ctrl_gck             (i_core_gck),
//    .i_ctrl_rst_n           (i_core_rst_n),
//
//    .o_ctrl_ctr_last_cycle  (ctr_last_cycle),
//
//    .o_ctrl_sqi_sck         (o_core_sqi_sck),
//    .o_ctrl_sqi_cs          (o_core_sqi_cs),
//    .o_ctrl_sqi_mode        (o_core_sqi_mode),
//    .o_ctrl_sqi_data        (o_core_sqi_data),
//    .i_ctrl_sqi_rd          ('1),
//    .i_ctrl_sqi_data        (pc_q),
//    .o_ctrl_sqi_rd_vld      (sqi_rd_data_vld_d)
//  );
//
//
//  // PC and increment/redirect logic.
//  idli_pc_m pc_u (
//    .i_pc_gck             (i_core_gck),
//    .i_pc_rst_n           (i_core_rst_n),
//
//    .i_pc_ctr_last_cycle  (ctr_last_cycle),
//
//    .o_pc_q               (pc_q)
//  );
//
//
//  // Instruction decoder.
//  idli_decode_m decode_u (
//    .i_dcd_gck      (i_core_gck),
//    .i_dcd_rst_n    (i_core_rst_n),
//
//    .i_dcd_enc      (sqi_rd_data_q),
//    .i_dcd_enc_vld  (sqi_rd_data_vld_q)
//  );
//
//
//  // Flop incoming data from the SQI memory. The memory outputs data on the
//  // falling edge of the current cycle, so vld_d will be high on this cycle
//  // indicating we can flop the data at the start of the next cycle. The valid
//  // is always flopped for enabling e.g. decode and is reset to zero.
//  always_ff @(posedge i_core_gck, negedge i_core_rst_n) begin
//    if (!i_core_rst_n) begin
//      sqi_rd_data_vld_q <= '0;
//    end else begin
//      sqi_rd_data_vld_q <= sqi_rd_data_vld_d;
//    end
//  end
//
//  always_ff @(posedge i_core_gck) begin
//    if (sqi_rd_data_vld_d) begin
//      sqi_rd_data_q <= i_core_sqi_data;
//    end
//  end


  // TODO Make use of the signals.
  logic _unused;

  always_comb o_core_din_acp     = '0;
  always_comb o_core_dout        = '0;
  always_comb o_core_dout_vld    = '0;

  always_comb _unused = &{i_core_din, i_core_dout_acp, i_core_din_vld, 1'b0};

endmodule
