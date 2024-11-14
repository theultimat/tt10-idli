// Trace: tt_um_theultimat_idli_top.sv:6:1
`default_nettype none
// removed package "idli_pkg"
module tt_um_theultimat_idli_top (
	ui_in,
	uo_out,
	uio_in,
	uio_out,
	uio_oe,
	ena,
	clk,
	rst_n
);
	reg _sv2v_0;
	// removed import idli_pkg::*;
	// Trace: tt_um_theultimat_idli_top.sv:11:5
	input wire [7:0] ui_in;
	// Trace: tt_um_theultimat_idli_top.sv:12:5
	output reg [7:0] uo_out;
	// Trace: tt_um_theultimat_idli_top.sv:13:5
	input wire [7:0] uio_in;
	// Trace: tt_um_theultimat_idli_top.sv:14:5
	output reg [7:0] uio_out;
	// Trace: tt_um_theultimat_idli_top.sv:15:5
	output reg [7:0] uio_oe;
	// Trace: tt_um_theultimat_idli_top.sv:16:5
	input wire ena;
	// Trace: tt_um_theultimat_idli_top.sv:17:5
	input wire clk;
	// Trace: tt_um_theultimat_idli_top.sv:18:5
	input wire rst_n;
	// Trace: tt_um_theultimat_idli_top.sv:22:3
	// removed localparam type idli_pkg_sqi_io_mode_t
	wire mem_io_mode;
	// Trace: tt_um_theultimat_idli_top.sv:25:3
	reg _unused_tie_off;
	// Trace: tt_um_theultimat_idli_top.sv:28:3
	idli_core_m core_u(
		.i_core_gck(clk),
		.i_core_rst_n(rst_n),
		.o_core_mem_sck(uio_out[0]),
		.o_core_mem_cs(uio_out[1]),
		.o_core_mem_io_mode(mem_io_mode),
		.i_core_mem_sio(uio_in[7:4]),
		.o_core_mem_sio(uio_out[7:4]),
		.i_core_din(ui_in[7:4]),
		.i_core_din_vld(ui_in[2]),
		.o_core_din_acp(uo_out[0]),
		.o_core_dout(uo_out[7:4]),
		.o_core_dout_vld(uo_out[2]),
		.i_core_dout_acp(ui_in[0])
	);
	// Trace: tt_um_theultimat_idli_top.sv:50:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: tt_um_theultimat_idli_top.sv:50:15
		uio_oe = {{4 {mem_io_mode}}, 4'hf};
	end
	// Trace: tt_um_theultimat_idli_top.sv:53:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: tt_um_theultimat_idli_top.sv:53:15
		uio_out[3:2] = 1'sb0;
	end
	// Trace: tt_um_theultimat_idli_top.sv:55:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: tt_um_theultimat_idli_top.sv:55:15
		uo_out[1] = 1'sb0;
	end
	// Trace: tt_um_theultimat_idli_top.sv:56:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: tt_um_theultimat_idli_top.sv:56:15
		uo_out[3] = 1'sb0;
	end
	// Trace: tt_um_theultimat_idli_top.sv:58:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: tt_um_theultimat_idli_top.sv:58:15
		_unused_tie_off = &{ena, ui_in[1], ui_in[3], uio_in[3:0], 1'b0};
	end
	initial _sv2v_0 = 0;
endmodule
