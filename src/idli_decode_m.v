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
	// removed localparam type idli_pkg_alu_op_t
	// removed localparam type idli_pkg_greg_t
	// removed localparam type idli_pkg_preg_t
	// removed localparam type idli_pkg_instr_t
	output reg [14:0] o_dcd_instr;
	// Trace: idli_decode_m.sv:22:3
	// removed localparam type state_t
	// Trace: idli_decode_m.sv:45:3
	reg [3:0] state_q;
	// Trace: idli_decode_m.sv:46:3
	reg [3:0] state_d;
	// Trace: idli_decode_m.sv:49:3
	reg [14:0] instr_q;
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
	// Trace: idli_decode_m.sv:62:3
	reg [1:0] alu_op;
	// Trace: idli_decode_m.sv:63:3
	reg alu_op_wr_en;
	// Trace: idli_decode_m.sv:67:3
	always @(posedge i_dcd_gck or negedge i_dcd_rst_n)
		// Trace: idli_decode_m.sv:68:5
		if (!i_dcd_rst_n)
			// Trace: idli_decode_m.sv:69:7
			state_q <= 4'd0;
		else
			// Trace: idli_decode_m.sv:71:7
			state_q <= state_d;
	// Trace: idli_decode_m.sv:76:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:77:5
		state_d = state_q;
		// Trace: idli_decode_m.sv:79:5
		case (state_q)
			4'd0:
				// Trace: idli_decode_m.sv:84:9
				if (i_dcd_enc_vld)
					// Trace: idli_decode_m.sv:87:11
					case (i_dcd_enc[1:0])
						2'b00:
							// Trace: idli_decode_m.sv:88:22
							state_d = 4'd1;
						2'b01:
							// Trace: idli_decode_m.sv:89:22
							state_d = 4'd2;
						2'b10:
							// Trace: idli_decode_m.sv:90:22
							state_d = 4'd3;
						default:
							// Trace: idli_decode_m.sv:91:22
							state_d = 4'd4;
					endcase
			4'd1, 4'd4:
				// Trace: idli_decode_m.sv:98:9
				state_d = 4'd5;
			4'd2:
				// Trace: idli_decode_m.sv:103:9
				case ({i_dcd_enc[3], i_dcd_enc[0]})
					2'b00:
						// Trace: idli_decode_m.sv:104:20
						state_d = 4'd6;
					2'b01:
						// Trace: idli_decode_m.sv:105:20
						state_d = 4'd7;
					default:
						// Trace: idli_decode_m.sv:106:20
						state_d = 4'd8;
				endcase
			4'd3:
				// Trace: idli_decode_m.sv:112:9
				case (i_dcd_enc[3:1])
					3'b110:
						// Trace: idli_decode_m.sv:113:20
						state_d = 4'd9;
					3'b111:
						// Trace: idli_decode_m.sv:114:20
						state_d = 4'd10;
					default:
						// Trace: idli_decode_m.sv:115:20
						state_d = 4'd5;
				endcase
			4'd5, 4'd6, 4'd7:
				// Trace: idli_decode_m.sv:120:9
				state_d = 4'd11;
			4'd8:
				// Trace: idli_decode_m.sv:124:9
				state_d = 4'd12;
			4'd9:
				// Trace: idli_decode_m.sv:129:9
				state_d = 4'd13;
			4'd10:
				// Trace: idli_decode_m.sv:133:9
				state_d = 4'd14;
			default:
				// Trace: idli_decode_m.sv:137:9
				state_d = 4'd0;
		endcase
	end
	// Trace: idli_decode_m.sv:143:3
	always @(posedge i_dcd_gck) begin
		// Trace: idli_decode_m.sv:144:5
		if (op_p_wr_en)
			// Trace: idli_decode_m.sv:145:7
			instr_q[14-:2] <= i_dcd_enc[3:2];
		if (op_q_wr_en)
			// Trace: idli_decode_m.sv:149:7
			instr_q[12-:2] <= i_dcd_enc[2:1];
		if (op_a_wr_en[0])
			// Trace: idli_decode_m.sv:153:7
			instr_q[9:8] <= i_dcd_enc[3:2];
		if (op_a_wr_en[1])
			// Trace: idli_decode_m.sv:157:7
			instr_q[10] <= i_dcd_enc[0];
		if (op_b_wr_en[0])
			// Trace: idli_decode_m.sv:161:7
			instr_q[5] <= i_dcd_enc[3];
		if (op_b_wr_en[1])
			// Trace: idli_decode_m.sv:165:7
			instr_q[7:6] <= i_dcd_enc[1:0];
		if (op_c_wr_en)
			// Trace: idli_decode_m.sv:169:7
			instr_q[4-:3] <= i_dcd_enc[2:0];
		if (alu_op_wr_en)
			// Trace: idli_decode_m.sv:173:7
			instr_q[1-:2] <= alu_op;
	end
	// Trace: idli_decode_m.sv:181:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:181:15
		op_p_wr_en = (state_q == 4'd0) & i_dcd_enc_vld;
	end
	// Trace: idli_decode_m.sv:187:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:188:5
		case (state_q)
			4'd1, 4'd2:
				// Trace: idli_decode_m.sv:190:27
				op_q_wr_en = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:191:27
				op_q_wr_en = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:196:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:197:5
		case (state_q)
			4'd1, 4'd4, 4'd3:
				// Trace: idli_decode_m.sv:200:31
				op_a_wr_en[1] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:201:31
				op_a_wr_en[1] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:206:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:207:5
		case (state_q)
			4'd5, 4'd10, 4'd9:
				// Trace: idli_decode_m.sv:210:23
				op_a_wr_en[0] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:211:23
				op_a_wr_en[0] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:218:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:219:5
		case (state_q)
			4'd5, 4'd6, 4'd7, 4'd10, 4'd9:
				// Trace: idli_decode_m.sv:224:23
				op_b_wr_en[1] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:225:23
				op_b_wr_en[1] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:230:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:231:5
		case (state_q)
			4'd11, 4'd14, 4'd13:
				// Trace: idli_decode_m.sv:234:29
				op_b_wr_en[0] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:235:29
				op_b_wr_en[0] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:240:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:241:5
		case (state_q)
			4'd12, 4'd11:
				// Trace: idli_decode_m.sv:243:17
				op_c_wr_en = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:244:17
				op_c_wr_en = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:249:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:249:15
		o_dcd_instr = instr_q;
	end
	// Trace: idli_decode_m.sv:252:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:253:5
		case (state_q)
			4'd1: begin
				// Trace: idli_decode_m.sv:256:9
				alu_op = 2'd0;
				// Trace: idli_decode_m.sv:257:9
				alu_op_wr_en = 1'sb1;
			end
			4'd3: begin
				// Trace: idli_decode_m.sv:262:9
				case (i_dcd_enc[3:1])
					3'b110:
						// Trace: idli_decode_m.sv:263:20
						alu_op_wr_en = 1'sb0;
					default:
						// Trace: idli_decode_m.sv:264:20
						alu_op_wr_en = 1'sb1;
				endcase
				casez (i_dcd_enc[3:1])
					3'b01z:
						// Trace: idli_decode_m.sv:268:20
						alu_op = 2'd1;
					3'b100:
						// Trace: idli_decode_m.sv:269:20
						alu_op = 2'd2;
					3'b101:
						// Trace: idli_decode_m.sv:270:20
						alu_op = 2'd3;
					default:
						// Trace: idli_decode_m.sv:271:20
						alu_op = 2'd0;
				endcase
			end
			default: begin
				// Trace: idli_decode_m.sv:276:9
				alu_op = 2'bxx;
				// Trace: idli_decode_m.sv:277:9
				alu_op_wr_en = 1'sb0;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
