// removed package "idli_pkg"
module idli_decode_m (
	i_dcd_gck,
	i_dcd_rst_n,
	i_dcd_enc,
	i_dcd_enc_vld,
	o_dcd_instr
);
	reg _sv2v_0;
	// removed import idli_pkg::*;
	// Trace: idli_decode_m.sv:7:3
	input wire i_dcd_gck;
	// Trace: idli_decode_m.sv:8:3
	input wire i_dcd_rst_n;
	// Trace: idli_decode_m.sv:11:3
	input wire [3:0] i_dcd_enc;
	// Trace: idli_decode_m.sv:12:3
	input wire i_dcd_enc_vld;
	// Trace: idli_decode_m.sv:15:3
	// removed localparam type idli_pkg_greg_t
	// removed localparam type idli_pkg_preg_t
	// removed localparam type idli_pkg_instr_t
	output wire [12:0] o_dcd_instr;
	// Trace: idli_decode_m.sv:22:3
	// removed localparam type state_t
	// Trace: idli_decode_m.sv:45:3
	reg [3:0] state_q;
	// Trace: idli_decode_m.sv:46:3
	reg [3:0] state_d;
	// Trace: idli_decode_m.sv:49:3
	reg [12:0] instr_q;
	// Trace: idli_decode_m.sv:55:3
	reg op_p_wr_en;
	// Trace: idli_decode_m.sv:56:3
	reg op_q_wr_en;
	// Trace: idli_decode_m.sv:57:3
	reg [1:0] op_a_wr_en;
	// Trace: idli_decode_m.sv:58:3
	reg [1:0] op_b_wr_en;
	// Trace: idli_decode_m.sv:59:3
	reg op_c_wr_en;
	// Trace: idli_decode_m.sv:63:3
	always @(posedge i_dcd_gck or negedge i_dcd_rst_n)
		// Trace: idli_decode_m.sv:64:5
		if (!i_dcd_rst_n)
			// Trace: idli_decode_m.sv:65:7
			state_q <= 4'd0;
		else
			// Trace: idli_decode_m.sv:67:7
			state_q <= state_d;
	// Trace: idli_decode_m.sv:72:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:73:5
		state_d = state_q;
		// Trace: idli_decode_m.sv:75:5
		case (state_q)
			4'd0:
				// Trace: idli_decode_m.sv:80:9
				if (i_dcd_enc_vld)
					// Trace: idli_decode_m.sv:83:11
					case (i_dcd_enc[1:0])
						2'b00:
							// Trace: idli_decode_m.sv:84:22
							state_d = 4'd1;
						2'b01:
							// Trace: idli_decode_m.sv:85:22
							state_d = 4'd2;
						2'b10:
							// Trace: idli_decode_m.sv:86:22
							state_d = 4'd3;
						default:
							// Trace: idli_decode_m.sv:87:22
							state_d = 4'd4;
					endcase
			4'd1, 4'd4:
				// Trace: idli_decode_m.sv:94:9
				state_d = 4'd5;
			4'd2:
				// Trace: idli_decode_m.sv:99:9
				case ({i_dcd_enc[3], i_dcd_enc[0]})
					2'b00:
						// Trace: idli_decode_m.sv:100:20
						state_d = 4'd6;
					2'b01:
						// Trace: idli_decode_m.sv:101:20
						state_d = 4'd7;
					default:
						// Trace: idli_decode_m.sv:102:20
						state_d = 4'd8;
				endcase
			4'd3:
				// Trace: idli_decode_m.sv:108:9
				case (i_dcd_enc[3:1])
					3'b110:
						// Trace: idli_decode_m.sv:109:20
						state_d = 4'd9;
					3'b111:
						// Trace: idli_decode_m.sv:110:20
						state_d = 4'd10;
					default:
						// Trace: idli_decode_m.sv:111:20
						state_d = 4'd5;
				endcase
			4'd5, 4'd6, 4'd7:
				// Trace: idli_decode_m.sv:116:9
				state_d = 4'd11;
			4'd8:
				// Trace: idli_decode_m.sv:120:9
				state_d = 4'd12;
			4'd9:
				// Trace: idli_decode_m.sv:125:9
				state_d = 4'd13;
			4'd10:
				// Trace: idli_decode_m.sv:129:9
				state_d = 4'd14;
			default:
				// Trace: idli_decode_m.sv:133:9
				state_d = 4'd0;
		endcase
	end
	// Trace: idli_decode_m.sv:139:3
	always @(posedge i_dcd_gck) begin
		// Trace: idli_decode_m.sv:140:5
		if (op_p_wr_en)
			// Trace: idli_decode_m.sv:141:7
			instr_q[12-:2] <= i_dcd_enc[3:2];
		if (op_q_wr_en)
			// Trace: idli_decode_m.sv:145:7
			instr_q[10-:2] <= i_dcd_enc[2:1];
		if (op_a_wr_en[0])
			// Trace: idli_decode_m.sv:149:7
			instr_q[7:6] <= i_dcd_enc[3:2];
		if (op_a_wr_en[1])
			// Trace: idli_decode_m.sv:153:7
			instr_q[8] <= i_dcd_enc[0];
		if (op_b_wr_en[0])
			// Trace: idli_decode_m.sv:157:7
			instr_q[3] <= i_dcd_enc[3];
		if (op_b_wr_en[1])
			// Trace: idli_decode_m.sv:161:7
			instr_q[5:4] <= i_dcd_enc[1:0];
		if (op_c_wr_en)
			// Trace: idli_decode_m.sv:165:7
			instr_q[2-:3] <= i_dcd_enc[2:0];
	end
	// Trace: idli_decode_m.sv:173:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:173:15
		op_p_wr_en = (state_q == 4'd0) & i_dcd_enc_vld;
	end
	// Trace: idli_decode_m.sv:179:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:180:5
		case (state_q)
			4'd1, 4'd2:
				// Trace: idli_decode_m.sv:182:27
				op_q_wr_en = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:183:27
				op_q_wr_en = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:188:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:189:5
		case (state_q)
			4'd1, 4'd4, 4'd3:
				// Trace: idli_decode_m.sv:192:31
				op_a_wr_en[1] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:193:31
				op_a_wr_en[1] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:198:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:199:5
		case (state_q)
			4'd5, 4'd10, 4'd9:
				// Trace: idli_decode_m.sv:202:23
				op_a_wr_en[0] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:203:23
				op_a_wr_en[0] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:210:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:211:5
		case (state_q)
			4'd5, 4'd6, 4'd7, 4'd10, 4'd9:
				// Trace: idli_decode_m.sv:216:23
				op_b_wr_en[1] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:217:23
				op_b_wr_en[1] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:222:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:223:5
		case (state_q)
			4'd11, 4'd14, 4'd13:
				// Trace: idli_decode_m.sv:226:29
				op_b_wr_en[0] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:227:29
				op_b_wr_en[0] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:232:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:233:5
		case (state_q)
			4'd12, 4'd11:
				// Trace: idli_decode_m.sv:235:17
				op_c_wr_en = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:236:17
				op_c_wr_en = 1'sb0;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
