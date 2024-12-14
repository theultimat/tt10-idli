// removed package "idli_pkg"
module idli_ctrl_m (
	i_ctrl_gck,
	i_ctrl_rst_n,
	o_ctrl_ctr,
	o_ctrl_ctr_last_cycle,
	o_ctrl_sqi_redirect,
	i_ctrl_dcd_op_c_imm,
	o_ctrl_dcd_enc_vld,
	o_ctrl_ex_op_c_imm
);
	reg _sv2v_0;
	// removed import idli_pkg::*;
	// Trace: idli_ctrl_m.sv:6:3
	input wire i_ctrl_gck;
	// Trace: idli_ctrl_m.sv:7:3
	input wire i_ctrl_rst_n;
	// Trace: idli_ctrl_m.sv:10:3
	output reg [1:0] o_ctrl_ctr;
	// Trace: idli_ctrl_m.sv:11:3
	output reg o_ctrl_ctr_last_cycle;
	// Trace: idli_ctrl_m.sv:14:3
	output reg o_ctrl_sqi_redirect;
	// Trace: idli_ctrl_m.sv:17:3
	input wire i_ctrl_dcd_op_c_imm;
	// Trace: idli_ctrl_m.sv:18:3
	output reg o_ctrl_dcd_enc_vld;
	// Trace: idli_ctrl_m.sv:21:3
	output reg o_ctrl_ex_op_c_imm;
	// Trace: idli_ctrl_m.sv:38:3
	// removed localparam type state_t
	// Trace: idli_ctrl_m.sv:48:3
	reg [2:0] state_q;
	// Trace: idli_ctrl_m.sv:49:3
	reg [2:0] state_d;
	// Trace: idli_ctrl_m.sv:53:3
	reg [1:0] ctr_q;
	// Trace: idli_ctrl_m.sv:54:3
	reg [1:0] ctr_d;
	// Trace: idli_ctrl_m.sv:58:3
	always @(posedge i_ctrl_gck or negedge i_ctrl_rst_n)
		// Trace: idli_ctrl_m.sv:59:5
		if (!i_ctrl_rst_n)
			// Trace: idli_ctrl_m.sv:60:7
			ctr_q <= 1'sb0;
		else
			// Trace: idli_ctrl_m.sv:62:7
			ctr_q <= ctr_d;
	// Trace: idli_ctrl_m.sv:67:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:67:15
		ctr_d = ctr_q + 2'd1;
	end
	// Trace: idli_ctrl_m.sv:71:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:71:15
		o_ctrl_ctr_last_cycle = ctr_q == 2'd3;
	end
	// Trace: idli_ctrl_m.sv:74:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:74:15
		o_ctrl_ctr = ctr_q;
	end
	// Trace: idli_ctrl_m.sv:78:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:79:5
		state_d = state_q;
		// Trace: idli_ctrl_m.sv:81:5
		case (state_q)
			3'd0:
				// Trace: idli_ctrl_m.sv:84:9
				state_d = 3'd1;
			3'd1:
				// Trace: idli_ctrl_m.sv:88:9
				state_d = 3'd2;
			3'd2:
				// Trace: idli_ctrl_m.sv:92:9
				state_d = 3'd3;
			3'd3:
				// Trace: idli_ctrl_m.sv:96:9
				state_d = 3'd4;
			3'd4:
				// Trace: idli_ctrl_m.sv:100:9
				if (i_ctrl_dcd_op_c_imm)
					// Trace: idli_ctrl_m.sv:101:11
					state_d = 3'd5;
			3'd5:
				// Trace: idli_ctrl_m.sv:108:9
				state_d = 3'd4;
			default:
				;
		endcase
	end
	// Trace: idli_ctrl_m.sv:117:3
	always @(posedge i_ctrl_gck or negedge i_ctrl_rst_n)
		// Trace: idli_ctrl_m.sv:118:5
		if (!i_ctrl_rst_n)
			// Trace: idli_ctrl_m.sv:119:7
			state_q <= 3'd0;
		else if (o_ctrl_ctr_last_cycle)
			// Trace: idli_ctrl_m.sv:121:7
			state_q <= state_d;
	// Trace: idli_ctrl_m.sv:126:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:126:15
		o_ctrl_sqi_redirect = state_q == 3'd0;
	end
	// Trace: idli_ctrl_m.sv:130:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:130:15
		o_ctrl_dcd_enc_vld = state_q == 3'd4;
	end
	// Trace: idli_ctrl_m.sv:134:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:134:15
		o_ctrl_ex_op_c_imm = state_q == 3'd5;
	end
	initial _sv2v_0 = 0;
endmodule
