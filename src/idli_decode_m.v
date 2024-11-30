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
	output reg [15:0] o_dcd_instr;
	// Trace: idli_decode_m.sv:22:3
	// removed localparam type state_t
	// Trace: idli_decode_m.sv:45:3
	reg [3:0] state_q;
	// Trace: idli_decode_m.sv:46:3
	reg [3:0] state_d;
	// Trace: idli_decode_m.sv:49:3
	reg [15:0] instr_q;
	// Trace: idli_decode_m.sv:50:3
	reg [15:0] instr_d;
	// Trace: idli_decode_m.sv:56:3
	reg op_p_wr_en;
	// Trace: idli_decode_m.sv:57:3
	reg op_q_wr_en;
	// Trace: idli_decode_m.sv:58:3
	reg [1:0] op_a_wr_en;
	// Trace: idli_decode_m.sv:59:3
	reg [1:0] op_b_wr_en;
	// Trace: idli_decode_m.sv:60:3
	reg op_c_wr_en;
	// Trace: idli_decode_m.sv:63:3
	reg [1:0] alu_op;
	// Trace: idli_decode_m.sv:64:3
	reg alu_op_wr_en;
	// Trace: idli_decode_m.sv:68:3
	reg op_a_wr_en_;
	// Trace: idli_decode_m.sv:69:3
	reg op_a_wr_en_wr_en;
	// Trace: idli_decode_m.sv:73:3
	always @(posedge i_dcd_gck or negedge i_dcd_rst_n)
		// Trace: idli_decode_m.sv:74:5
		if (!i_dcd_rst_n)
			// Trace: idli_decode_m.sv:75:7
			state_q <= 4'd0;
		else
			// Trace: idli_decode_m.sv:77:7
			state_q <= state_d;
	// Trace: idli_decode_m.sv:82:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:83:5
		state_d = state_q;
		// Trace: idli_decode_m.sv:85:5
		case (state_q)
			4'd0:
				// Trace: idli_decode_m.sv:90:9
				if (i_dcd_enc_vld)
					// Trace: idli_decode_m.sv:93:11
					case (i_dcd_enc[1:0])
						2'b00:
							// Trace: idli_decode_m.sv:94:22
							state_d = 4'd1;
						2'b01:
							// Trace: idli_decode_m.sv:95:22
							state_d = 4'd2;
						2'b10:
							// Trace: idli_decode_m.sv:96:22
							state_d = 4'd3;
						default:
							// Trace: idli_decode_m.sv:97:22
							state_d = 4'd4;
					endcase
			4'd1, 4'd4:
				// Trace: idli_decode_m.sv:104:9
				state_d = 4'd5;
			4'd2:
				// Trace: idli_decode_m.sv:109:9
				case ({i_dcd_enc[3], i_dcd_enc[0]})
					2'b00:
						// Trace: idli_decode_m.sv:110:20
						state_d = 4'd6;
					2'b01:
						// Trace: idli_decode_m.sv:111:20
						state_d = 4'd7;
					default:
						// Trace: idli_decode_m.sv:112:20
						state_d = 4'd8;
				endcase
			4'd3:
				// Trace: idli_decode_m.sv:118:9
				case (i_dcd_enc[3:1])
					3'b110:
						// Trace: idli_decode_m.sv:119:20
						state_d = 4'd9;
					3'b111:
						// Trace: idli_decode_m.sv:120:20
						state_d = 4'd10;
					default:
						// Trace: idli_decode_m.sv:121:20
						state_d = 4'd5;
				endcase
			4'd5, 4'd6, 4'd7:
				// Trace: idli_decode_m.sv:126:9
				state_d = 4'd11;
			4'd8:
				// Trace: idli_decode_m.sv:130:9
				state_d = 4'd12;
			4'd9:
				// Trace: idli_decode_m.sv:135:9
				state_d = 4'd13;
			4'd10:
				// Trace: idli_decode_m.sv:139:9
				state_d = 4'd14;
			default:
				// Trace: idli_decode_m.sv:143:9
				state_d = 4'd0;
		endcase
	end
	// Trace: idli_decode_m.sv:149:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:150:5
		instr_d = instr_q;
		// Trace: idli_decode_m.sv:152:5
		if (op_p_wr_en)
			// Trace: idli_decode_m.sv:153:7
			instr_d[15-:2] = i_dcd_enc[3:2];
		if (op_q_wr_en)
			// Trace: idli_decode_m.sv:157:7
			instr_d[13-:2] = i_dcd_enc[2:1];
		if (op_a_wr_en[0])
			// Trace: idli_decode_m.sv:161:7
			instr_d[10:9] = i_dcd_enc[3:2];
		if (op_a_wr_en[1])
			// Trace: idli_decode_m.sv:165:7
			instr_d[11] = i_dcd_enc[0];
		if (op_b_wr_en[0])
			// Trace: idli_decode_m.sv:169:7
			instr_d[6] = i_dcd_enc[3];
		if (op_b_wr_en[1])
			// Trace: idli_decode_m.sv:173:7
			instr_d[8:7] = i_dcd_enc[1:0];
		if (op_c_wr_en)
			// Trace: idli_decode_m.sv:177:7
			instr_d[5-:3] = i_dcd_enc[2:0];
		if (alu_op_wr_en)
			// Trace: idli_decode_m.sv:181:7
			instr_d[2-:2] = alu_op;
		if (op_a_wr_en_wr_en)
			// Trace: idli_decode_m.sv:185:7
			instr_d[0] = op_a_wr_en_;
	end
	// Trace: idli_decode_m.sv:190:3
	always @(posedge i_dcd_gck)
		// Trace: idli_decode_m.sv:191:5
		instr_q <= instr_d;
	// Trace: idli_decode_m.sv:198:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:198:15
		op_p_wr_en = (state_q == 4'd0) & i_dcd_enc_vld;
	end
	// Trace: idli_decode_m.sv:204:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:205:5
		case (state_q)
			4'd1, 4'd2:
				// Trace: idli_decode_m.sv:207:27
				op_q_wr_en = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:208:27
				op_q_wr_en = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:213:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:214:5
		case (state_q)
			4'd1, 4'd4, 4'd3:
				// Trace: idli_decode_m.sv:217:31
				op_a_wr_en[1] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:218:31
				op_a_wr_en[1] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:223:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:224:5
		case (state_q)
			4'd5, 4'd10, 4'd9:
				// Trace: idli_decode_m.sv:227:23
				op_a_wr_en[0] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:228:23
				op_a_wr_en[0] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:235:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:236:5
		case (state_q)
			4'd5, 4'd6, 4'd7, 4'd10, 4'd9:
				// Trace: idli_decode_m.sv:241:23
				op_b_wr_en[1] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:242:23
				op_b_wr_en[1] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:247:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:248:5
		case (state_q)
			4'd11, 4'd14, 4'd13:
				// Trace: idli_decode_m.sv:251:29
				op_b_wr_en[0] = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:252:29
				op_b_wr_en[0] = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:257:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:258:5
		case (state_q)
			4'd12, 4'd11:
				// Trace: idli_decode_m.sv:260:17
				op_c_wr_en = 1'sb1;
			default:
				// Trace: idli_decode_m.sv:261:17
				op_c_wr_en = 1'sb0;
		endcase
	end
	// Trace: idli_decode_m.sv:268:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:268:15
		o_dcd_instr = instr_d;
	end
	// Trace: idli_decode_m.sv:271:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:272:5
		case (state_q)
			4'd1: begin
				// Trace: idli_decode_m.sv:275:9
				alu_op = 2'd0;
				// Trace: idli_decode_m.sv:276:9
				alu_op_wr_en = 1'sb1;
			end
			4'd3: begin
				// Trace: idli_decode_m.sv:281:9
				case (i_dcd_enc[3:1])
					3'b110:
						// Trace: idli_decode_m.sv:282:20
						alu_op_wr_en = 1'sb0;
					default:
						// Trace: idli_decode_m.sv:283:20
						alu_op_wr_en = 1'sb1;
				endcase
				casez (i_dcd_enc[3:1])
					3'b01z:
						// Trace: idli_decode_m.sv:287:20
						alu_op = 2'd1;
					3'b100:
						// Trace: idli_decode_m.sv:288:20
						alu_op = 2'd2;
					3'b101:
						// Trace: idli_decode_m.sv:289:20
						alu_op = 2'd3;
					default:
						// Trace: idli_decode_m.sv:290:20
						alu_op = 2'd0;
				endcase
			end
			default: begin
				// Trace: idli_decode_m.sv:295:9
				alu_op = 2'bxx;
				// Trace: idli_decode_m.sv:296:9
				alu_op_wr_en = 1'sb0;
			end
		endcase
	end
	// Trace: idli_decode_m.sv:303:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:304:5
		case (state_q)
			4'd1, 4'd3: begin
				// Trace: idli_decode_m.sv:310:9
				op_a_wr_en_ = 1'sb1;
				// Trace: idli_decode_m.sv:311:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			4'd2: begin
				// Trace: idli_decode_m.sv:315:9
				op_a_wr_en_ = 1'sb0;
				// Trace: idli_decode_m.sv:316:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			4'd4: begin
				// Trace: idli_decode_m.sv:320:9
				op_a_wr_en_ = ~i_dcd_enc[2];
				// Trace: idli_decode_m.sv:321:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			4'd14: begin
				// Trace: idli_decode_m.sv:326:9
				op_a_wr_en_ = ~i_dcd_enc[1];
				// Trace: idli_decode_m.sv:327:9
				op_a_wr_en_wr_en = 1'sb1;
			end
			default: begin
				// Trace: idli_decode_m.sv:330:9
				op_a_wr_en_ = 1'sb0;
				// Trace: idli_decode_m.sv:331:9
				op_a_wr_en_wr_en = 1'sb0;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
