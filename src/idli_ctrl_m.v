// removed package "idli_pkg"
module idli_ctrl_m (
	i_ctrl_gck,
	i_ctrl_rst_n,
	o_ctrl_ctr_last_cycle,
	o_ctrl_sqi_sck,
	o_ctrl_sqi_cs,
	o_ctrl_sqi_mode,
	o_ctrl_sqi_data,
	i_ctrl_sqi_rd,
	i_ctrl_sqi_data,
	o_ctrl_sqi_rd_vld
);
	reg _sv2v_0;
	// removed import idli_pkg::*;
	// Trace: idli_ctrl_m.sv:6:3
	input wire i_ctrl_gck;
	// Trace: idli_ctrl_m.sv:7:3
	input wire i_ctrl_rst_n;
	// Trace: idli_ctrl_m.sv:10:3
	output reg o_ctrl_ctr_last_cycle;
	// Trace: idli_ctrl_m.sv:13:3
	output reg o_ctrl_sqi_sck;
	// Trace: idli_ctrl_m.sv:14:3
	output reg o_ctrl_sqi_cs;
	// Trace: idli_ctrl_m.sv:15:3
	// removed localparam type idli_pkg_sqi_mode_t
	output reg o_ctrl_sqi_mode;
	// Trace: idli_ctrl_m.sv:16:3
	output reg [3:0] o_ctrl_sqi_data;
	// Trace: idli_ctrl_m.sv:17:3
	input wire i_ctrl_sqi_rd;
	// Trace: idli_ctrl_m.sv:18:3
	input wire [3:0] i_ctrl_sqi_data;
	// Trace: idli_ctrl_m.sv:19:3
	output reg o_ctrl_sqi_rd_vld;
	// Trace: idli_ctrl_m.sv:36:3
	// removed localparam type sqi_state_t
	// Trace: idli_ctrl_m.sv:44:3
	reg [1:0] sqi_state_q;
	// Trace: idli_ctrl_m.sv:45:3
	reg [1:0] sqi_state_d;
	// Trace: idli_ctrl_m.sv:49:3
	reg [15:0] sqi_shift_q;
	// Trace: idli_ctrl_m.sv:52:3
	reg sqi_shift_wr_en_q;
	// Trace: idli_ctrl_m.sv:61:3
	reg [1:0] ctr_q;
	// Trace: idli_ctrl_m.sv:62:3
	reg [1:0] ctr_d;
	// Trace: idli_ctrl_m.sv:71:3
	always @(posedge i_ctrl_gck or negedge i_ctrl_rst_n)
		// Trace: idli_ctrl_m.sv:72:5
		if (!i_ctrl_rst_n)
			// Trace: idli_ctrl_m.sv:73:7
			sqi_state_q <= 2'd0;
		else if (o_ctrl_ctr_last_cycle)
			// Trace: idli_ctrl_m.sv:75:7
			sqi_state_q <= sqi_state_d;
	// Trace: idli_ctrl_m.sv:80:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:81:5
		sqi_state_d = sqi_state_q;
		// Trace: idli_ctrl_m.sv:83:5
		case (sqi_state_q)
			2'd0:
				// Trace: idli_ctrl_m.sv:87:9
				sqi_state_d = 2'd1;
			2'd1:
				// Trace: idli_ctrl_m.sv:93:9
				sqi_state_d = 2'd2;
			2'd2:
				// Trace: idli_ctrl_m.sv:97:9
				sqi_state_d = 2'd3;
			default:
				;
		endcase
	end
	// Trace: idli_ctrl_m.sv:108:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:108:15
		o_ctrl_sqi_cs = (sqi_state_q == 2'd0) & ~ctr_q[1];
	end
	// Trace: idli_ctrl_m.sv:114:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:115:5
		o_ctrl_sqi_sck = i_ctrl_gck;
		// Trace: idli_ctrl_m.sv:117:5
		if ((sqi_state_q == 2'd2) & ~(i_ctrl_sqi_rd & ctr_q[1]))
			// Trace: idli_ctrl_m.sv:118:7
			o_ctrl_sqi_sck = 1'sb0;
	end
	// Trace: idli_ctrl_m.sv:125:3
	always @(posedge i_ctrl_gck or negedge i_ctrl_rst_n)
		// Trace: idli_ctrl_m.sv:126:5
		if (!i_ctrl_rst_n)
			// Trace: idli_ctrl_m.sv:127:7
			sqi_shift_wr_en_q <= 1'sb1;
		else if (o_ctrl_ctr_last_cycle)
			// Trace: idli_ctrl_m.sv:130:7
			sqi_shift_wr_en_q <= 1'sb0;
	// Trace: idli_ctrl_m.sv:137:3
	always @(posedge i_ctrl_gck)
		// Trace: idli_ctrl_m.sv:138:5
		if (sqi_shift_wr_en_q)
			// Trace: idli_ctrl_m.sv:139:7
			sqi_shift_q <= {i_ctrl_sqi_data, sqi_shift_q[15:4]};
		else
			// Trace: idli_ctrl_m.sv:141:7
			sqi_shift_q <= {sqi_shift_q[11:0], sqi_shift_q[15:12]};
	// Trace: idli_ctrl_m.sv:146:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:147:5
		o_ctrl_sqi_data = 1'sbx;
		// Trace: idli_ctrl_m.sv:149:5
		case (sqi_state_q)
			2'd0:
				// Trace: idli_ctrl_m.sv:152:9
				if (ctr_q[1])
					// Trace: idli_ctrl_m.sv:153:11
					o_ctrl_sqi_data = (ctr_q[0] ? {3'b001, i_ctrl_sqi_rd} : {4 {1'sb0}});
			2'd1:
				// Trace: idli_ctrl_m.sv:158:9
				o_ctrl_sqi_data = sqi_shift_q[15:12];
			2'd3:
				// Trace: idli_ctrl_m.sv:162:9
				if (!i_ctrl_sqi_rd)
					// Trace: idli_ctrl_m.sv:163:11
					o_ctrl_sqi_data = sqi_shift_q[15:12];
			default:
				// Trace: idli_ctrl_m.sv:167:9
				o_ctrl_sqi_data = 1'sbx;
		endcase
	end
	// Trace: idli_ctrl_m.sv:175:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:176:5
		o_ctrl_sqi_mode = 1'b1;
		// Trace: idli_ctrl_m.sv:178:5
		if ((sqi_state_q == 2'd3) & i_ctrl_sqi_rd)
			// Trace: idli_ctrl_m.sv:179:7
			o_ctrl_sqi_mode = 1'b0;
	end
	// Trace: idli_ctrl_m.sv:186:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:187:5
		o_ctrl_sqi_rd_vld = i_ctrl_sqi_rd;
		// Trace: idli_ctrl_m.sv:189:5
		if (sqi_state_q == 2'd2)
			// Trace: idli_ctrl_m.sv:190:7
			o_ctrl_sqi_rd_vld = o_ctrl_sqi_rd_vld & o_ctrl_ctr_last_cycle;
	end
	// Trace: idli_ctrl_m.sv:200:3
	always @(posedge i_ctrl_gck or negedge i_ctrl_rst_n)
		// Trace: idli_ctrl_m.sv:201:5
		if (!i_ctrl_rst_n)
			// Trace: idli_ctrl_m.sv:202:7
			ctr_q <= 1'sb0;
		else
			// Trace: idli_ctrl_m.sv:204:7
			ctr_q <= ctr_d;
	// Trace: idli_ctrl_m.sv:209:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:209:15
		ctr_d = ctr_q + 2'd1;
	end
	// Trace: idli_ctrl_m.sv:213:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:213:15
		o_ctrl_ctr_last_cycle = ctr_q == 2'd3;
	end
	initial _sv2v_0 = 0;
endmodule
