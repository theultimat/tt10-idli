`ifndef idli_pkg_svh_d
`define idli_pkg_svh_d

package idli_pkg;

// Whether the IO pins on the SQI interface are inputs or outputs.
typedef enum logic {
  SQI_IO_MODE_IN  = 1'b0,
  SQI_IO_MODE_OUT = 1'b1
} sqi_io_mode_t;

endpackage

`endif // !idli_pkg_svh_d
