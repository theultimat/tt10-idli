`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

//    initial begin
//        $dumpfile("test.vcd");
//        $dumpvars(0, tb);
//    end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Replace tt_um_example with your module name:
  tt_um_theultimat_idli_top user_project (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );


  // Helper signals for cocotb.
  wire sqi_sck = uio_out[0] & uio_oe[0];
  wire sqi_cs = uio_out[1];
  wire [3:0] sqi_data_out = uio_out[7:4];

  wire core_gck            = user_project.core_u.i_core_gck;
  wire core_rst_n          = user_project.core_u.i_core_rst_n;
  wire core_ctr_last_cycle = user_project.core_u.ctr_last_cycle;
  wire core_instr_vld_q    = user_project.core_u.instr_vld_q;

  wire [15:0] core_grf_regs_q [1:7];

  assign core_grf_regs_q[1] = user_project.core_u.grf_u.regs_q[1];
  assign core_grf_regs_q[2] = user_project.core_u.grf_u.regs_q[2];
  assign core_grf_regs_q[3] = user_project.core_u.grf_u.regs_q[3];
  assign core_grf_regs_q[4] = user_project.core_u.grf_u.regs_q[4];
  assign core_grf_regs_q[5] = user_project.core_u.grf_u.regs_q[5];
  assign core_grf_regs_q[6] = user_project.core_u.grf_u.regs_q[6];
  assign core_grf_regs_q[7] = user_project.core_u.grf_u.regs_q[7];

endmodule
