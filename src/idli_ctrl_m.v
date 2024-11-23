// removed package "idli_pkg"
module idli_ctrl_m (
	i_ctrl_gck,
	i_ctrl_rst_n,
	o_ctrl_ctr,
	o_ctrl_ctr_last_cycle,
	o_ctrl_sqi_redirect,
	o_ctrl_dcd_enc_vld
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
	output reg o_ctrl_dcd_enc_vld;
	// Trace: idli_ctrl_m.sv:31:3
	// removed localparam type state_t
	// Trace: idli_ctrl_m.sv:40:3
	reg [2:0] state_q;
	// Trace: idli_ctrl_m.sv:41:3
	reg [2:0] state_d;
	// Trace: idli_ctrl_m.sv:45:3
	reg [1:0] ctr_q;
	// Trace: idli_ctrl_m.sv:46:3
	reg [1:0] ctr_d;
	// Trace: idli_ctrl_m.sv:50:3
	always @(posedge i_ctrl_gck or negedge i_ctrl_rst_n)
		// Trace: idli_ctrl_m.sv:51:5
		if (!i_ctrl_rst_n)
			// Trace: idli_ctrl_m.sv:52:7
			ctr_q <= 1'sb0;
		else
			// Trace: idli_ctrl_m.sv:54:7
			ctr_q <= ctr_d;
	// Trace: idli_ctrl_m.sv:59:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:59:15
		ctr_d = ctr_q + 2'd1;
	end
	// Trace: idli_ctrl_m.sv:63:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:63:15
		o_ctrl_ctr_last_cycle = ctr_q == 2'd3;
	end
	// Trace: idli_ctrl_m.sv:66:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:66:15
		o_ctrl_ctr = ctr_q;
	end
	// Trace: idli_ctrl_m.sv:70:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:71:5
		state_d = state_q;
		// Trace: idli_ctrl_m.sv:73:5
		case (state_q)
			3'd0:
				// Trace: idli_ctrl_m.sv:76:9
				state_d = 3'd1;
			3'd1:
				// Trace: idli_ctrl_m.sv:80:9
				state_d = 3'd2;
			3'd2:
				// Trace: idli_ctrl_m.sv:84:9
				state_d = 3'd3;
			3'd3:
				// Trace: idli_ctrl_m.sv:88:9
				state_d = 3'd4;
			default:
				;
		endcase
	end
	// Trace: idli_ctrl_m.sv:97:3
	always @(posedge i_ctrl_gck or negedge i_ctrl_rst_n)
		// Trace: idli_ctrl_m.sv:98:5
		if (!i_ctrl_rst_n)
			// Trace: idli_ctrl_m.sv:99:7
			state_q <= 3'd0;
		else if (o_ctrl_ctr_last_cycle)
			// Trace: idli_ctrl_m.sv:101:7
			state_q <= state_d;
	// Trace: idli_ctrl_m.sv:106:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:106:15
		o_ctrl_sqi_redirect = state_q == 3'd0;
	end
	// Trace: idli_ctrl_m.sv:110:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:110:15
		o_ctrl_dcd_enc_vld = state_q == 3'd4;
	end
	initial _sv2v_0 = 0;
endmodule
