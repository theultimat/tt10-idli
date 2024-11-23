import re
import struct


# Length of all instructions in bits.
ILEN = 16


# General purpose REGisters as a map from name in assembly to their underlying
# register number. All registers at 16b. We have eight registers in total:
# - r0          Alias 'zr'. Reads always return 0, writes are ignored.
# - r1 .. r5    General purpose.
# - r6          Alias 'sp'. General purpose but recommended as stack pointer.
# - r7          Alias 'pc'. Program counter.
GREGS = {
    'r0': 0,
    'r1': 1,
    'r2': 2,
    'r3': 3,
    'r4': 4,
    'r5': 5,
    'r6': 6,
    'r7': 7,

    'zr': 0,
    'sp': 6,
    'pc': 7,
}

GREGS_INV = {v: k for k, v in GREGS.items()}


# Predicate REGisters. These are used for conditions and storing the result of
# comparisons. Each of the four registers are a single bit in size. These are
# all general purpose except for 'p3' which ignores writes and always returns 1
# on read.
PREGS = {
    'p0': 0,
    'p1': 1,
    'p2': 2,
    'p3': 3,
}

PREGS_INV = {v: k for k, v in PREGS.items()}


# Encodings for all supported instructions. Letters indicates the bits that are
# used for operands in the order that they appear in the assembly. There are
# a number of operand types:
# - 'p': Name of a predicate register to control whether the instruction should
#        be executed.
# - 'q': Name of a predicate register that can be used as both and input and an
#        output to an instruction.
# - 'a': General purpose register used as a destination only.
# - 'b': Source general purpose register. This can also be written by memory
#        operations with writeback addressing.
# - 'c': Source register only. A value of 'r7' indicates that an immediate
#        should be read as an operand from the next 16b following the
#        instruction.
ENCODINGS = {
    # Add/subtract with carry.
    'adcs': 'pp000qqaaabbbccc',
    'sbbs': 'pp001qqaaabbbccc',

    # Signed and unsigned comparison.
    'eq':   'pp010qq000bbbccc',
    'ne':   'pp010qq001bbbccc',
    'lt':   'pp010qq010bbbccc',
    'ltu':  'pp010qq011bbbccc',
    'ge':   'pp010qq100bbbccc',
    'geu':  'pp010qq101bbbccc',

    # Check for mask bits set/clear.
    'mset': 'pp010qq110bbbccc',
    'mclr': 'pp010qq111bbbccc',

    # Store value in predicate register.
    'putp': 'pp011qq000000ccc',

    # Write 16b to output pins.
    'out':  'pp01100100000ccc',

    # ALU operations.
    'add':  'pp10000aaabbbccc',
    'sub':  'pp10001aaabbbccc',
    'and':  'pp10010aaabbbccc',
    'andn': 'pp10011aaabbbccc',
    'or':   'pp10100aaabbbccc',
    'xor':  'pp10101aaabbbccc',

    # Right shifts.
    'sra':  'pp10110aaabbb000',
    'srl':  'pp10110aaabbb001',
    'ror':  'pp10110aaabbb010',

    # Read 16b from input pins.
    'in':   'pp10110aaa000111',

    # Load/store with post-increment writeback.
    'ldb!': 'pp10111aaabbb000',
    'ldh!': 'pp10111aaabbb001',
    'stb!': 'pp10111aaabbb010',
    'sth!': 'pp10111aaabbb011',

    # Load/store with pre-increment writeback.
    '!ldb': 'pp10111aaabbb100',
    '!ldh': 'pp10111aaabbb101',
    '!stb': 'pp10111aaabbb110',
    '!sth': 'pp10111aaabbb111',

    # Load/store with optional index scaling and no writeback.
    'ldb':  'pp11000aaabbbccc',
    'ldh':  'pp11001aaabbbccc',
    'stb':  'pp11010aaabbbccc',
    'sth':  'pp11011aaabbbccc',
    'ldhs': 'pp11101aaabbbccc',
    'sths': 'pp11111aaabbbccc',
}

OPCODES = {
    k: int(''.join(x if x in '01' else '0' for x in v), 2)
    for k, v in ENCODINGS.items()
}

OPCODE_MASKS = {
    k: int(''.join('1' if x in '01' else '0' for x in v), 2)
    for k, v in ENCODINGS.items()
}


# The assembler also support synonyms for common operations. These are written
# below as python format strings - operations read from the assembly will be
# be substituted into the strings to generate the real instruction.
SYNONYMS = {
    # Push/pop stack.
    'push': '!sth.{} {}, sp, -2',
    'pop':  'ldh!.{} {}, sp, 2',

    # Return from function by popping address from stack.
    'ret':  'ldh!.{} pc, sp, 2',

    # Relative and absolute branches.
    'b':    'add.{} pc, pc, {}',
    'j':    'add.{} pc, zr, {}',

    # Move between registers.
    'mov':  'add.{} {}, zr, {}',

    # Logical and arithmetic negation.
    'not':  'xor.{} {}, zr, {}',
    'neg':  'sub.{} {}, zr, {}',

    # No-operation.
    'nop':  'add.{} zr, zr, zr',

    # Read predicate register into general purpose register.
    'getp': 'add.{1} {0}, zr, 1',
}


# Helper function to parse an immediate with the specified number of bits.
def parse_imm(data, error_prefix='', bits=16):
    try:
        imm = int(data, 0)
    except ValueError:
        imm = None

    if imm is None:
        raise Exception(f'{error_prefix}Bad immediate: {data}')

    # Immediates are represented as a signed number internally, so if the value
    # is too large then we subtract the bias to get back into the signed range.
    if imm >= 1 << (bits - 1):
        imm -= 1 << bits

    if imm >= 1 << (bits - 1):
        raise Exception(f'{error_prefix}Immediate too large: {data}')
    if imm < -(1 << (bits - 1)):
        raise Exception(f'{error_prefix}Immediate too small: {data}')

    return imm


# Represents a single instruction.
class Instruction:
    # Default to a NOP.
    def __init__(self):
        self.name = 'add'
        self.enc = ENCODINGS['add']
        self.ops = {
            'p': PREGS['p3'],
            'a': GREGS['zr'],
            'b': GREGS['zr'],
            'c': GREGS['zr'],
        }

    # Create an instruction from the assembly line.
    @staticmethod
    def from_str(line, error_prefix=''):
        instr = Instruction()

        # Split the input line into parts. Instructions should be of the form
        # op[.pred] op0, op1, ...
        parts = re.split(r'[\s,]+', line.strip())
        if not parts:
            raise Exception(f'{error_prefix}No instruction found')

        # Extract the mnemonic and check for any predication. If no predication
        # is found we default to 'p3' i.e. always executed. The 'getp' synonym
        # is a special case here as it cannot be predicated.
        instr.name = parts.pop(0)
        pred = '.' in instr.name
        getp = instr.name.startswith('getp')

        if pred and getp:
            raise Exception(f'{error_prefix}getp cannot be predicated')

        if pred:
            instr.name, pred = instr.name.split('.')
        elif not getp:
            pred = 'p3'

        # Add the predicate to the start of parts so it's always treated as the
        # first operand passed to the instruction.
        parts = [pred] + parts

        # Check for the instruction being a synonym and if so replace it with
        # the real instruction.
        synonym = SYNONYMS.get(instr.name)
        if synonym:
            parts = re.split(r'[\s,.]+', synonym.format(*parts))
            instr.name = parts.pop(0)

        # Get the encoding string and make sure it's the correct length.
        instr.enc = ENCODINGS.get(instr.name)
        if not instr.enc:
            raise Exception(f'{error_prefix}Unknown mnemonic: {instr.name}')
        assert len(instr.enc) == ILEN

        # Extract the operands from the encoding. Writeback memory operations
        # don't have a 'c' operand for encoding the immediate marker as it's
        # always present so this needs to be accounted for when checking we
        # have the correct number of operands.
        instr.ops = {k: None for k in instr.enc if k not in '01'}
        writeback = '!' in instr.name

        if len(instr.ops) != len(parts) - writeback:
            raise Exception(
                f'{error_prefix}Bad number of operands: '
                'expected {len(instr.ops)} but got {len(parts) - writeback}'
            )

        # Parse the operands and store their values in the internal map. The
        # values appear in the same order in the assembly as in the encoding.
        imm = None
        for op, val in zip(instr.ops, parts):
            if val in GREGS:
                val = GREGS[val]

                # 'pc' cannot be encoded in a 'c' operand as this is used to
                # indicate an immediate.
                if op == 'c' and val == GREGS['pc']:
                    raise Exception(
                        f"{error_prefix}Cannot encode pc into 'c' operand"
                    )
            elif val in PREGS:
                val = PREGS[val]
            elif val.startswith('@') or val.startswith('$'):
                # Relative and absolute labels are indicated by @ and $
                # respectively and stored a tuple of type and value.
                imm = (val[1:], val[0])
                val = GREGS['pc']
            else:
                if imm is not None:
                    raise Exception(f'{error_prefix}Too many immediates')

                # Get immediate value and encode in instruction as 'pc'.
                imm = parse_imm(val, error_prefix)
                val = GREGS['pc']

            # Immediate must be encoded as 'c' operands only.
            if imm is not None and op != 'c':
                raise Exception(f'{error_prefix}Bad immediate position')

            instr.ops[op] = val

        # If this is a writeback load/store then we need to manually parse the
        # immediate as there is no encoded 'c'.
        if writeback:
            if imm is not None:
                raise Exception(f'{error_prefix}Too many immediates')

            imm = parse_imm(parts[-1], error_prefix)

        # Store the immediate as an operand.
        if imm is not None:
            instr.ops['imm'] = imm

        return instr

    # Create instruction from a byte buffer.
    @staticmethod
    def from_bytes(buffer, error_prefix=''):
        if len(buffer) < ILEN // 8:
            raise Exception(f'{error_prefix}Not enough bytes to parse')

        # Read first 16b to identify the instruction.
        data, = struct.unpack_from('<H', buffer)
        data = Instruction._swap_nibbles(data)
        name = None

        for mnem, opcode in OPCODES.items():
            mask = OPCODE_MASKS[mnem]

            if (data & mask) == opcode:
                name = mnem
                break

        # If we didn't find a match then return none.
        if not name:
            return None

        instr = Instruction()
        instr.name = name
        instr.enc = ENCODINGS[name]

        # Extract operand values by determining their
        instr.ops = {k: None for k in instr.enc if k not in '01'}
        for op in instr.ops:
            mask = int(''.join('1' if x == op else '0' for x in instr.enc), 2)
            val = (data & mask) >> ((mask & -mask).bit_length() - 1)
            instr.ops[op] = val

        # Read immediate operand from the following 16b if required.
        if instr.ops.get('c') == GREGS['pc'] or '!' in name:
            if len(buffer) < 2 * ILEN // 8:
                raise Exception(f'{error_prefix}Not enough bytes for immediate')

            instr.ops['imm'], = struct.unpack_from('<h', buffer[ILEN // 8:])

        return instr

    # Encode the instruction and return the raw bytes.
    def encode(self):
        bits = self.enc

        # Substitute each operand letter with the binary value.
        for op, val in self.ops.items():
            if op == 'imm':
                continue

            n = bits.count(op)
            enc = f'{val:0{n}b}'
            assert n == len(enc)

            enc = iter(enc)
            bits = ''.join(next(enc) if x == op else x for x in bits)

        # Convert the encoding to bytes and add the optional immediate.
        enc = Instruction._swap_nibbles(int(bits, 2))
        imm = self.ops.get('imm')

        out = struct.pack('<H', enc)
        if imm is not None:
            out += struct.pack('<h', imm)

        return out

    # Print instruction as a string.
    def __str__(self):
        pred = self.ops['p']
        pred = f'.p{pred}' if pred != PREGS['p3'] else ''

        ops = []
        seen = set()
        for bit in self.enc:
            if bit in '01p' or bit in seen:
                continue

            op = self.ops[bit]
            seen.add(bit)
            if bit == 'c' and op == GREGS['pc']:
                continue

            if bit == 'q':
                ops.append(PREGS_INV[op])
            else:
                ops.append(GREGS_INV[op])

        imm = self.ops.get('imm')
        if isinstance(imm, tuple):
            ops.append(f'{imm[1]}{imm[0]}')
        elif imm is not None:
            ops.append(hex(imm))

        return f'{self.name}{pred} {", ".join(ops)}'

    # Size of the instruction in bits.
    def size(self):
        return (1 + ('imm' in self.ops)) * ILEN

    # Helper to swap the nibbles around in an encoded instruction. The decoder
    # in the RTL is simplified by taking the highest nibble first so swap these
    # around within each byte.
    @staticmethod
    def _swap_nibbles(x):
        out  = (x & 0x000f) << 4
        out |= (x & 0x00f0) >> 4
        out |= (x & 0x0f00) << 4
        out |= (x & 0xf000) >> 4
        return out
