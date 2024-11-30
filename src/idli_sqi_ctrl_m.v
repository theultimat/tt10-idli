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
	o_sqi_rd_data,
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
	output reg [3:0] o_sqi_rd_data;
	// Trace: idli_sqi_ctrl_m.sv:22:3
	output reg [3:0] o_sqi_wr_data;
	// Trace: idli_sqi_ctrl_m.sv:23:3
	input wire [3:0] i_sqi_wr_data;
	// Trace: idli_sqi_ctrl_m.sv:24:3
	input wire i_sqi_wr_data_vld;
	// Trace: idli_sqi_ctrl_m.sv:42:3
	// removed localparam type state_t
	// Trace: idli_sqi_ctrl_m.sv:50:3
	reg [1:0] state_q;
	// Trace: idli_sqi_ctrl_m.sv:51:3
	reg [1:0] state_d;
	// Trace: idli_sqi_ctrl_m.sv:55:3
	wire [3:0] wr_reg_data;
	// Trace: idli_sqi_ctrl_m.sv:56:3
	reg wr_reg_data_wr_en;
	// Trace: idli_sqi_ctrl_m.sv:59:3
	wire [3:0] mem_reg_data [0:1];
	// Trace: idli_sqi_ctrl_m.sv:60:3
	reg mem_reg_wr_en [0:1];
	// Trace: idli_sqi_ctrl_m.sv:63:3
	reg active_mem_reg_q;
	// Trace: idli_sqi_ctrl_m.sv:64:3
	reg active_mem_reg_d;
	// Trace: idli_sqi_ctrl_m.sv:69:3
	idli_io_reg_m wr_reg_u(
		.i_reg_gck(i_sqi_gck),
		.i_reg_data(i_sqi_wr_data),
		.i_reg_wr_en(wr_reg_data_wr_en),
		.o_reg_data(wr_reg_data)
	);
	// Trace: idli_sqi_ctrl_m.sv:81:3
	genvar _gv_REG_1;
	generate
		for (_gv_REG_1 = 0; _gv_REG_1 < 2; _gv_REG_1 = _gv_REG_1 + 1) begin : num_mem_regs_b
			localparam REG = _gv_REG_1;
			// Trace: idli_sqi_ctrl_m.sv:82:5
			idli_io_reg_m mem_reg_u(
				.i_reg_gck(i_sqi_gck),
				.i_reg_data(i_sqi_rd_data),
				.i_reg_wr_en(mem_reg_wr_en[REG]),
				.o_reg_data(mem_reg_data[REG])
			);
		end
	endgenerate
	// Trace: idli_sqi_ctrl_m.sv:94:3
	always @(posedge i_sqi_gck or negedge i_sqi_rst_n)
		// Trace: idli_sqi_ctrl_m.sv:95:5
		if (!i_sqi_rst_n)
			// Trace: idli_sqi_ctrl_m.sv:96:7
			state_q <= 2'd0;
		else if (i_sqi_ctr_last_cycle)
			// Trace: idli_sqi_ctrl_m.sv:98:7
			state_q <= state_d;
	// Trace: idli_sqi_ctrl_m.sv:104:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:105:5
		case (state_q)
			2'd0:
				// Trace: idli_sqi_ctrl_m.sv:106:20
				state_d = 2'd1;
			2'd1:
				// Trace: idli_sqi_ctrl_m.sv:107:20
				state_d = 2'd2;
			2'd2:
				// Trace: idli_sqi_ctrl_m.sv:108:20
				state_d = 2'd3;
			default:
				// Trace: idli_sqi_ctrl_m.sv:109:20
				state_d = (i_sqi_redirect ? 2'd0 : 2'd3);
		endcase
	end
	// Trace: idli_sqi_ctrl_m.sv:117:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:118:5
		o_sqi_sck = i_sqi_gck;
		// Trace: idli_sqi_ctrl_m.sv:120:5
		if ((state_q == 2'd2) & ~(i_sqi_rd & i_sqi_ctr[1]))
			// Trace: idli_sqi_ctrl_m.sv:121:7
			o_sqi_sck = 1'sb0;
	end
	// Trace: idli_sqi_ctrl_m.sv:127:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:127:15
		o_sqi_cs = (state_q == 2'd0) & ~i_sqi_ctr[1];
	end
	// Trace: idli_sqi_ctrl_m.sv:130:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:131:5
		o_sqi_wr_data = 1'sbx;
		// Trace: idli_sqi_ctrl_m.sv:133:5
		if ((state_q == 2'd0) & i_sqi_ctr[1])
			// Trace: idli_sqi_ctrl_m.sv:135:7
			o_sqi_wr_data = (i_sqi_ctr[0] ? {3'b001, i_sqi_rd} : {4 {1'sb0}});
		else if ((state_q == 2'd1) | ((state_q == 2'd3) & ~i_sqi_rd))
			// Trace: idli_sqi_ctrl_m.sv:138:7
			o_sqi_wr_data = wr_reg_data;
	end
	// Trace: idli_sqi_ctrl_m.sv:146:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:146:15
		o_sqi_mode = ((state_q == 2'd3) & i_sqi_rd ? 1'b0 : 1'b1);
	end
	// Trace: idli_sqi_ctrl_m.sv:152:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:152:15
		wr_reg_data_wr_en = (state_q == 2'd0) | (state_q == 2'd2);
	end
	// Trace: idli_sqi_ctrl_m.sv:155:3
	always @(posedge i_sqi_gck or negedge i_sqi_rst_n)
		// Trace: idli_sqi_ctrl_m.sv:156:5
		if (!i_sqi_rst_n)
			// Trace: idli_sqi_ctrl_m.sv:157:7
			active_mem_reg_q <= 1'sb0;
		else if (i_sqi_ctr_last_cycle)
			// Trace: idli_sqi_ctrl_m.sv:159:7
			active_mem_reg_q <= active_mem_reg_d;
	// Trace: idli_sqi_ctrl_m.sv:166:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:167:5
		if (i_sqi_ctr_last_cycle)
			// Trace: idli_sqi_ctrl_m.sv:168:7
			active_mem_reg_d = ~active_mem_reg_q;
		else
			// Trace: idli_sqi_ctrl_m.sv:170:7
			active_mem_reg_d = active_mem_reg_q;
	end
	// Trace: idli_sqi_ctrl_m.sv:177:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:177:15
		mem_reg_wr_en[0] = ~active_mem_reg_d;
	end
	// Trace: idli_sqi_ctrl_m.sv:178:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:178:15
		mem_reg_wr_en[1] = active_mem_reg_d;
	end
	// Trace: idli_sqi_ctrl_m.sv:183:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_sqi_ctrl_m.sv:183:15
		o_sqi_rd_data = mem_reg_data[~active_mem_reg_q];
	end
	initial _sv2v_0 = 0;
endmodule
