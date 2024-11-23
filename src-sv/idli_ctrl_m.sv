`include "idli_pkg.svh"

// Generates control signals for the core.
module idli_ctrl_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic        i_ctrl_gck,
  input  var logic        i_ctrl_rst_n,

  // Cycle counter interface.
  output var logic [1:0]  o_ctrl_ctr,
  output var logic        o_ctrl_ctr_last_cycle,

  // SQI control signals.
  output var logic        o_ctrl_sqi_redirect,

  // Decode control signals.
  output var logic        o_ctrl_dcd_enc_vld
);

  // The control unit has a state machine that directs the rest of the core
  // based on the current state:
  //
  // PC_REDIRECT_0  The next instruction to leave decode will write to the PC,
  //                so we need to start writing the new fetch address to the
  //                SQI memory.
  //
  // PC_REDIRECT_?  Wait for the redirect to complete and new read data to
  //                become available.
  //
  // STEADY         Core is in a steady state.
  typedef enum logic [2:0] {
    STATE_PC_REDIRECT_0,
    STATE_PC_REDIRECT_1,
    STATE_PC_REDIRECT_2,
    STATE_PC_REDIRECT_3,
    STATE_STEADY
  } state_t;

  // Current and next state.
  state_t state_q;
  state_t state_d;

  // Internal cycle counter. The core is 4b serial so each 16b operation takes
  // a multiple of four cycles to complete.
  logic [1:0] ctr_q;
  logic [1:0] ctr_d;


  // Latch the new cycle counter every cycle or reset back to zero.
  always_ff @(posedge i_ctrl_gck, negedge i_ctrl_rst_n) begin
    if (!i_ctrl_rst_n) begin
      ctr_q <= '0;
    end else begin
      ctr_q <= ctr_d;
    end
  end

  // Counter advances every cycle.
  always_comb ctr_d = ctr_q + 2'd1;

  // Some events only trigger on the transition between first and last cycle
  // i.e. when the counter wraps.
  always_comb o_ctrl_ctr_last_cycle = ctr_q == 2'd3;

  // Make current value of the counter externally visible.
  always_comb o_ctrl_ctr = ctr_q;


  // Determine the next state.
  always_comb begin
    state_d = state_q;

    case (state_q)
      STATE_PC_REDIRECT_0: begin
        // Move to the next PC wait state.
        state_d = STATE_PC_REDIRECT_1;
      end
      STATE_PC_REDIRECT_1: begin
        // Move to the next PC wait state.
        state_d = STATE_PC_REDIRECT_2;
      end
      STATE_PC_REDIRECT_2: begin
        // Move to the next PC wait state.
        state_d = STATE_PC_REDIRECT_3;
      end
      STATE_PC_REDIRECT_3: begin
        // Move to the steady state.
        state_d = STATE_STEADY;
      end
      default: begin
        // TODO
      end
    endcase
  end

  // Latch new state on final cycle of counter.
  always_ff @(posedge i_ctrl_gck, negedge i_ctrl_rst_n) begin
    if (!i_ctrl_rst_n) begin
      state_q <= STATE_PC_REDIRECT_0;
    end else if (o_ctrl_ctr_last_cycle) begin
      state_q <= state_d;
    end
  end

  // Output the redirect signal when we're in the first PC redirect state.
  always_comb o_ctrl_sqi_redirect = state_q == STATE_PC_REDIRECT_0;

  // Encoding is valid for the decoder if we're in the steady state and
  // therefore have instruction data ready to go.
  always_comb o_ctrl_dcd_enc_vld = state_q == STATE_STEADY;

endmodule
