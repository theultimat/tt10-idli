// removed package "idli_pkg"
module idli_io_reg_m (
	i_reg_gck,
	i_reg_data,
	i_reg_wr_en,
	o_reg_data
);
	reg _sv2v_0;
	// removed import idli_pkg::*;
	// Trace: idli_io_reg_m.sv:8:3
	input wire i_reg_gck;
	// Trace: idli_io_reg_m.sv:11:3
	input wire [3:0] i_reg_data;
	// Trace: idli_io_reg_m.sv:12:3
	input wire i_reg_wr_en;
	// Trace: idli_io_reg_m.sv:13:3
	output reg [3:0] o_reg_data;
	// Trace: idli_io_reg_m.sv:17:3
	reg [15:0] data_q;
	// Trace: idli_io_reg_m.sv:22:3
	always @(posedge i_reg_gck)
		// Trace: idli_io_reg_m.sv:23:5
		if (i_reg_wr_en)
			// Trace: idli_io_reg_m.sv:24:7
			data_q <= {i_reg_data, data_q[15:4]};
		else
			// Trace: idli_io_reg_m.sv:26:7
			data_q <= {data_q[11:0], data_q[15:12]};
	// Trace: idli_io_reg_m.sv:32:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_io_reg_m.sv:32:15
		o_reg_data = data_q[3:0];
	end
	initial _sv2v_0 = 0;
endmodule
