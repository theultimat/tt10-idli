// removed package "idli_pkg"
module idli_alu_m (
	i_alu_gck,
	i_alu_ctr_last_cycle,
	i_alu_op,
	i_alu_lhs,
	i_alu_rhs,
	o_alu_out,
	o_alu_cout
);
	reg _sv2v_0;
	// removed import idli_pkg::*;
	// Trace: idli_alu_m.sv:6:3
	input wire i_alu_gck;
	// Trace: idli_alu_m.sv:9:3
	input wire i_alu_ctr_last_cycle;
	// Trace: idli_alu_m.sv:10:3
	// removed localparam type idli_pkg_alu_op_t
	input wire [1:0] i_alu_op;
	// Trace: idli_alu_m.sv:13:3
	input wire [3:0] i_alu_lhs;
	// Trace: idli_alu_m.sv:14:3
	input wire [3:0] i_alu_rhs;
	// Trace: idli_alu_m.sv:17:3
	output reg [3:0] o_alu_out;
	// Trace: idli_alu_m.sv:18:3
	output reg o_alu_cout;
	// Trace: idli_alu_m.sv:22:3
	reg carry_q;
	// Trace: idli_alu_m.sv:27:3
	always @(posedge i_alu_gck)
		// Trace: idli_alu_m.sv:28:5
		carry_q <= (i_alu_ctr_last_cycle ? 1'b0 : o_alu_cout);
	// Trace: idli_alu_m.sv:32:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_alu_m.sv:33:5
		o_alu_out = 1'sbx;
		// Trace: idli_alu_m.sv:34:5
		o_alu_cout = 1'sbx;
		// Trace: idli_alu_m.sv:36:5
		case (i_alu_op)
			2'd0:
				// Trace: idli_alu_m.sv:38:9
				{o_alu_cout, o_alu_out} = (i_alu_lhs + i_alu_rhs) + {3'b000, carry_q};
			2'd1:
				// Trace: idli_alu_m.sv:41:9
				o_alu_out = i_alu_lhs & i_alu_rhs;
			2'd2:
				// Trace: idli_alu_m.sv:44:9
				o_alu_out = i_alu_lhs | i_alu_rhs;
			default:
				// Trace: idli_alu_m.sv:47:9
				o_alu_out = i_alu_lhs ^ i_alu_rhs;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
