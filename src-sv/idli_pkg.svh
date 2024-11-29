`ifndef idli_pkg_svh_d
`define idli_pkg_svh_d

package idli_pkg;

// Whether the IO pins on the SQI interface are inputs or outputs.
typedef enum logic {
  SQI_MODE_IN  = 1'b0,
  SQI_MODE_OUT = 1'b1
} sqi_mode_t;

// Predicate and general purpose register IDs.
typedef logic [1:0] preg_t;
typedef logic [2:0] greg_t;

localparam greg_t GREG_PC = greg_t'('1);

// Supported ALU operations.
typedef enum logic [1:0] {
  ALU_OP_ADD,
  ALU_OP_AND,
  ALU_OP_OR,
  ALU_OP_XOR
} alu_op_t;

// Decoded instruction for execution unit control.
typedef struct packed {
  preg_t    op_p;
  preg_t    op_q;
  greg_t    op_a;
  greg_t    op_b;
  greg_t    op_c;
  alu_op_t  alu_op;
} instr_t;

endpackage

`endif // !idli_pkg_svh_d
