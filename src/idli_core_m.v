// removed package "idli_pkg"
module idli_core_m (
	i_core_gck,
	i_core_rst_n,
	o_core_mem_sck,
	o_core_mem_cs,
	o_core_mem_io_mode,
	i_core_mem_sio,
	o_core_mem_sio,
	i_core_din,
	i_core_din_vld,
	o_core_din_acp,
	o_core_dout,
	o_core_dout_vld,
	i_core_dout_acp
);
	reg _sv2v_0;
	// removed import idli_pkg::*;
	// Trace: idli_core_m.sv:6:3
	input wire i_core_gck;
	// Trace: idli_core_m.sv:7:3
	input wire i_core_rst_n;
	// Trace: idli_core_m.sv:10:3
	output reg o_core_mem_sck;
	// Trace: idli_core_m.sv:11:3
	output reg o_core_mem_cs;
	// Trace: idli_core_m.sv:12:3
	output reg o_core_mem_io_mode;
	// Trace: idli_core_m.sv:15:3
	input wire [3:0] i_core_mem_sio;
	// Trace: idli_core_m.sv:16:3
	output reg [3:0] o_core_mem_sio;
	// Trace: idli_core_m.sv:19:3
	input wire [3:0] i_core_din;
	// Trace: idli_core_m.sv:20:3
	input wire i_core_din_vld;
	// Trace: idli_core_m.sv:21:3
	output reg o_core_din_acp;
	// Trace: idli_core_m.sv:24:3
	output reg [3:0] o_core_dout;
	// Trace: idli_core_m.sv:25:3
	output reg o_core_dout_vld;
	// Trace: idli_core_m.sv:26:3
	input wire i_core_dout_acp;
	// Trace: idli_core_m.sv:30:3
	reg _unused;
	// Trace: idli_core_m.sv:32:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:32:15
		o_core_mem_sck = 1'b0;
	end
	// Trace: idli_core_m.sv:33:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:33:15
		o_core_mem_cs = 1'b1;
	end
	// Trace: idli_core_m.sv:34:3
	// removed localparam type idli_pkg_sqi_io_mode_t
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:34:15
		o_core_mem_io_mode = 1'b1;
	end
	// Trace: idli_core_m.sv:35:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:35:15
		o_core_mem_sio = 4'b0000;
	end
	// Trace: idli_core_m.sv:36:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:36:15
		o_core_din_acp = 1'b0;
	end
	// Trace: idli_core_m.sv:37:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:37:15
		o_core_dout = 4'b0000;
	end
	// Trace: idli_core_m.sv:38:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:38:15
		o_core_dout_vld = 1'b0;
	end
	// Trace: idli_core_m.sv:40:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:40:15
		_unused = &{i_core_gck, i_core_rst_n, i_core_mem_sio, i_core_din, i_core_dout_acp, i_core_din_vld, 1'b0};
	end
	initial _sv2v_0 = 0;
endmodule
