// removed package "idli_pkg"
module idli_sqi_ctrl_m (
	i_sqi_gck,
	i_sqi_rst_n,
	i_sqi_ctr,
	i_sqi_ctr_last_cycle,
	i_sqi_redirect,
	i_sqi_rd,
	o_sqi_sck,
	o_sqi_cs,
	o_sqi_mode,
	i_sqi_rd_data,
	o_sqi_wr_data,
	i_sqi_wr_data,
	i_sqi_wr_data_vld
);
	reg _sv2v_0;
	// removed import idli_pkg::*;
	// Trace: idli_sqi_ctrl_m.sv:7:3
	input wire i_sqi_gck;
	// Trace: idli_sqi_ctrl_m.sv:8:3
	input wire i_sqi_rst_n;
	// Trace: idli_sqi_ctrl_m.sv:11:3
	input wire [1:0] i_sqi_ctr;
	// Trace: idli_sqi_ctrl_m.sv:12:3
	input wire i_sqi_ctr_last_cycle;
	// Trace: idli_sqi_ctrl_m.sv:13:3
	input wire i_sqi_redirect;
	// Trace: idli_sqi_ctrl_m.sv:14:3
	input wire i_sqi_rd;
	// Trace: idli_sqi_ctrl_m.sv:17:3
	output reg o_sqi_sck;
	// Trace: idli_sqi_ctrl_m.sv:18:3
	output reg o_sqi_cs;
	// Trace: idli_sqi_ctrl_m.sv:19:3
	// removed localparam type idli_pkg_sqi_mode_t
	output reg o_sqi_mode;
	// Trace: idli_sqi_ctrl_m.sv:20:3
	input wire [3:0] i_sqi_rd_data;
	// Trace: idli_sqi_ctrl_m.sv:21:3
	output reg [3:0] o_sqi_wr_data;
	// Trace: idli_sqi_ctrl_m.sv:22:3
	input wire [3:0] i_sqi_wr_data;
	// Trace: idli_sqi_ctrl_m.sv:23:3
	input wire i_sqi_wr_data_vld;
	// Trace: idli_sqi_ctrl_m.sv:41:3
	// removed localparam type state_t
	// Trace: idli_sqi_ctrl_m.sv:49:3
	reg [1:0] state_q;
	// Trace: idli_sqi_ctrl_m.sv:50:3
	reg [1:0] state_d;
	// Trace: idli_sqi_ctrl_m.sv:54:3
	wire [3:0] wr_reg_data;
	// Trace: idli_sqi_ctrl_m.sv:55:3
	reg wr_reg_data_wr_en;
	// Trace: idli_sqi_ctrl_m.sv:60:3
	idli_io_reg_m wr_reg_u(
		.i_reg_gck(i_sqi_gck),
		.i_reg_data(i_sqi_wr_data),
		.i_reg_wr_en(wr_reg_data_wr_en),
		.o_reg_data(wr_reg_data)
	);
	// Trace: idli_sqi_ctrl_m.sv:71:3
	always @(posedge i_sqi_gck or negedge i_sqi_rst_n)
		// Trace: idli_sqi_ctrl_m.sv:72:5
		if (!i_sqi_rst_n)
			// Trace: idli_sqi_ctrl_m.sv:73:7
			state_q <= 2'd0;
		else if (i_sqi_ctr_last_cycle)
			// Trace: idli_sqi_ctrl_m.sv:75:7
			state_q <= state_d;
	// Trace: idli_sqi_ctrl_m.sv:81:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:82:5
		case (state_q)
			2'd0:
				// Trace: idli_sqi_ctrl_m.sv:83:20
				state_d = 2'd1;
			2'd1:
				// Trace: idli_sqi_ctrl_m.sv:84:20
				state_d = 2'd2;
			2'd2:
				// Trace: idli_sqi_ctrl_m.sv:85:20
				state_d = 2'd3;
			default:
				// Trace: idli_sqi_ctrl_m.sv:86:20
				state_d = (i_sqi_redirect ? 2'd0 : 2'd3);
		endcase
	end
	// Trace: idli_sqi_ctrl_m.sv:94:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:95:5
		o_sqi_sck = i_sqi_gck;
		// Trace: idli_sqi_ctrl_m.sv:97:5
		if ((state_q == 2'd2) & ~(i_sqi_rd & i_sqi_ctr[1]))
			// Trace: idli_sqi_ctrl_m.sv:98:7
			o_sqi_sck = 1'sb0;
	end
	// Trace: idli_sqi_ctrl_m.sv:104:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:104:15
		o_sqi_cs = (state_q == 2'd0) & ~i_sqi_ctr[1];
	end
	// Trace: idli_sqi_ctrl_m.sv:107:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:108:5
		o_sqi_wr_data = 1'sbx;
		// Trace: idli_sqi_ctrl_m.sv:110:5
		if ((state_q == 2'd0) & i_sqi_ctr[1])
			// Trace: idli_sqi_ctrl_m.sv:112:7
			o_sqi_wr_data = (i_sqi_ctr[0] ? {3'b001, i_sqi_rd} : {4 {1'sb0}});
		else if ((state_q == 2'd1) | ((state_q == 2'd3) & ~i_sqi_rd))
			// Trace: idli_sqi_ctrl_m.sv:115:7
			o_sqi_wr_data = wr_reg_data;
	end
	// Trace: idli_sqi_ctrl_m.sv:123:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:123:15
		o_sqi_mode = ((state_q == 2'd3) & i_sqi_rd ? 1'b0 : 1'b1);
	end
	// Trace: idli_sqi_ctrl_m.sv:129:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:129:15
		wr_reg_data_wr_en = (state_q == 2'd0) | (state_q == 2'd2);
	end
	initial _sv2v_0 = 0;
endmodule
