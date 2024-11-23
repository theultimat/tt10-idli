// removed package "idli_pkg"
module idli_core_m (
	i_core_gck,
	i_core_rst_n,
	o_core_sqi_sck,
	o_core_sqi_cs,
	o_core_sqi_mode,
	i_core_sqi_data,
	o_core_sqi_data,
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
	output wire o_core_sqi_sck;
	// Trace: idli_core_m.sv:11:3
	output wire o_core_sqi_cs;
	// Trace: idli_core_m.sv:12:3
	// removed localparam type idli_pkg_sqi_mode_t
	output wire o_core_sqi_mode;
	// Trace: idli_core_m.sv:15:3
	input wire [3:0] i_core_sqi_data;
	// Trace: idli_core_m.sv:16:3
	output wire [3:0] o_core_sqi_data;
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
	// Trace: idli_core_m.sv:32:3
	wire [1:0] ctr;
	// Trace: idli_core_m.sv:33:3
	wire ctr_last_cycle;
	// Trace: idli_core_m.sv:40:3
	wire [3:0] sqi_rd_data;
	// Trace: idli_core_m.sv:47:3
	idli_ctrl_m ctrl_u(
		.i_ctrl_gck(i_core_gck),
		.i_ctrl_rst_n(i_core_rst_n),
		.o_ctrl_ctr(ctr),
		.o_ctrl_ctr_last_cycle(ctr_last_cycle)
	);
	// Trace: idli_core_m.sv:59:3
	idli_sqi_ctrl_m sqi_ctrl_u(
		.i_sqi_gck(i_core_gck),
		.i_sqi_rst_n(i_core_rst_n),
		.i_sqi_ctr(ctr),
		.i_sqi_ctr_last_cycle(ctr_last_cycle),
		.i_sqi_redirect(1'sb1),
		.i_sqi_rd(1'sb1),
		.o_sqi_sck(o_core_sqi_sck),
		.o_sqi_cs(o_core_sqi_cs),
		.o_sqi_mode(o_core_sqi_mode),
		.i_sqi_rd_data(i_core_sqi_data),
		.o_sqi_rd_data(sqi_rd_data),
		.o_sqi_wr_data(o_core_sqi_data),
		.i_sqi_wr_data(1'sb0),
		.i_sqi_wr_data_vld(1'sb1)
	);
	// Trace: idli_core_m.sv:153:3
	reg _unused;
	// Trace: idli_core_m.sv:155:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:155:15
		o_core_din_acp = 1'sb0;
	end
	// Trace: idli_core_m.sv:156:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:156:15
		o_core_dout = 1'sb0;
	end
	// Trace: idli_core_m.sv:157:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:157:15
		o_core_dout_vld = 1'sb0;
	end
	// Trace: idli_core_m.sv:159:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:159:15
		_unused = &{i_core_din, i_core_dout_acp, i_core_din_vld, 1'b0};
	end
	initial _sv2v_0 = 0;
endmodule
