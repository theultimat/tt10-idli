import argparse
import numpy as np
import pathlib

import isa


# Simulator callback class. When events are called in the simulator the
# corresponding functions will be called.
class IdliCallback:
    def write_greg(self, reg, val):
        pass

    def write_preg(self, reg, val):
        pass

# Simulates the core at the instruction level. This is behavioural and in no way
# cycle accurate!
class Idli:
    # Initialise the simulator into its state post reset.
    def __init__(self, path, trace=False, inputs=[], callback=None):
        self.trace = trace
        self.inputs = inputs
        self.outputs = []
        self.callback = callback

        # The PC is the only GREG that gets reset by the hardware - all others
        # must be initialised by running binary. For ease of use we also set
        # ZR to zero but in the RTL this register doesn't really exist.
        self.gregs = [None] * 8
        self.gregs[isa.GREGS['zr']] = np.uint16(0)
        self.gregs[isa.GREGS['pc']] = np.uint16(0)

        # No predicate registers are initialised, but we set p3 to 1 similarly
        # to ZR.
        self.pregs = [None] * 4
        self.pregs[isa.PREGS['p3']] = True

        # Load the binary into memory as a byte array and resize to the maximum
        # 64K size.
        self.mem = np.fromfile(path, dtype=np.uint8)
        self.mem.resize(64 * 1024)

        # Configure the mapping from instruction name to execution function.
        self.instr_funcs = {
            'adcs': self._adcs_sbbs,
            'sbbs': self._adcs_sbbs,
            'eq':   self._cmp,
            'ne':   self._cmp,
            'lt':   self._cmp,
            'ltu':  self._cmp,
            'ge':   self._cmp,
            'geu':  self._cmp,
            'mset': self._cmp,
            'mclr': self._cmp,
            'putp': self._putp,
            'out':  self._out,
            'add':  self._add_sub,
            'sub':  self._add_sub,
            'and':  self._and_or_xor,
            'andn': self._and_or_xor,
            'or':   self._and_or_xor,
            'xor':  self._and_or_xor,
            'sra':  self._shift,
            'srl':  self._shift,
            'ror':  self._shift,
            'in':   self._in,
            'ldb!': self._load,
            'ldh!': self._load,
            'stb!': self._store,
            'sth!': self._store,
            '!ldb': self._load,
            '!ldh': self._load,
            '!stb': self._store,
            '!sth': self._store,
            'ldb':  self._load,
            'ldh':  self._load,
            'stb':  self._store,
            'sth':  self._store,
            'ldhs': self._load,
            'sths': self._store,
        }

    # Get a handle to the next instruction to execute.
    def next_instr(self):
        pc = self.gregs[isa.GREGS['pc']]
        return isa.Instruction.from_bytes(self.mem[pc:])

    # Run the next instruction.
    def tick(self):
        # Fetch and decode the instruction at the current PC.
        pc = self.gregs[isa.GREGS['pc']]
        instr = self.next_instr()

        if self.trace:
            print(f'RUN    0x{pc:04x}    {instr}')

        # Prior to execution increment the PC by 16b to account for the pipeline
        # found in the real hardware.
        self.write_greg(isa.GREGS['pc'], pc + isa.ILEN // 8)

        # Check whether the instruction should be run based on predication.
        pred = instr.ops['p']
        if self.pregs[pred]:
            sources = self._read_sources(instr)
            redirect = self.instr_funcs[instr.name](instr, sources)
        else:
            if self.trace:
                print(f'SKIP   {isa.PREGS_INV[pred]}')
            redirect = False

        # If the instruction hasn't redirected the PC then it needs to be
        # incremented again if it has an immediate.
        if not redirect and 'imm' in instr.ops:
            self.write_greg(isa.GREGS['pc'], pc + instr.size() // 8)

    # Write a general purpose register.
    def write_greg(self, reg, val):
        if self.callback:
            self.callback.write_greg(reg, val)

        if reg == isa.GREGS['zr']:
            return

        if self.trace:
            print(f'GREG   {isa.GREGS_INV[reg]}        0x{val:04x}')

        self.gregs[reg] = np.uint16(val)

    # Write a predicate register.
    def write_preg(self, reg, val):
        if self.callback:
            self.callback.write_preg(reg, val)

        if reg == isa.PREGS['p3']:
            return

        if self.trace:
            print(f'PREG   {isa.PREGS_INV[reg]}        0x{val:x}')

        self.pregs[reg] = bool(val)

    # Check if the end of test condition has been reached.
    def finished(self, exit_sequence):
        if not exit_sequence:
            return False

        return self.outputs[-len(exit_sequence):] == exit_sequence

    # Read operands for the instruction - we don't need to read the predicate
    # as it's already been checked by this point.
    def _read_sources(self, instr):
        out = {}

        for op, val in instr.ops.items():
            if op in ('p', 'imm'):
                continue

            # Only read 'a' if this is a store.
            if op == 'a' and 'st' not in instr.name:
                continue

            # We only need to read 'q' if the operation is adcs or sbbs - all
            # others treat it as a destination only.
            if op == 'q' and instr.name not in ('adcs', 'sbbs'):
                continue

            # If the operand is 'c' and its value is PC then we should take the
            # immediate value instead.
            if op == 'c' and val == isa.GREGS['pc']:
                out[op] = np.array(instr.ops['imm']).astype(np.uint16).take(0)
                continue

            # Read the register from the appropriate bank, throwing an exception
            # if the register is uninitialised.
            regs = self.pregs if op == 'q' else self.gregs
            out[op] = regs[val]

            if out[op] is None:
                name = isa.PREGS_INV[val] if op == 'q' else isa.GREGS_INV[val]
                raise Exception(f'Read of uninitialised register: {name}')

        # Writeback operations also take an immediate - add it as a 'c' source
        # for consistency with other load/store instructions.
        if '!' in instr.name:
            out['c'] = np.array(instr.ops['imm']).astype(np.uint16).take(0)

        return out

    # Add or subtract with carry.
    def _adcs_sbbs(self, instr, sources):
        gdst = instr.ops['a']

        lhs = np.uint32(sources['b'])
        rhs = np.uint32(sources['c'])
        cin = np.uint32(sources['q'])

        if instr.name == 'adcs':
            out = lhs + rhs + cin
        else:
            out = lhs - rhs - cin

        self.write_preg(instr.ops['q'], (out >> 16) & 1)
        self.write_greg(gdst, out & 0xffff)

        return gdst == isa.GREGS['pc']

    # Add or subtract.
    def _add_sub(self, instr, sources):
        gdst = instr.ops['a']

        lhs = np.uint32(sources['b'])
        rhs = np.uint32(sources['c'])

        if instr.name == 'add':
            out = lhs + rhs
        else:
            out = lhs - rhs

        self.write_greg(gdst, out & 0xffff)

        return gdst == isa.GREGS['pc']

    # Write predicate register.
    def _putp(self, instr, sources):
        self.write_preg(instr.ops['q'], sources['c'] & 1)

        return False

    # Load from memory.
    def _load(self, instr, sources):
        base = sources['b']
        offset = sources['c']
        redirect = False

        # Optionally scale the offset.
        if instr.name == 'ldhs':
            offset <<= 1

        # If required perform register writeback.
        wb_addr = np.uint16((np.uint32(base) + np.uint32(offset)) & 0xffff)
        if '!' in instr.name:
            gdst = instr.ops['b']
            self.write_greg(gdst, wb_addr)
            redirect = gdst == isa.GREGS['pc']

        # Post-writeback takes base before offset, alll others take base after
        # the offset has been added.
        if instr.name.endswith('!'):
            addr = base
        else:
            addr = wb_addr

        if self.trace:
            print(f'LOAD   0x{addr:04x}')

        # Load either a byte or half, sign extending the byte.
        if 'ldb' in instr.name:
            data = self.mem[addr]
            if data & 0x80:
                data |= 0xff00
        else:
            data = self.mem[addr] | (self.mem[addr + 1] << 8)

        gdst = instr.ops['a']
        self.write_greg(gdst, data)

        return redirect or gdst == isa.GREGS['pc']

    # Store to memory.
    def _store(self, instr, sources):
        base = sources['b']
        offset = sources['c']
        redirect = False

        # Scale offset if required.
        if instr.name == 'sths':
            offset <<= 1

        # Perform writeback.
        wb_addr = np.uint16((np.uint32(base) + np.uint32(offset)) & 0xffff)
        if '!' in instr.name:
            gdst = instr.ops['b']
            self.write_greg(gdst, wb_addr)
            redirect = gdst == isa.GREGS['pc']

        # Take address based on writeback mode.
        if instr.name.endswith('!'):
            addr = base
        else:
            addr = wb_addr

        # Store either a byte or half.
        if 'stb' in instr.name:
            data = np.uint8(sources['a'] & 0xff)
            self.mem[addr] = data
            width = 2
        else:
            data = sources['a']
            self.mem[addr + 0] = np.uint8(data & 0xff)
            self.mem[addr + 1] = np.uint8(data >> 8)
            width = 4

        if self.trace:
            print(f'STORE  0x{addr:04x}    0x{data:0{width}x}')

        return redirect

    # Perform comparisons and write to predicate.
    def _cmp(self, instr, sources):
        lhs = sources['b']
        rhs = sources['c']

        # Convert to signed for comparison if required.
        if not instr.name.endswith('u'):
            lhs = np.int16(lhs)
            rhs = np.int16(rhs)

        # Perform the appropriate comparison.
        if instr.name == 'eq':
            out = lhs == rhs
        elif instr.name == 'ne':
            out = lhs != rhs
        elif instr.name.startswith('lt'):
            out = lhs < rhs
        elif instr.name.startswith('ge'):
            out = lhs >= rhs
        elif instr.name == 'mset':
            out = (lhs & rhs) == rhs
        else:
            out = (lhs & rhs) == 0

        self.write_preg(instr.ops['q'], out)

        return False

    # Read from input pins.
    def _in(self, instr, sources):
        gdst = instr.ops['a']

        if not self.inputs:
            raise Exception(f'No input data to read')

        data = self.inputs.pop(0)

        if self.trace:
            print(f'IN     0x{data:04x}')

        self.write_greg(gdst, data)

        return gdst == isa.GREGS['pc']

    # Write to output pins.
    def _out(self, instr, sources):
        data = sources['c']

        if self.trace:
            print(f'OUT    0x{data:04x}')

        self.outputs.append(data)
        return False

    # Perform logical operations.
    def _and_or_xor(self, instr, sources):
        gdst = instr.ops['a']
        lhs = sources['b']
        rhs = sources['c']

        if instr.name == 'and':
            out = lhs & rhs
        elif instr.name == 'andn':
            out = lhs & ~rhs
        elif instr.name == 'or':
            out = lhs | rhs
        else:
            out = lhs ^ rhs

        self.write_greg(gdst, out)

        return gdst == isa.GREGS['pc']

    # Shift right by a single position.
    def _shift(self, instr, sources):
        gdst = instr.ops['a']
        data = sources['b']

        if instr.name == 'sra':
            out = (val & 0x8000) | (data >> 1)
        elif instr.name == 'srl':
            out = data >> 1
        else:
            out = ((data & 1) << 15) | (data >> 1)

        self.write_greg(gdst, out)

        return gdst == isa.GREGS['pc']


# Parse input arguments.
def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        'input',
        metavar='INPUT',
        type=pathlib.Path,
        help='Path to input binary.',
    )

    parser.add_argument(
        '-t',
        '--timeout',
        type=int,
        default=5000,
        help='Maximum number of simulation ticks.',
    )

    parser.add_argument(
        '-i',
        '--in-data',
        action='append',
        default=[],
        help='Data to pass to the core on IN instructions',
    )

    parser.add_argument(
        '-o',
        '--out-data-exit-sequence',
        action='append',
        default=[],
        help='Sequence of output data to indicate end of test.',
    )

    parser.add_argument(
        '-v',
        '--verbose',
        action='store_true',
        help='Enable verbose simulator output.',
    )

    args = parser.parse_args()

    # Check input binary exists.
    if not args.input.is_file():
        raise Exception(f'Bad input: {args.input}')

    # If no pattern is specified define a default.
    if not args.out_data_exit_sequence:
        args.out_data_exit_sequence = ['0xf0f0', '0x0f0f', '0xffff']

    # Convert input and output data to uint16.
    args.in_data = [
        np.array(int(x, 0)).astype(np.uint16).take(0)
        for x in args.in_data
    ]

    args.out_data_exit_sequence = [
        np.array(int(x, 0)).astype(np.uint16).take(0)
        for x in args.out_data_exit_sequence
    ]

    return args


# Entry point.
if __name__ == '__main__':
    args = parse_args()

    sim = Idli(args.input, trace=args.verbose, inputs=args.in_data)

    for _ in range(args.timeout):
        sim.tick()

        if sim.finished(args.out_data_exit_sequence):
            break

    if args.verbose:
        out_data = sim.outputs[:-len(args.out_data_exit_sequence)]

        if out_data:
            for data in out_data:
                vals = [
                    f'0x{data:04x}',
                    f'{np.int16(data)}',
                ]

                if 32 <= data < 127:
                    vals.append(f"'{chr(data)}'")

                print(f'OUTBUF {", ".join(vals)}')
