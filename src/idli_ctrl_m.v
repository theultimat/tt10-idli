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
	i_ctrl_sqi_data
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
	// Trace: idli_ctrl_m.sv:35:3
	// removed localparam type sqi_state_t
	// Trace: idli_ctrl_m.sv:43:3
	reg [1:0] sqi_state_q;
	// Trace: idli_ctrl_m.sv:44:3
	reg [1:0] sqi_state_d;
	// Trace: idli_ctrl_m.sv:48:3
	reg [15:0] sqi_shift_q;
	// Trace: idli_ctrl_m.sv:51:3
	reg sqi_shift_wr_en_q;
	// Trace: idli_ctrl_m.sv:60:3
	reg [1:0] ctr_q;
	// Trace: idli_ctrl_m.sv:61:3
	reg [1:0] ctr_d;
	// Trace: idli_ctrl_m.sv:70:3
	always @(posedge i_ctrl_gck or negedge i_ctrl_rst_n)
		// Trace: idli_ctrl_m.sv:71:5
		if (!i_ctrl_rst_n)
			// Trace: idli_ctrl_m.sv:72:7
			sqi_state_q <= 2'd0;
		else if (o_ctrl_ctr_last_cycle)
			// Trace: idli_ctrl_m.sv:74:7
			sqi_state_q <= sqi_state_d;
	// Trace: idli_ctrl_m.sv:79:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:80:5
		sqi_state_d = sqi_state_q;
		// Trace: idli_ctrl_m.sv:82:5
		case (sqi_state_q)
			2'd0:
				// Trace: idli_ctrl_m.sv:86:9
				sqi_state_d = 2'd1;
			2'd1:
				// Trace: idli_ctrl_m.sv:92:9
				sqi_state_d = 2'd2;
			2'd2:
				// Trace: idli_ctrl_m.sv:96:9
				sqi_state_d = 2'd3;
			default:
				;
		endcase
	end
	// Trace: idli_ctrl_m.sv:107:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:107:15
		o_ctrl_sqi_cs = (sqi_state_q == 2'd0) & ~ctr_q[1];
	end
	// Trace: idli_ctrl_m.sv:113:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:114:5
		o_ctrl_sqi_sck = i_ctrl_gck;
		// Trace: idli_ctrl_m.sv:116:5
		if ((sqi_state_q == 2'd2) & ~(i_ctrl_sqi_rd & ctr_q[1]))
			// Trace: idli_ctrl_m.sv:117:7
			o_ctrl_sqi_sck = 1'sb0;
	end
	// Trace: idli_ctrl_m.sv:124:3
	always @(posedge i_ctrl_gck or negedge i_ctrl_rst_n)
		// Trace: idli_ctrl_m.sv:125:5
		if (!i_ctrl_rst_n)
			// Trace: idli_ctrl_m.sv:126:7
			sqi_shift_wr_en_q <= 1'sb1;
		else if (o_ctrl_ctr_last_cycle)
			// Trace: idli_ctrl_m.sv:129:7
			sqi_shift_wr_en_q <= 1'sb0;
	// Trace: idli_ctrl_m.sv:136:3
	always @(posedge i_ctrl_gck)
		// Trace: idli_ctrl_m.sv:137:5
		if (sqi_shift_wr_en_q)
			// Trace: idli_ctrl_m.sv:138:7
			sqi_shift_q <= {i_ctrl_sqi_data, sqi_shift_q[15:4]};
		else
			// Trace: idli_ctrl_m.sv:140:7
			sqi_shift_q <= {sqi_shift_q[11:0], sqi_shift_q[15:12]};
	// Trace: idli_ctrl_m.sv:145:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:146:5
		case (sqi_state_q)
			2'd0:
				// Trace: idli_ctrl_m.sv:149:9
				if (ctr_q[1])
					// Trace: idli_ctrl_m.sv:150:11
					o_ctrl_sqi_data = (ctr_q[0] ? {3'b001, i_ctrl_sqi_rd} : {4 {1'sb0}});
			2'd1:
				// Trace: idli_ctrl_m.sv:155:9
				o_ctrl_sqi_data = sqi_shift_q[15:12];
			2'd3:
				// Trace: idli_ctrl_m.sv:159:9
				if (!i_ctrl_sqi_rd)
					// Trace: idli_ctrl_m.sv:160:11
					o_ctrl_sqi_data = sqi_shift_q[15:12];
			default:
				// Trace: idli_ctrl_m.sv:164:9
				o_ctrl_sqi_data = 1'sbx;
		endcase
	end
	// Trace: idli_ctrl_m.sv:172:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:173:5
		o_ctrl_sqi_mode = 1'b1;
		// Trace: idli_ctrl_m.sv:175:5
		if ((sqi_state_q == 2'd3) & i_ctrl_sqi_rd)
			// Trace: idli_ctrl_m.sv:176:7
			o_ctrl_sqi_mode = 1'b0;
	end
	// Trace: idli_ctrl_m.sv:186:3
	always @(posedge i_ctrl_gck or negedge i_ctrl_rst_n)
		// Trace: idli_ctrl_m.sv:187:5
		if (!i_ctrl_rst_n)
			// Trace: idli_ctrl_m.sv:188:7
			ctr_q <= 1'sb0;
		else
			// Trace: idli_ctrl_m.sv:190:7
			ctr_q <= ctr_d;
	// Trace: idli_ctrl_m.sv:195:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:195:15
		ctr_d = ctr_q + 2'd1;
	end
	// Trace: idli_ctrl_m.sv:199:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_ctrl_m.sv:199:15
		o_ctrl_ctr_last_cycle = ctr_q == 2'd3;
	end
	initial _sv2v_0 = 0;
endmodule
