# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import numpy as np
import os
import pathlib
import subprocess
import sys
import tempfile

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge


THIS_DIR = pathlib.Path(__file__).parent.resolve()

sys.path.insert(0, str(THIS_DIR.parent / 'scripts'))

from sim import Idli, IdliCallback
import isa


# Callback for the simulator.
class TestCallback(IdliCallback):
    def __init__(self, dut):
        self.dut = dut

    def write_greg(self, reg, val):
        # Don't check the PC when writing - instead check the final PC is
        # correct after the instruction completes.
        if reg == isa.GREGS['pc']:
            return

        # No point in checking ZR as the hardware can't actually write it.
        if reg == isa.GREGS['zr']:
            return

        rtl = self.dut.grf_u.regs_q[reg].value.integer
        self.dut._log.info(f'- Write r{reg} sim=0x{val:04x} rtl=0x{rtl:04x}')

        assert rtl == val


# Assemble the test in memory and use it to initialise the simulator. Return
# the simulator and a duplicate of the memory for the RTL to use.
def build_sim(cb):
    path = THIS_DIR / f'asm/{os.environ["IDLI_ASM"]}.ia'
    asm = THIS_DIR.parent / 'scripts/asm.py'

    with tempfile.NamedTemporaryFile() as tmp:
        subprocess.check_call([
            'python3',
            asm,
            '--output',
            tmp.name,
            path,
        ])

        dis = subprocess.check_output([
            'python3',
            THIS_DIR.parent / 'scripts/objdump.py',
            tmp.name,
        ]).decode('utf-8')

        sim = Idli(tmp.name, callback=cb)

    return sim, np.copy(sim.mem), dis


# Pretend to be the attached SQI memory.
async def sqi_sim(dut, mem):
    mode = None
    addr = None
    state = None

    MODE_READ = 0x3
    MODE_WRITE = 0x2

    while True:
        await RisingEdge(dut.sqi_sck)

        # Not selected -> chip is in reset.
        if dut.sqi_cs.value:
            mode = None
            addr = None
            state = None
            continue

        # Decide what to do based on the state.
        if state is None:
            dut._log.info('Starting SQI command')
            state = 'instr'
            mode = dut.sqi_data_out.value
        elif state == 'instr':
            mode = (mode << 4) | dut.sqi_data_out.value
            state = 'addr0'
            assert mode in (MODE_READ, MODE_WRITE), hex(mode)
            dut._log.info(f'SQI instruction: 0x{mode:02x}')
        elif state == 'addr0':
            addr = dut.sqi_data_out.value
            state = 'addr1'
        elif state == 'addr1':
            addr = (addr << 4) | dut.sqi_data_out.value
            state = 'addr2'
        elif state == 'addr2':
            addr = (addr << 4) | dut.sqi_data_out.value
            state = 'addr3'
        elif state == 'addr3':
            addr = (addr << 4) | dut.sqi_data_out.value
            state = 'dummy0' if mode == MODE_READ else 'write'
            dut._log.info(f'SQI address: 0x{addr:04x}')
        elif state == 'dummy0':
            state = 'dummy1'
        elif state == 'dummy1':
            state = 'read_hi'
        elif state == 'read_hi':
            state = 'read_lo'
        elif state == 'read_lo':
            state = 'read_hi'
        else:
            raise NotImplementedError(state)

        await FallingEdge(dut.sqi_sck)

        # Output data on the falling edge if required.
        if state == 'read_hi':
            data = (mem[addr] & 0xf0) >> 4
            dut._log.info(f'SQI read 0x{addr:04x}: 0x{data:x}')
            dut.uio_in.value = int(data) << 4
        elif state == 'read_lo':
            data = mem[addr] & 0xf
            dut._log.info(f'SQI read 0x{addr:04x}: 0x{data:x}')
            dut.uio_in.value = int(data) << 4
            addr += 1


# Check instructions that finish execution.
async def check_instr(dut, sim):
    # Wait for reset to complete.
    await RisingEdge(dut.i_core_rst_n)

    while True:
        # Wait for a valid instruction to complete - this is the next rising
        # edge after the last cycle of a valid instruction.
        await FallingEdge(dut.i_core_gck)

        instr_vld = dut.ctr_last_cycle.value & dut.instr_vld_q.value

        await RisingEdge(dut.i_core_gck)

        if not instr_vld:
            continue

        # Advance to the next falling edge to ensure any flopping of register
        # values have now occurred.
        await FallingEdge(dut.i_core_gck)

        instr = sim.next_instr()
        dut._log.info(f'Checking instruction: {instr}')

        # Tick the simulator. This will invoke the callbacks to perform all
        # required checking.
        sim.tick()

        # TODO Check PC is correct.


@cocotb.test()
async def test_project(dut):
    # Check if we're gate-level as we can't access any internal signals so some
    # of the checks need to be disabled.
    gates = 'GL_TEST' in os.environ or os.environ.get('GATES') == 'yes'
    if gates:
        dut._log.info('GL_TEST: Not checking any internal signals!')

    # Create simulator for comparison.
    core = dut.user_project.core_u if not gates else None
    sim, mem, dis = build_sim(TestCallback(core))

    dut._log.info('==== TEST OBJDUMP ====')

    for line in dis.splitlines():
        dut._log.info(line.rstrip())

    dut._log.info("==== START ====")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 2, units="ns")
    cocotb.start_soon(clock.start())

    await cocotb.start(sqi_sim(dut, mem))

    if not gates:
        await cocotb.start(check_instr(core, sim))

    # Reset
    dut._log.info("==== RESET ====")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1

    dut._log.info("==== RESET COMPLETE ====")

    # TODO Determine end condition for test.
    await ClockCycles(dut.clk, 48)
