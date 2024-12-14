`include "idli_pkg.svh"

// Controller for the SQI memory. This handles sending instructions, addresses,
// etc. to the memory and handles data ordering restrictions.
module idli_sqi_ctrl_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic          i_sqi_gck,
  input  var logic          i_sqi_rst_n,

  // Main control interface.
  input  var logic [1:0]    i_sqi_ctr,
  input  var logic          i_sqi_ctr_last_cycle,
  input  var logic          i_sqi_redirect,
  input  var logic          i_sqi_rd,

  // SQI memory interface.
  output var logic          o_sqi_sck,
  output var logic          o_sqi_cs,
  output var sqi_mode_t     o_sqi_mode,
  input  var logic [3:0]    i_sqi_rd_data,
  output var logic [3:0]    o_sqi_rd_data,
  output var logic [3:0]    o_sqi_wr_data,
  input  var logic [3:0]    i_sqi_wr_data,
  input  var logic          i_sqi_wr_data_vld
);

  // SQI state machine goes through the required steps to initialise and
  // maintain a transaction with the external memory. The general process to
  // read or write memory is as follows:
  //
  // 1. Pull CS high to reset the transaction, then pull low to start again.
  // 2. Send the instruction byte: READ (0x3) or WRITE (0x2).
  // 3. Send the 16b address.
  // 4. Wait for the DUMMY byte to clock out for a READ.
  // 5. Read or write the data.
  //
  // We also perfom a DUMMY cycle in write mode as this keeps the logic less
  // complex - we simply don't clock the memory during this period.
  //
  // All data to and from the memory is performed in big endian, and as the
  // core operates internally in little endian the order must be reversed.
  typedef enum logic [1:0] {
    STATE_INIT,
    STATE_ADDR,
    STATE_DUMMY,
    STATE_DATA
  } state_t;

  // Current and next state of the FSM.
  state_t state_q;
  state_t state_d;

  // Data read out of the address/data register and whether the register is
  // currently being written to.
  logic [3:0] wr_reg_data;
  logic       wr_reg_data_wr_en;

  // Data read out of memory registers and write enables.
  logic [3:0] mem_reg_data  [2];
  logic       mem_reg_wr_en [2];

  // Which of the memory reigsters is currently active.
  logic active_mem_reg_q;
  logic active_mem_reg_d;


  // Address and data IO register. Data is written by the core into this in LE
  // and is read out to be transmitted to the memory in BE.
  idli_io_reg_m wr_reg_u (
    .i_reg_gck    (i_sqi_gck),

    .i_reg_data   (i_sqi_wr_data),
    .i_reg_wr_en  (wr_reg_data_wr_en),
    .o_reg_data   (wr_reg_data)
  );

  // Memory input data IO register. Data is written into this register in BE
  // by the SQI memory and read out by the core. Note that we have two
  // registers for this purpose such that we can read out of one while writing
  // into the other.
  for (genvar REG = 0; REG < 2; REG++) begin : num_mem_regs_b
    idli_io_reg_m mem_reg_u (
      .i_reg_gck    (i_sqi_gck),

      .i_reg_data   (i_sqi_rd_data),
      .i_reg_wr_en  (mem_reg_wr_en[REG]),
      .o_reg_data   (mem_reg_data [REG])
    );
  end : num_mem_regs_b


  // Latch the new state of the FSM if this is the final cycle of each 16b
  // period, or reset back to INIT.
  always_ff @(posedge i_sqi_gck, negedge i_sqi_rst_n) begin
    if (!i_sqi_rst_n) begin
      state_q <= STATE_INIT;
    end else if (i_sqi_ctr_last_cycle) begin
      state_q <= state_d;
    end
  end

  // Determine which state ot move to next. Once we're in the DATA state we
  // stay here until a redirect request arrives.
  always_comb begin
    case (state_q)
      STATE_INIT:  state_d = STATE_ADDR;
      STATE_ADDR:  state_d = STATE_DUMMY;
      STATE_DUMMY: state_d = STATE_DATA;
      default:     state_d = i_sqi_redirect ? STATE_INIT : STATE_DATA;
    endcase
  end

  // SCK should be active for every cycle except during DUMMY. When in READ we
  // need to clock out a dummy byte, so SCK should only be active for 2 cycles
  // of the 4 cycle period, and when in WRITE we don't clock at all as data
  // can be immediately presented to the memory.
  always_comb begin
    o_sqi_sck = i_sqi_gck;

    if ((state_q == STATE_DUMMY) & ~(i_sqi_rd & i_sqi_ctr[1])) begin
      o_sqi_sck = '0;
    end
  end

  // CS is set high during the first two cycles of INIT after which it remains
  // low until the next INIT.
  always_comb o_sqi_cs = (state_q == STATE_INIT) & ~i_sqi_ctr[1];

  // Set the output data to be sent to the memory on this cycle.
  always_comb begin
    o_sqi_wr_data = 'x;

    if ((state_q == STATE_INIT) & i_sqi_ctr[1]) begin
      // Transmit the instruction in the final two INIT cycles.
      o_sqi_wr_data = i_sqi_ctr[0] ? {3'b001, i_sqi_rd} : '0;
    end else if ((state_q == STATE_ADDR) | ((state_q == STATE_DATA) & ~i_sqi_rd)) begin
      // Set the address of the output data when writing.
      o_sqi_wr_data = wr_reg_data;
    end
  end

  // Whether the IO pins are inputs or outputs depends on the state. We always
  // transmit data to the memory during INIT and ADDR, and transmit data in
  // DATA if we're writing. We don't care about the data during DUMMY so just
  // ignore it.
  always_comb o_sqi_mode = ((state_q == STATE_DATA) & i_sqi_rd) ? SQI_MODE_IN : SQI_MODE_OUT;

  // We want to be writing into the address/data out register when we're in
  // INIT or DUMMY. During INIT the address is being written into the register
  // to be read out during ADDR, and during DUMMY write data is being written
  // into the buffer to be read out during DATA.
  always_comb wr_reg_data_wr_en = (state_q == STATE_INIT) | (state_q == STATE_DUMMY);

  // Flop the new value for the active memory register.
  always_ff @(posedge i_sqi_gck, negedge i_sqi_rst_n) begin
    if (!i_sqi_rst_n) begin
      active_mem_reg_q <= '0;
    end else if (i_sqi_ctr_last_cycle) begin
      active_mem_reg_q <= active_mem_reg_d;
    end
  end

  // We alternate which memory register is active on each four cycle period.
  // We also ensure we don't flip the _d until the last cycle so we can use it
  // for controlling the write/read enables.
  always_comb begin
    if (i_sqi_ctr_last_cycle) begin
      active_mem_reg_d = ~active_mem_reg_q;
    end else begin
      active_mem_reg_d = active_mem_reg_q;
    end
  end

  // Set write enable for the registers such that only one of the two is
  // active at a time. Note we use the _d here as we need to know what will
  // happen next cycle so we're ready to flop on the rising edge.
  always_comb mem_reg_wr_en[0] = ~active_mem_reg_d;
  always_comb mem_reg_wr_en[1] =  active_mem_reg_d;

  // Route the data read from the memory out to the rest of core. This will be
  // read from whichever register isn't currently being written to and was
  // therefore written to on the previous four cycle period.
  always_comb o_sqi_rd_data = mem_reg_data[~active_mem_reg_q];

endmodule
