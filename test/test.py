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

from sim import Idli


# Assemble the test in memory and use it to initialise the simulator. Return
# the simulator and a duplicate of the memory for the RTL to use.
def build_sim():
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

        sim = Idli(tmp.name)

    return sim, np.copy(sim.mem)


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


@cocotb.test()
async def test_project(dut):
    sim, mem = build_sim()

    dut._log.info("==== START ====")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 2, units="ns")
    cocotb.start_soon(clock.start())

    await cocotb.start(sqi_sim(dut, mem))

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

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 32)
