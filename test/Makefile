# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

SOURCE_NAMES :=                 \
    tt_um_theultimat_idli_top   \
    idli_core_m                 \
    idli_io_reg_m               \
    idli_ctrl_m                 \
    idli_decode_m               \
    idli_grf_m                  \
    idli_sqi_ctrl_m

# Use SystemVerilog for verilator, sv2v converted for iverilog.
ifeq ($(SIM),verilator)

COMPILE_ARGS += -Wall

EXTRA_ARGS := --trace-fst --trace-structs --x-assign unique --x-initial unique
PLUSARGS := +verilator+rand+reset+2

SRC_DIR = $(PWD)/../src-sv
PROJECT_SOURCES = $(addsuffix .sv,$(SOURCE_NAMES))

else

SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = $(addsuffix .v,$(SOURCE_NAMES))

endif


ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS 		+= -I$(SRC_DIR)

else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# MODULE is the basename of the Python test file
MODULE = test

# Name of the test to compile and run.
export IDLI_ASM ?= gcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
