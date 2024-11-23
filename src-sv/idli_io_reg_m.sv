`include "idli_pkg.svh"

// IO Register module is used to interface with the SQI memory. The memory
// expects data in big endian, but internally we process in little endian, so
// we need to be able to write in one direction and read out in the other.
module idli_io_reg_m import idli_pkg::*; (
  // Clock - no reset required.
  input  var logic        i_reg_gck,

  // Data interface - input, output, and whether writing is enabled.
  input  var logic [3:0]  i_reg_data,
  input  var logic        i_reg_wr_en,
  output var logic [3:0]  o_reg_data
);

  // Internally store 16b of data.
  logic [15:0] data_q;


  // The register shifts 4b every cycle, with the direction depending on
  // whether write enable is set.
  always_ff @(posedge i_reg_gck) begin
    if (i_reg_wr_en) begin
      data_q <= {i_reg_data, data_q[15:4]};
    end else begin
      data_q <= {data_q[11:0], data_q[15:12]};
    end
  end

  // Output the top of the register - whether this is the first or last nibble
  // depends on whether the data was written in big or little endian.
  always_comb o_reg_data = data_q[15:12];

endmodule
