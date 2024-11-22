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
	// Trace: idli_core_m.sv:30:3
	wire ctr_last_cycle;
	// Trace: idli_core_m.sv:33:3
	reg sqi_rd_data_vld_q;
	// Trace: idli_core_m.sv:34:3
	wire sqi_rd_data_vld_d;
	// Trace: idli_core_m.sv:35:3
	reg [3:0] sqi_rd_data_q;
	// Trace: idli_core_m.sv:38:3
	wire [3:0] pc_q;
	// Trace: idli_core_m.sv:42:3
	idli_ctrl_m ctrl_u(
		.i_ctrl_gck(i_core_gck),
		.i_ctrl_rst_n(i_core_rst_n),
		.o_ctrl_ctr_last_cycle(ctr_last_cycle),
		.o_ctrl_sqi_sck(o_core_sqi_sck),
		.o_ctrl_sqi_cs(o_core_sqi_cs),
		.o_ctrl_sqi_mode(o_core_sqi_mode),
		.o_ctrl_sqi_data(o_core_sqi_data),
		.i_ctrl_sqi_rd(1'sb1),
		.i_ctrl_sqi_data(pc_q),
		.o_ctrl_sqi_rd_vld(sqi_rd_data_vld_d)
	);
	// Trace: idli_core_m.sv:59:3
	idli_pc_m pc_u(
		.i_pc_gck(i_core_gck),
		.i_pc_rst_n(i_core_rst_n),
		.i_pc_ctr_last_cycle(ctr_last_cycle),
		.o_pc_q(pc_q)
	);
	// Trace: idli_core_m.sv:73:3
	always @(posedge i_core_gck or negedge i_core_rst_n)
		// Trace: idli_core_m.sv:74:5
		if (!i_core_rst_n)
			// Trace: idli_core_m.sv:75:7
			sqi_rd_data_vld_q <= 1'sb0;
		else
			// Trace: idli_core_m.sv:77:7
			sqi_rd_data_vld_q <= sqi_rd_data_vld_d;
	// Trace: idli_core_m.sv:81:3
	always @(posedge i_core_gck)
		// Trace: idli_core_m.sv:82:5
		if (sqi_rd_data_vld_d)
			// Trace: idli_core_m.sv:83:7
			sqi_rd_data_q <= i_core_sqi_data;
	// Trace: idli_core_m.sv:89:3
	reg _unused;
	// Trace: idli_core_m.sv:91:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:91:15
		o_core_din_acp = 1'sb0;
	end
	// Trace: idli_core_m.sv:92:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:92:15
		o_core_dout = 1'sb0;
	end
	// Trace: idli_core_m.sv:93:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:93:15
		o_core_dout_vld = 1'sb0;
	end
	// Trace: idli_core_m.sv:95:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:95:15
		_unused = &{i_core_din, i_core_dout_acp, i_core_din_vld, 1'b0};
	end
	initial _sv2v_0 = 0;
endmodule
