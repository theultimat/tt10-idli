// removed package "idli_pkg"
module idli_prf_m (
	i_prf_gck,
	i_prf_p,
	o_prf_p_data,
	i_prf_q,
	o_prf_q_data,
	i_prf_q_wr_en,
	i_prf_q_data
);
	reg _sv2v_0;
	// removed import idli_pkg::*;
	// Trace: idli_prf_m.sv:6:3
	input wire i_prf_gck;
	// Trace: idli_prf_m.sv:9:3
	// removed localparam type idli_pkg_preg_t
	input wire [1:0] i_prf_p;
	// Trace: idli_prf_m.sv:10:3
	output reg o_prf_p_data;
	// Trace: idli_prf_m.sv:13:3
	input wire [1:0] i_prf_q;
	// Trace: idli_prf_m.sv:14:3
	output reg o_prf_q_data;
	// Trace: idli_prf_m.sv:15:3
	input wire i_prf_q_wr_en;
	// Trace: idli_prf_m.sv:16:3
	input wire i_prf_q_data;
	// Trace: idli_prf_m.sv:20:3
	reg regs_q [0:2];
	// Trace: idli_prf_m.sv:24:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_prf_m.sv:24:15
		o_prf_p_data = (&i_prf_p ? 1'b1 : regs_q[i_prf_p]);
	end
	// Trace: idli_prf_m.sv:25:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_prf_m.sv:25:15
		o_prf_q_data = (&i_prf_q ? 1'b1 : regs_q[i_prf_q]);
	end
	// Trace: idli_prf_m.sv:28:3
	genvar _gv_REG_1;
	generate
		for (_gv_REG_1 = 0; _gv_REG_1 < 3; _gv_REG_1 = _gv_REG_1 + 1) begin : num_regs_b
			localparam REG = _gv_REG_1;
			// Trace: idli_prf_m.sv:29:5
			always @(posedge i_prf_gck)
				// Trace: idli_prf_m.sv:30:7
				if (i_prf_q_wr_en & (i_prf_q == REG))
					// Trace: idli_prf_m.sv:31:9
					regs_q[REG] <= i_prf_q_data;
		end
	endgenerate
	initial _sv2v_0 = 0;
endmodule
