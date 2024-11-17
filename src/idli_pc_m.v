// removed package "idli_pkg"
module idli_pc_m (
	i_pc_gck,
	i_pc_rst_n,
	i_pc_ctr_last_cycle,
	o_pc_q
);
	reg _sv2v_0;
	// Trace: idli_pc_m.sv:7:3
	input wire i_pc_gck;
	// Trace: idli_pc_m.sv:8:3
	input wire i_pc_rst_n;
	// Trace: idli_pc_m.sv:11:3
	input wire i_pc_ctr_last_cycle;
	// Trace: idli_pc_m.sv:14:3
	output reg [3:0] o_pc_q;
	// Trace: idli_pc_m.sv:19:3
	reg [15:0] pc_q;
	// Trace: idli_pc_m.sv:20:3
	reg [3:0] pc_d;
	// Trace: idli_pc_m.sv:24:3
	reg [1:0] inc_q;
	// Trace: idli_pc_m.sv:25:3
	reg [1:0] inc_d;
	// Trace: idli_pc_m.sv:29:3
	always @(posedge i_pc_gck or negedge i_pc_rst_n)
		// Trace: idli_pc_m.sv:30:5
		if (!i_pc_rst_n) begin
			// Trace: idli_pc_m.sv:31:7
			pc_q <= 1'sb0;
			// Trace: idli_pc_m.sv:32:7
			inc_q <= 2'd2;
		end
		else begin
			// Trace: idli_pc_m.sv:34:7
			pc_q <= {pc_d, pc_q[15:4]};
			// Trace: idli_pc_m.sv:35:7
			inc_q <= inc_d;
		end
	// Trace: idli_pc_m.sv:42:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_pc_m.sv:43:5
		inc_d = 1'sb0;
		// Trace: idli_pc_m.sv:44:5
		{inc_d[0], pc_d} = pc_q[3:0] + {2'b00, inc_q};
		// Trace: idli_pc_m.sv:46:5
		if (i_pc_ctr_last_cycle)
			// Trace: idli_pc_m.sv:47:7
			inc_d = 2'd2;
	end
	// Trace: idli_pc_m.sv:52:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_pc_m.sv:52:15
		o_pc_q = pc_q[3:0];
	end
	initial _sv2v_0 = 0;
endmodule
