// removed package "idli_pkg"
module idli_grf_m (
	i_grf_gck,
	i_grf_b,
	o_grf_b_data,
	i_grf_c,
	o_grf_c_data,
	i_grf_a,
	i_grf_a_vld,
	i_grf_a_data,
	i_grf_pc_vld,
	i_grf_pc_data,
	o_grf_pc_data
);
	reg _sv2v_0;
	// removed import idli_pkg::*;
	// Trace: idli_grf_m.sv:7:3
	input wire i_grf_gck;
	// Trace: idli_grf_m.sv:10:3
	// removed localparam type idli_pkg_greg_t
	input wire [2:0] i_grf_b;
	// Trace: idli_grf_m.sv:11:3
	output reg [3:0] o_grf_b_data;
	// Trace: idli_grf_m.sv:14:3
	input wire [2:0] i_grf_c;
	// Trace: idli_grf_m.sv:15:3
	output reg [3:0] o_grf_c_data;
	// Trace: idli_grf_m.sv:18:3
	input wire [2:0] i_grf_a;
	// Trace: idli_grf_m.sv:19:3
	input wire i_grf_a_vld;
	// Trace: idli_grf_m.sv:20:3
	input wire [3:0] i_grf_a_data;
	// Trace: idli_grf_m.sv:24:3
	input wire i_grf_pc_vld;
	// Trace: idli_grf_m.sv:25:3
	input wire [3:0] i_grf_pc_data;
	// Trace: idli_grf_m.sv:26:3
	output reg [3:0] o_grf_pc_data;
	// Trace: idli_grf_m.sv:30:3
	reg [15:0] regs_q [1:7];
	// Trace: idli_grf_m.sv:33:3
	reg [3:0] regs_d [1:7];
	// Trace: idli_grf_m.sv:37:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_grf_m.sv:37:15
		o_grf_b_data = (|i_grf_b ? regs_q[i_grf_b][3:0] : {4 {1'sb0}});
	end
	// Trace: idli_grf_m.sv:38:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_grf_m.sv:38:15
		o_grf_c_data = (|i_grf_c ? regs_q[i_grf_c][3:0] : {4 {1'sb0}});
	end
	// Trace: idli_grf_m.sv:39:3
	localparam [2:0] idli_pkg_GREG_PC = 3'b111;
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_grf_m.sv:39:15
		o_grf_pc_data = regs_q[idli_pkg_GREG_PC][3:0];
	end
	// Trace: idli_grf_m.sv:42:3
	genvar _gv_REG_1;
	generate
		for (_gv_REG_1 = 1; _gv_REG_1 < 8; _gv_REG_1 = _gv_REG_1 + 1) begin : num_regs_b
			localparam REG = _gv_REG_1;
			// Trace: idli_grf_m.sv:43:5
			always @(*) begin
				if (_sv2v_0)
					;
				// Trace: idli_grf_m.sv:44:7
				regs_d[REG] = regs_q[REG][3:0];
				// Trace: idli_grf_m.sv:48:7
				if ((REG == idli_pkg_GREG_PC) & i_grf_pc_vld)
					// Trace: idli_grf_m.sv:49:9
					regs_d[REG] = i_grf_pc_data;
				if (i_grf_a_vld & (i_grf_a == REG))
					// Trace: idli_grf_m.sv:54:9
					regs_d[REG] = i_grf_a_data;
			end
			// Trace: idli_grf_m.sv:59:5
			always @(posedge i_grf_gck)
				// Trace: idli_grf_m.sv:60:7
				regs_q[REG] <= {regs_d[REG], regs_q[REG][15:4]};
		end
	endgenerate
	initial _sv2v_0 = 0;
endmodule
