// removed package "idli_pkg"
module idli_ctrl_m (
	i_ctrl_gck,
	i_ctrl_rst_n,
	o_ctrl_ctr,
	o_ctrl_ctr_last_cycle
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
	// Trace: idli_ctrl_m.sv:16:3
	reg [1:0] ctr_q;
	// Trace: idli_ctrl_m.sv:17:3
	reg [1:0] ctr_d;
	// Trace: idli_ctrl_m.sv:21:3
	always @(posedge i_ctrl_gck or negedge i_ctrl_rst_n)
		// Trace: idli_ctrl_m.sv:22:5
		if (!i_ctrl_rst_n)
			// Trace: idli_ctrl_m.sv:23:7
			ctr_q <= 1'sb0;
		else
			// Trace: idli_ctrl_m.sv:25:7
			ctr_q <= ctr_d;
	// Trace: idli_ctrl_m.sv:30:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:30:15
		ctr_d = ctr_q + 2'd1;
	end
	// Trace: idli_ctrl_m.sv:34:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:34:15
		o_ctrl_ctr_last_cycle = ctr_q == 2'd3;
	end
	// Trace: idli_ctrl_m.sv:37:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:37:15
		o_ctrl_ctr = ctr_q;
	end
	initial _sv2v_0 = 0;
endmodule
