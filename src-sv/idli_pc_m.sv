`include "idli_pkg.svh"

// Holds the program counter and determines the new value to latch. Each cycle
// we can update 4b of the program counter.
module idli_pc_m (
  // Clock and reset.
  input  var logic        i_pc_gck,
  input  var logic        i_pc_rst_n,

  // Cycle counter interface.
  input  var logic        i_pc_ctr_last_cycle,

  // Flopped value of the PC.
  output var logic [3:0]  o_pc_q
);

  // Current and next value of the PC. As we only process 4b per cycle we
  // don't need a full 16b for _d.
  logic [15:0] pc_q;
  logic [ 3:0] pc_d;

  // Value to increment the PC by this cycle. This is 2 on the first cycle or
  // the carry out of the previous cycle's addition.
  logic [1:0] inc_q;
  logic [1:0] inc_d;


  // Latch the new values or reset back to zero.
  always_ff @(posedge i_pc_gck, negedge i_pc_rst_n) begin
    if (!i_pc_rst_n) begin
      pc_q  <= '0;
      inc_q <= 2'd2;
    end else begin
      pc_q  <= {pc_d, pc_q[15:4]};
      inc_q <= inc_d;
    end
  end

  // Perform the increment and calculate the increment amount on the following
  // cycle. This will be 2 for the first cycle of the increment or the carry
  // out of the previous cycle.
  always_comb begin
    inc_d = '0;
    {inc_d[0], pc_d} = pc_q[3:0] + {2'b0, inc_q};

    if (i_pc_ctr_last_cycle) begin
      inc_d = 2'd2;
    end
  end

  // Output the latched slice of the PC.
  always_comb o_pc_q = pc_q[3:0];

endmodule
