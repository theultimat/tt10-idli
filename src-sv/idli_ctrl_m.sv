`include "idli_pkg.svh"

// Generates control signals for the core.
module idli_ctrl_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic        i_ctrl_gck,
  input  var logic        i_ctrl_rst_n,

  // Cycle counter interface.
  output var logic        o_ctrl_ctr_last_cycle,

  // SQI interface.
  output var logic        o_ctrl_sqi_sck,
  output var logic        o_ctrl_sqi_cs,
  output var sqi_mode_t   o_ctrl_sqi_mode,
  output var logic [3:0]  o_ctrl_sqi_data,
  input  var logic        i_ctrl_sqi_rd,
  input  var logic [3:0]  i_ctrl_sqi_data
);

  // {{{ SQI signals

  // States for the SQI state machine. The general process for starting an SQI
  // transaction is:
  //
  // 1. Pull CS high to reset the transaction then pull low to start the new
  //    operation.
  // 2. Send the instruction byte: READ (0x3) or WRITE (0x2).
  // 3. Send the 16b address.
  // 4. Wait for the DUMMY byte to clock out for a READ.
  // 5. Send or receive the data.
  //
  // We keep the DUMMY cycle in WRITE mode as we can use this period to
  // convert the store data order from little to big endian.
  typedef enum logic [1:0] {
    SQI_STATE_INIT,
    SQI_STATE_ADDR,
    SQI_STATE_DUMMY,
    SQI_STATE_DATA
  } sqi_state_t;

  // Current and next state of the SQI FSM.
  sqi_state_t sqi_state_q;
  sqi_state_t sqi_state_d;

  // Shift register for reversing the nibble order from little endian on input
  // to big endian on output.
  logic [15:0] sqi_shift_q;

  // Whether the shift register should be written to on this cycle.
  logic sqi_shift_wr_en_q;

  // }}} SQI signals


  // {{{ Cycle counter signals

  // Internal cycle counter. The core is 4b serial so each 16b operation takes
  // a multiple of four cycles to complete.
  logic [1:0] ctr_q;
  logic [1:0] ctr_d;

  // }}} Cycle counter signals


  // {{{ SQI logic

  // Latch the new state of the FSM on the final cycle of the period, or reset
  // back to INIT.
  always_ff @(posedge i_ctrl_gck, negedge i_ctrl_rst_n) begin
    if (!i_ctrl_rst_n) begin
      sqi_state_q <= SQI_STATE_INIT;
    end else if (o_ctrl_ctr_last_cycle) begin
      sqi_state_q <= sqi_state_d;
    end
  end

  // Determine the next state for the FSM.
  always_comb begin
    sqi_state_d = sqi_state_q;

    case (sqi_state_q)
      SQI_STATE_INIT: begin
        // After INIT we always need to move to ADDR. During INIT the address
        // will be reversed into big-endian.
        sqi_state_d = SQI_STATE_ADDR;
      end
      SQI_STATE_ADDR: begin
        // After address we always have a dummy cycle. The SQI memory doesn't
        // need a dummy cycle for writing but we use it here to correctly
        // reverse the store data.
        sqi_state_d = SQI_STATE_DUMMY;
      end
      SQI_STATE_DUMMY: begin
        // Once we've waited for the dummy cycle move straight to DATA.
        sqi_state_d = SQI_STATE_DATA;
      end
      default: begin // SQI_STATE_DATA
        // Stay in the DATA state until a redirect request happens.
        // TODO
      end
    endcase
  end

  // CS needs to be set high during the first two cycles of INIT after which
  // we pull low and keep low until the next INIT stage.
  always_comb o_ctrl_sqi_cs = (sqi_state_q == SQI_STATE_INIT) & ~ctr_q[1];

  // SCK should be active for every cycle except during DUMMY. When in READ we
  // need to clock out a dummy byte and so must be active for two of the four
  // cycles. For WRITE the memory can accept input immediately so don't clock
  // the memory at all.
  always_comb begin
    o_ctrl_sqi_sck = i_ctrl_gck;

    if ((sqi_state_q == SQI_STATE_DUMMY) & ~(i_ctrl_sqi_rd & ctr_q[1])) begin
      o_ctrl_sqi_sck = '0;
    end
  end

  // Latch the shift write signal. This is reset to 1 to ensure we perform an
  // initial latch of the PC to initiate the starting fetch. A new value only
  // needs to be flopped on the final cycle of each period.
  always_ff @(posedge i_ctrl_gck, negedge i_ctrl_rst_n) begin
    if (!i_ctrl_rst_n) begin
      sqi_shift_wr_en_q <= '1;
    end else if (o_ctrl_ctr_last_cycle) begin
      // TODO Need to write on address change e.g. LD/ST or PC redirect.
      sqi_shift_wr_en_q <= '0;
    end
  end

  // Shift register performs the shift on every cycle. If write enable is set
  // new data is written in little endian order, otherwise data is rotated out
  // in big endian order.
  always_ff @(posedge i_ctrl_gck) begin
    if (sqi_shift_wr_en_q) begin
      sqi_shift_q <= {i_ctrl_sqi_data, sqi_shift_q[15:4]};
    end else begin
      sqi_shift_q <= {sqi_shift_q[11:0], sqi_shift_q[15:12]};
    end
  end

  // Output data depends on the state and the current cycle within the period.
  always_comb begin
    o_ctrl_sqi_data = 'x;

    case (sqi_state_q)
      SQI_STATE_INIT: begin
        // On the final two cycles of INIT transmit the instruction.
        if (ctr_q[1]) begin
          o_ctrl_sqi_data = ctr_q[0] ? {3'b001, i_ctrl_sqi_rd} : '0;
        end
      end
      SQI_STATE_ADDR: begin
        // Read the top byte out of the shift register for the address.
        o_ctrl_sqi_data = sqi_shift_q[15:12];
      end
      SQI_STATE_DATA: begin
        // Read top byte from shift register if this is a write operation.
        if (!i_ctrl_sqi_rd) begin
          o_ctrl_sqi_data = sqi_shift_q[15:12];
        end
      end
      default: begin
        o_ctrl_sqi_data = 'x;
      end
    endcase
  end

  // Current mode of the pins depends on the state. We should be transmitting
  // data to the memory in every cycle except when data is actively being
  // read.
  always_comb begin
    o_ctrl_sqi_mode = SQI_MODE_OUT;

    if ((sqi_state_q == SQI_STATE_DATA) & i_ctrl_sqi_rd) begin
      o_ctrl_sqi_mode = SQI_MODE_IN;
    end
  end

  // }}} SQI logic


  // {{{ Cycle counter logic

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

  // }}} Cycle counter logic

endmodule
