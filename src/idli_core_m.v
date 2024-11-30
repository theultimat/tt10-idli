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
	wire sqi_redirect;
	// Trace: idli_core_m.sv:43:3
	wire [3:0] sqi_rd_data;
	// Trace: idli_core_m.sv:50:3
	wire dcd_enc_vld;
	// Trace: idli_core_m.sv:53:3
	// removed localparam type idli_pkg_alu_op_t
	// removed localparam type idli_pkg_greg_t
	// removed localparam type idli_pkg_preg_t
	// removed localparam type idli_pkg_instr_t
	reg [15:0] instr_q;
	// Trace: idli_core_m.sv:54:3
	wire [15:0] instr_d;
	// Trace: idli_core_m.sv:55:3
	reg instr_vld_q;
	// Trace: idli_core_m.sv:62:3
	wire [3:0] grf_b_data;
	// Trace: idli_core_m.sv:63:3
	wire [3:0] grf_c_data;
	// Trace: idli_core_m.sv:64:3
	wire [3:0] grf_pc_data;
	// Trace: idli_core_m.sv:67:3
	wire prf_p_data;
	// Trace: idli_core_m.sv:68:3
	wire prf_q_data;
	// Trace: idli_core_m.sv:75:3
	reg ex_instr_vld;
	// Trace: idli_core_m.sv:78:3
	wire [3:0] alu_out;
	// Trace: idli_core_m.sv:79:3
	wire alu_cout;
	// Trace: idli_core_m.sv:86:3
	idli_ctrl_m ctrl_u(
		.i_ctrl_gck(i_core_gck),
		.i_ctrl_rst_n(i_core_rst_n),
		.o_ctrl_ctr(ctr),
		.o_ctrl_ctr_last_cycle(ctr_last_cycle),
		.o_ctrl_sqi_redirect(sqi_redirect),
		.o_ctrl_dcd_enc_vld(dcd_enc_vld)
	);
	// Trace: idli_core_m.sv:102:3
	idli_sqi_ctrl_m sqi_ctrl_u(
		.i_sqi_gck(i_core_gck),
		.i_sqi_rst_n(i_core_rst_n),
		.i_sqi_ctr(ctr),
		.i_sqi_ctr_last_cycle(ctr_last_cycle),
		.i_sqi_redirect(sqi_redirect),
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
	// Trace: idli_core_m.sv:125:3
	idli_decode_m decode_u(
		.i_dcd_gck(i_core_gck),
		.i_dcd_rst_n(i_core_rst_n),
		.i_dcd_enc(sqi_rd_data),
		.i_dcd_enc_vld(dcd_enc_vld),
		.o_dcd_instr(instr_d)
	);
	// Trace: idli_core_m.sv:137:3
	always @(posedge i_core_gck or negedge i_core_rst_n)
		// Trace: idli_core_m.sv:138:5
		if (!i_core_rst_n)
			// Trace: idli_core_m.sv:139:7
			instr_vld_q <= 1'sb0;
		else if (ctr_last_cycle) begin
			// Trace: idli_core_m.sv:141:7
			instr_q <= instr_d;
			// Trace: idli_core_m.sv:142:7
			instr_vld_q <= dcd_enc_vld;
		end
	// Trace: idli_core_m.sv:150:3
	idli_grf_m grf_u(
		.i_grf_gck(i_core_gck),
		.i_grf_b(instr_q[8-:3]),
		.o_grf_b_data(grf_b_data),
		.i_grf_c(instr_q[5-:3]),
		.o_grf_c_data(grf_c_data),
		.i_grf_a(instr_q[11-:3]),
		.i_grf_a_vld(instr_q[0] & ex_instr_vld),
		.i_grf_a_data(alu_out),
		.i_grf_pc_vld(1'sb0),
		.i_grf_pc_data(1'sbx),
		.o_grf_pc_data(grf_pc_data)
	);
	// Trace: idli_core_m.sv:168:3
	idli_prf_m prf_u(
		.i_prf_gck(i_core_gck),
		.i_prf_p(instr_q[15-:2]),
		.o_prf_p_data(prf_p_data),
		.i_prf_q(instr_q[13-:2]),
		.o_prf_q_data(prf_q_data),
		.i_prf_q_wr_en(1'sb0),
		.i_prf_q_data(1'sbx)
	);
	// Trace: idli_core_m.sv:184:3
	idli_alu_m alu_u(
		.i_alu_gck(i_core_gck),
		.i_alu_ctr_last_cycle(ctr_last_cycle),
		.i_alu_op(instr_q[2-:2]),
		.i_alu_lhs(grf_b_data),
		.i_alu_rhs(grf_c_data),
		.o_alu_out(alu_out),
		.o_alu_cout(alu_cout)
	);
	// Trace: idli_core_m.sv:198:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:198:15
		ex_instr_vld = prf_p_data & instr_vld_q;
	end
	// Trace: idli_core_m.sv:203:3
	reg _unused;
	// Trace: idli_core_m.sv:205:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:205:15
		o_core_din_acp = 1'sb0;
	end
	// Trace: idli_core_m.sv:206:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:206:15
		o_core_dout = 1'sb0;
	end
	// Trace: idli_core_m.sv:207:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:207:15
		o_core_dout_vld = 1'sb0;
	end
	// Trace: idli_core_m.sv:209:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_core_m.sv:209:15
		_unused = &{i_core_din, i_core_dout_acp, i_core_din_vld, 1'b0, prf_p_data, prf_q_data, alu_cout};
	end
	initial _sv2v_0 = 0;
endmodule
