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
	output reg [16:0] o_dcd_instr;
	// Trace: idli_decode_m.sv:22:3
	// removed localparam type state_t
	// Trace: idli_decode_m.sv:44:3
	reg [3:0] state_q;
	// Trace: idli_decode_m.sv:45:3
	reg [3:0] state_d;
	// Trace: idli_decode_m.sv:48:3
	reg [16:0] instr_q;
	// Trace: idli_decode_m.sv:49:3
	reg [16:0] instr_d;
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
	reg op_a_wr_en_;
	// Trace: idli_decode_m.sv:68:3
	reg op_a_wr_en_wr_en;
	// Trace: idli_decode_m.sv:69:3
	reg op_q_wr_en_;
	// Trace: idli_decode_m.sv:70:3
	reg op_q_wr_en_wr_en;
	// Trace: idli_decode_m.sv:74:3
	always @(posedge i_dcd_gck or negedge i_dcd_rst_n)
		// Trace: idli_decode_m.sv:75:5
		if (!i_dcd_rst_n)
			// Trace: idli_decode_m.sv:76:7
			state_q <= 4'd0;
		else
			// Trace: idli_decode_m.sv:78:7
			state_q <= state_d;
	// Trace: idli_decode_m.sv:83:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:84:5
		state_d = state_q;
		// Trace: idli_decode_m.sv:86:5
		case (state_q)
			4'd0:
				// Trace: idli_decode_m.sv:91:9
				if (i_dcd_enc_vld)
					// Trace: idli_decode_m.sv:94:11
					case (i_dcd_enc[1:0])
						2'b00:
							// Trace: idli_decode_m.sv:95:22
							state_d = 4'd1;
						2'b01:
							// Trace: idli_decode_m.sv:96:22
							state_d = 4'd2;
						2'b10:
							// Trace: idli_decode_m.sv:97:22
							state_d = 4'd3;
						default:
							// Trace: idli_decode_m.sv:98:22
							state_d = 4'd4;
					endcase
			4'd1, 4'd4:
				// Trace: idli_decode_m.sv:105:9
				state_d = 4'd5;
			4'd2:
				// Trace: idli_decode_m.sv:112:9
				case ({i_dcd_enc[3], i_dcd_enc[0]})
					2'b00:
						// Trace: idli_decode_m.sv:113:20
						state_d = 4'd6;
					default:
						// Trace: idli_decode_m.sv:114:20
						state_d = 4'd7;
				endcase
			4'd3:
				// Trace: idli_decode_m.sv:120:9
				case (i_dcd_enc[3:1])
					3'b110:
						// Trace: idli_decode_m.sv:121:20
						state_d = 4'd8;
					3'b111:
						// Trace: idli_decode_m.sv:122:20
						state_d = 4'd9;
					default:
						// Trace: idli_decode_m.sv:123:20
						state_d = 4'd5;
				endcase
			4'd5, 4'd6, 4'd7:
				// Trace: idli_decode_m.sv:128:9
				state_d = 4'd10;
			4'd8:
				// Trace: idli_decode_m.sv:133:9
				state_d = 4'd12;
			4'd9:
				// Trace: idli_decode_m.sv:137:9
				state_d = 4'd13;
			default:
				// Trace: idli_decode_m.sv:141:9
				state_d = 4'd0;
		endcase
	end
	// Trace: idli_decode_m.sv:147:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:148:5
		instr_d = instr_q;
		// Trace: idli_decode_m.sv:150:5
		if (op_p_wr_en)
			// Trace: idli_decode_m.sv:151:7
			instr_d[16-:2] = i_dcd_enc[3:2];
		if (op_q_wr_en)
			// Trace: idli_decode_m.sv:155:7
			instr_d[14-:2] = i_dcd_enc[2:1];
		if (op_a_wr_en[0])
			// Trace: idli_decode_m.sv:159:7
			instr_d[11:10] = i_dcd_enc[3:2];
		if (op_a_wr_en[1])
			// Trace: idli_decode_m.sv:163:7
			instr_d[12] = i_dcd_enc[0];
		if (op_b_wr_en[0])
			// Trace: idli_decode_m.sv:167:7
			instr_d[7] = i_dcd_enc[3];
		if (op_b_wr_en[1])
			// Trace: idli_decode_m.sv:171:7
			instr_d[9:8] = i_dcd_enc[1:0];
		if (op_c_wr_en)
			// Trace: idli_decode_m.sv:175:7
			instr_d[6-:3] = i_dcd_enc[2:0];
		if (alu_op_wr_en)
			// Trace: idli_decode_m.sv:179:7
			instr_d[3-:2] = alu_op;
		if (op_a_wr_en_wr_en)
			// Trace: idli_decode_m.sv:183:7
			instr_d[1] = op_a_wr_en_;
		if (op_q_wr_en_wr_en)
			// Trace: idli_decode_m.sv:187:7
			instr_d[0] = op_q_wr_en_;
	end
	// Trace: idli_decode_m.sv:192:3
	always @(posedge i_dcd_gck)
		// Trace: idli_decode_m.sv:193:5
		instr_q <= instr_d;
	// Trace: idli_decode_m.sv:200:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:200:15
		op_p_wr_en = (state_q == 4'd0) & i_dcd_enc_vld;
	end
	// Trace: idli_decode_m.sv:206:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:207:5
		case (state_q)
			4'd1, 4'd2:
				// Trace: idli_decode_m.sv:209:27
				op_q_wr_en = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:210:27
				op_q_wr_en = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:215:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:216:5
		case (state_q)
			4'd1, 4'd4, 4'd3:
				// Trace: idli_decode_m.sv:219:31
				op_a_wr_en[1] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:220:31
				op_a_wr_en[1] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:225:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:226:5
		case (state_q)
			4'd5, 4'd9, 4'd8:
				// Trace: idli_decode_m.sv:229:23
				op_a_wr_en[0] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:230:23
				op_a_wr_en[0] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:237:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:238:5
		case (state_q)
			4'd5, 4'd6, 4'd7, 4'd9, 4'd8:
				// Trace: idli_decode_m.sv:243:23
				op_b_wr_en[1] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:244:23
				op_b_wr_en[1] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:249:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:250:5
		case (state_q)
			4'd10, 4'd13, 4'd12:
				// Trace: idli_decode_m.sv:253:29
				op_b_wr_en[0] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:254:29
				op_b_wr_en[0] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:259:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:260:5
		case (state_q)
			4'd11, 4'd10:
				// Trace: idli_decode_m.sv:262:17
				op_c_wr_en = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:263:17
				op_c_wr_en = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:270:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:270:15
		o_dcd_instr = instr_d;
	end
	// Trace: idli_decode_m.sv:273:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:274:5
		case (state_q)
			4'd1: begin
				// Trace: idli_decode_m.sv:277:9
				alu_op = 2'd0;
				// Trace: idli_decode_m.sv:278:9
				alu_op_wr_en = 1'sb1;
			end
			4'd3: begin
				// Trace: idli_decode_m.sv:283:9
				case (i_dcd_enc[3:1])
					3'b110:
						// Trace: idli_decode_m.sv:284:20
						alu_op_wr_en = 1'sb0;
					default:
						// Trace: idli_decode_m.sv:285:20
						alu_op_wr_en = 1'sb1;
				endcase
				casez (i_dcd_enc[3:1])
					3'b01z:
						// Trace: idli_decode_m.sv:289:20
						alu_op = 2'd1;
					3'b100:
						// Trace: idli_decode_m.sv:290:20
						alu_op = 2'd2;
					3'b101:
						// Trace: idli_decode_m.sv:291:20
						alu_op = 2'd3;
					default:
						// Trace: idli_decode_m.sv:292:20
						alu_op = 2'd0;
				endcase
			end
			4'd2: begin
				// Trace: idli_decode_m.sv:298:9
				alu_op = 2'd2;
				// Trace: idli_decode_m.sv:299:9
				alu_op_wr_en = 1'sb1;
			end
			default: begin
				// Trace: idli_decode_m.sv:303:9
				alu_op = 2'bxx;
				// Trace: idli_decode_m.sv:304:9
				alu_op_wr_en = 1'sb0;
			end
		endcase
	end
	// Trace: idli_decode_m.sv:311:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:312:5
		case (state_q)
			4'd1, 4'd3: begin
				// Trace: idli_decode_m.sv:318:9
				op_a_wr_en_ = 1'sb1;
				// Trace: idli_decode_m.sv:319:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			4'd2: begin
				// Trace: idli_decode_m.sv:323:9
				op_a_wr_en_ = 1'sb0;
				// Trace: idli_decode_m.sv:324:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			4'd4: begin
				// Trace: idli_decode_m.sv:328:9
				op_a_wr_en_ = ~i_dcd_enc[2];
				// Trace: idli_decode_m.sv:329:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			4'd13: begin
				// Trace: idli_decode_m.sv:334:9
				op_a_wr_en_ = ~i_dcd_enc[1];
				// Trace: idli_decode_m.sv:335:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			default: begin
				// Trace: idli_decode_m.sv:338:9
				op_a_wr_en_ = 1'sbx;
				// Trace: idli_decode_m.sv:339:9
				op_a_wr_en_wr_en = 1'sb0;
			end
		endcase
	end
	// Trace: idli_decode_m.sv:346:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:347:5
		case (state_q)
			4'd1, 4'd2: begin
				// Trace: idli_decode_m.sv:350:9
				op_q_wr_en_ = ~(i_dcd_enc[3] & i_dcd_enc[0]);
				// Trace: idli_decode_m.sv:351:9
				op_q_wr_en_wr_en = 1'sb1;
			end
			4'd4, 4'd3: begin
				// Trace: idli_decode_m.sv:355:9
				op_q_wr_en_ = 1'sb0;
				// Trace: idli_decode_m.sv:356:9
				op_q_wr_en_wr_en = 1'sb1;
			end
			default: begin
				// Trace: idli_decode_m.sv:359:9
				op_q_wr_en_ = 1'sbx;
				// Trace: idli_decode_m.sv:360:9
				op_q_wr_en_wr_en = 1'sb0;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
