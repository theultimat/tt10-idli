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
	output reg [17:0] o_dcd_instr;
	// Trace: idli_decode_m.sv:22:3
	// removed localparam type state_t
	// Trace: idli_decode_m.sv:44:3
	reg [3:0] state_q;
	// Trace: idli_decode_m.sv:45:3
	reg [3:0] state_d;
	// Trace: idli_decode_m.sv:48:3
	reg [17:0] instr_q;
	// Trace: idli_decode_m.sv:49:3
	reg [17:0] instr_d;
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
	// Trace: idli_decode_m.sv:73:3
	reg op_c_imm;
	// Trace: idli_decode_m.sv:77:3
	always @(posedge i_dcd_gck or negedge i_dcd_rst_n)
		// Trace: idli_decode_m.sv:78:5
		if (!i_dcd_rst_n)
			// Trace: idli_decode_m.sv:79:7
			state_q <= 4'd0;
		else
			// Trace: idli_decode_m.sv:81:7
			state_q <= state_d;
	// Trace: idli_decode_m.sv:86:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:87:5
		state_d = state_q;
		// Trace: idli_decode_m.sv:89:5
		case (state_q)
			4'd0:
				// Trace: idli_decode_m.sv:94:9
				if (i_dcd_enc_vld)
					// Trace: idli_decode_m.sv:97:11
					case (i_dcd_enc[1:0])
						2'b00:
							// Trace: idli_decode_m.sv:98:22
							state_d = 4'd1;
						2'b01:
							// Trace: idli_decode_m.sv:99:22
							state_d = 4'd2;
						2'b10:
							// Trace: idli_decode_m.sv:100:22
							state_d = 4'd3;
						default:
							// Trace: idli_decode_m.sv:101:22
							state_d = 4'd4;
					endcase
			4'd1, 4'd4:
				// Trace: idli_decode_m.sv:108:9
				state_d = 4'd5;
			4'd2:
				// Trace: idli_decode_m.sv:115:9
				case ({i_dcd_enc[3], i_dcd_enc[0]})
					2'b00:
						// Trace: idli_decode_m.sv:116:20
						state_d = 4'd6;
					default:
						// Trace: idli_decode_m.sv:117:20
						state_d = 4'd7;
				endcase
			4'd3:
				// Trace: idli_decode_m.sv:123:9
				case (i_dcd_enc[3:1])
					3'b110:
						// Trace: idli_decode_m.sv:124:20
						state_d = 4'd8;
					3'b111:
						// Trace: idli_decode_m.sv:125:20
						state_d = 4'd9;
					default:
						// Trace: idli_decode_m.sv:126:20
						state_d = 4'd5;
				endcase
			4'd5, 4'd6, 4'd7:
				// Trace: idli_decode_m.sv:131:9
				state_d = 4'd10;
			4'd8:
				// Trace: idli_decode_m.sv:136:9
				state_d = 4'd12;
			4'd9:
				// Trace: idli_decode_m.sv:140:9
				state_d = 4'd13;
			default:
				// Trace: idli_decode_m.sv:144:9
				state_d = 4'd0;
		endcase
	end
	// Trace: idli_decode_m.sv:150:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:151:5
		instr_d = instr_q;
		// Trace: idli_decode_m.sv:153:5
		if (op_p_wr_en)
			// Trace: idli_decode_m.sv:154:7
			instr_d[17-:2] = i_dcd_enc[3:2];
		if (op_q_wr_en)
			// Trace: idli_decode_m.sv:158:7
			instr_d[15-:2] = i_dcd_enc[2:1];
		if (op_a_wr_en[0])
			// Trace: idli_decode_m.sv:162:7
			instr_d[12:11] = i_dcd_enc[3:2];
		if (op_a_wr_en[1])
			// Trace: idli_decode_m.sv:166:7
			instr_d[13] = i_dcd_enc[0];
		if (op_b_wr_en[0])
			// Trace: idli_decode_m.sv:170:7
			instr_d[8] = i_dcd_enc[3];
		if (op_b_wr_en[1])
			// Trace: idli_decode_m.sv:174:7
			instr_d[10:9] = i_dcd_enc[1:0];
		if (op_c_wr_en) begin
			// Trace: idli_decode_m.sv:178:7
			instr_d[7-:3] = i_dcd_enc[2:0];
			// Trace: idli_decode_m.sv:179:7
			instr_d[0] = op_c_imm;
		end
		if (alu_op_wr_en)
			// Trace: idli_decode_m.sv:183:7
			instr_d[4-:2] = alu_op;
		if (op_a_wr_en_wr_en)
			// Trace: idli_decode_m.sv:187:7
			instr_d[2] = op_a_wr_en_;
		if (op_q_wr_en_wr_en)
			// Trace: idli_decode_m.sv:191:7
			instr_d[1] = op_q_wr_en_;
	end
	// Trace: idli_decode_m.sv:196:3
	always @(posedge i_dcd_gck)
		// Trace: idli_decode_m.sv:197:5
		instr_q <= instr_d;
	// Trace: idli_decode_m.sv:204:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:204:15
		op_p_wr_en = (state_q == 4'd0) & i_dcd_enc_vld;
	end
	// Trace: idli_decode_m.sv:210:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:211:5
		case (state_q)
			4'd1, 4'd2:
				// Trace: idli_decode_m.sv:213:27
				op_q_wr_en = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:214:27
				op_q_wr_en = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:219:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:220:5
		case (state_q)
			4'd1, 4'd4, 4'd3:
				// Trace: idli_decode_m.sv:223:31
				op_a_wr_en[1] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:224:31
				op_a_wr_en[1] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:229:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:230:5
		case (state_q)
			4'd5, 4'd9, 4'd8:
				// Trace: idli_decode_m.sv:233:23
				op_a_wr_en[0] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:234:23
				op_a_wr_en[0] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:241:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:242:5
		case (state_q)
			4'd5, 4'd6, 4'd7, 4'd9, 4'd8:
				// Trace: idli_decode_m.sv:247:23
				op_b_wr_en[1] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:248:23
				op_b_wr_en[1] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:253:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:254:5
		case (state_q)
			4'd10, 4'd13, 4'd12:
				// Trace: idli_decode_m.sv:257:29
				op_b_wr_en[0] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:258:29
				op_b_wr_en[0] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:263:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:264:5
		case (state_q)
			4'd11, 4'd10:
				// Trace: idli_decode_m.sv:266:17
				op_c_wr_en = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:267:17
				op_c_wr_en = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:274:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:274:15
		o_dcd_instr = instr_d;
	end
	// Trace: idli_decode_m.sv:277:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:278:5
		case (state_q)
			4'd1: begin
				// Trace: idli_decode_m.sv:281:9
				alu_op = 2'd0;
				// Trace: idli_decode_m.sv:282:9
				alu_op_wr_en = 1'sb1;
			end
			4'd3: begin
				// Trace: idli_decode_m.sv:287:9
				case (i_dcd_enc[3:1])
					3'b110:
						// Trace: idli_decode_m.sv:288:20
						alu_op_wr_en = 1'sb0;
					default:
						// Trace: idli_decode_m.sv:289:20
						alu_op_wr_en = 1'sb1;
				endcase
				casez (i_dcd_enc[3:1])
					3'b01z:
						// Trace: idli_decode_m.sv:293:20
						alu_op = 2'd1;
					3'b100:
						// Trace: idli_decode_m.sv:294:20
						alu_op = 2'd2;
					3'b101:
						// Trace: idli_decode_m.sv:295:20
						alu_op = 2'd3;
					default:
						// Trace: idli_decode_m.sv:296:20
						alu_op = 2'd0;
				endcase
			end
			4'd2: begin
				// Trace: idli_decode_m.sv:302:9
				alu_op = 2'd2;
				// Trace: idli_decode_m.sv:303:9
				alu_op_wr_en = 1'sb1;
			end
			default: begin
				// Trace: idli_decode_m.sv:307:9
				alu_op = 2'bxx;
				// Trace: idli_decode_m.sv:308:9
				alu_op_wr_en = 1'sb0;
			end
		endcase
	end
	// Trace: idli_decode_m.sv:315:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:316:5
		case (state_q)
			4'd1, 4'd3: begin
				// Trace: idli_decode_m.sv:322:9
				op_a_wr_en_ = 1'sb1;
				// Trace: idli_decode_m.sv:323:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			4'd2: begin
				// Trace: idli_decode_m.sv:327:9
				op_a_wr_en_ = 1'sb0;
				// Trace: idli_decode_m.sv:328:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			4'd4: begin
				// Trace: idli_decode_m.sv:332:9
				op_a_wr_en_ = ~i_dcd_enc[2];
				// Trace: idli_decode_m.sv:333:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			4'd13: begin
				// Trace: idli_decode_m.sv:338:9
				op_a_wr_en_ = ~i_dcd_enc[1];
				// Trace: idli_decode_m.sv:339:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			default: begin
				// Trace: idli_decode_m.sv:342:9
				op_a_wr_en_ = 1'sbx;
				// Trace: idli_decode_m.sv:343:9
				op_a_wr_en_wr_en = 1'sb0;
			end
		endcase
	end
	// Trace: idli_decode_m.sv:350:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:351:5
		case (state_q)
			4'd1, 4'd2: begin
				// Trace: idli_decode_m.sv:354:9
				op_q_wr_en_ = ~(i_dcd_enc[3] & i_dcd_enc[0]);
				// Trace: idli_decode_m.sv:355:9
				op_q_wr_en_wr_en = 1'sb1;
			end
			4'd4, 4'd3: begin
				// Trace: idli_decode_m.sv:359:9
				op_q_wr_en_ = 1'sb0;
				// Trace: idli_decode_m.sv:360:9
				op_q_wr_en_wr_en = 1'sb1;
			end
			default: begin
				// Trace: idli_decode_m.sv:363:9
				op_q_wr_en_ = 1'sbx;
				// Trace: idli_decode_m.sv:364:9
				op_q_wr_en_wr_en = 1'sb0;
			end
		endcase
	end
	// Trace: idli_decode_m.sv:371:3
	localparam [2:0] idli_pkg_GREG_PC = 3'b111;
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:371:15
		op_c_imm = i_dcd_enc[2:0] == idli_pkg_GREG_PC;
	end
	initial _sv2v_0 = 0;
endmodule
