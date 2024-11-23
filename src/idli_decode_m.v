// removed package "idli_pkg"
module idli_decode_m (
	i_dcd_gck,
	i_dcd_rst_n,
	i_dcd_enc,
	i_dcd_enc_vld
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
	// Trace: idli_decode_m.sv:19:3
	// removed localparam type state_t
	// Trace: idli_decode_m.sv:42:3
	reg [3:0] state_q;
	// Trace: idli_decode_m.sv:43:3
	reg [3:0] state_d;
	// Trace: idli_decode_m.sv:47:3
	always @(posedge i_dcd_gck or negedge i_dcd_rst_n)
		// Trace: idli_decode_m.sv:48:5
		if (!i_dcd_rst_n)
			// Trace: idli_decode_m.sv:49:7
			state_q <= 4'd0;
		else
			// Trace: idli_decode_m.sv:51:7
			state_q <= state_d;
	// Trace: idli_decode_m.sv:56:3
	always @(*) begin
		if (_sv2v_0)
			;
		// Trace: idli_decode_m.sv:57:5
		state_d = state_q;
		// Trace: idli_decode_m.sv:59:5
		case (state_q)
			4'd0:
				// Trace: idli_decode_m.sv:64:9
				if (i_dcd_enc_vld)
					// Trace: idli_decode_m.sv:67:11
					case (i_dcd_enc[1:0])
						2'b00:
							// Trace: idli_decode_m.sv:68:22
							state_d = 4'd1;
						2'b01:
							// Trace: idli_decode_m.sv:69:22
							state_d = 4'd2;
						2'b10:
							// Trace: idli_decode_m.sv:70:22
							state_d = 4'd3;
						default:
							// Trace: idli_decode_m.sv:71:22
							state_d = 4'd4;
					endcase
			4'd1, 4'd4:
				// Trace: idli_decode_m.sv:78:9
				state_d = 4'd5;
			4'd2:
				// Trace: idli_decode_m.sv:83:9
				case ({i_dcd_enc[3], i_dcd_enc[0]})
					2'b00:
						// Trace: idli_decode_m.sv:84:20
						state_d = 4'd6;
					2'b01:
						// Trace: idli_decode_m.sv:85:20
						state_d = 4'd7;
					default:
						// Trace: idli_decode_m.sv:86:20
						state_d = 4'd8;
				endcase
			4'd3:
				// Trace: idli_decode_m.sv:92:9
				case (i_dcd_enc[3:1])
					3'b110:
						// Trace: idli_decode_m.sv:93:20
						state_d = 4'd9;
					3'b111:
						// Trace: idli_decode_m.sv:94:20
						state_d = 4'd10;
					default:
						// Trace: idli_decode_m.sv:95:20
						state_d = 4'd5;
				endcase
			4'd5, 4'd6, 4'd7:
				// Trace: idli_decode_m.sv:100:9
				state_d = 4'd11;
			4'd8:
				// Trace: idli_decode_m.sv:104:9
				state_d = 4'd12;
			4'd9:
				// Trace: idli_decode_m.sv:109:9
				state_d = 4'd13;
			4'd10:
				// Trace: idli_decode_m.sv:113:9
				state_d = 4'd14;
			default:
				// Trace: idli_decode_m.sv:117:9
				state_d = 4'd0;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
