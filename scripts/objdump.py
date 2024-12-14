import argparse
import pathlib
import struct

import isa


# Parse command line arguments.
def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        'input',
        metavar='INPUT',
        type=pathlib.Path,
        help='Path to binary to disassemble',
    )

    args = parser.parse_args()

    # Check input exists.
    if not args.input.is_file():
        raise Exception(f'Bad input: {args.input}')

    return args


# Parse the binary into instructions and data.
def parse(args):
    out = []

    with open(args.input, 'rb') as f:
        data = f.read()

    while data:
        if len(data) >= isa.ILEN // 8:
            instr = isa.Instruction.from_bytes(data)

            if instr is None:
                out.append(('half', *struct.unpack_from('>H', data)))
                data = data[isa.ILEN // 2:]
            else:
                out.append(instr)
                data = data[instr.size() // 8:]
        else:
            out.append(('byte', *struct.unpack_from('>B', data)))
            data = data[1:]

    return out


# Print out the disassembly.
def dump(items):
    addr = 0
    lines = []

    for item in items:
        # If it's an instruction then we can print out the disassmebly but if
        # not just write out the raw data.
        if isinstance(item, isa.Instruction):
            size = item.size() // 8
            enc = item.encode()

            if len(enc) > 2:
                instr, imm = struct.unpack('>HH', enc)
                raw = f'{instr:04x} {imm:04x}'
            else:
                instr, = struct.unpack('>H', enc)
                raw = f'{instr:04x}'

            # Add a comment with the target PC if the instruction is a branch
            # or jump.
            comment = ''
            if item.name == 'add' and item.ops.get('a') == isa.GREGS['pc']:
                target = item.ops['imm']
                if item.ops['b'] == isa.GREGS['pc']:
                    target = addr + isa.ILEN // 8 + target
                elif item.ops['b'] != isa.GREGS['zr']:
                    target = None

                if target is not None:
                    comment = f' # target=0x{target:04x}'

            name, rest = f'{item}'.split(maxsplit=1)
            dis = f'{name:8}{rest}{comment}'
        else:
            dtype, val = item

            if dtype == 'byte':
                dis = f'.byte {hex(val)}'
                raw = f'{val:02x}'
                size = 1
            else:
                dis = f'.half {hex(val)}'
                raw = f'{val:04x}'
                size = 2

        lines.append(f'{addr:04x}:  {raw:12}  {dis}')
        addr += size

    # If the same line repeats (aside from address) then don't repeat it as we
    # just clog up the output.
    counts = []
    for line in lines:
        check = line.split(':', 1)[-1]

        if not counts:
            counts.append((check, 1))
            continue

        prev, n = counts[-1]
        if prev == check:
            counts[-1] = (prev, n +  1)
        else:
            counts.append((check, 1))

    i = 0
    for _, n in counts:
        if n < 3:
            for line in lines[i:i + n]:
                print(line)
        else:
            print(lines[i])
            print(' *')
            print(lines[i + n - 1])

        i += n


# Entry point.
if __name__ == '__main__':
    args = parse_args()
    items = parse(args)
    dump(items)
