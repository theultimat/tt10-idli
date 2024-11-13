import argparse
import pathlib
import re
import struct

import isa


# Data names to widths in bits.
DATA_TYPES = {
    'byte': 8,
    'half': 16,
    'word': 32,
    'long': 64,
}


# Parse command line arguments.
def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '-v',
        '--verbose',
        action='store_true',
        help='Enable verbose debug output.',
    )

    parser.add_argument(
        'input',
        metavar='INPUT',
        type=pathlib.Path,
        help='Path to input assembly file.',
    )

    parser.add_argument(
        '-o',
        '--output',
        type=pathlib.Path,
        required=True,
        help='Path to output binary to generate.',
    )

    args = parser.parse_args()

    # Check input paths are valid.
    if not args.input.is_file():
        raise Exception(f'Bad input: {args.input}')

    if not args.output.parent.is_dir():
        raise Exception(f'Bad output directory: {args.output.parent}')

    return args


# Get the size of the specified section in bytes. Instructions are either 16 or
# 32 bits depending on a following immediate. Data size depends on the type and
# is stored in the section as a tuple of (dtype, value).
def section_size(section):
    size = 0

    for item in section:
        if isinstance(item, isa.Instruction):
            size += item.size()
        else:
            dtype, _ = item
            size += DATA_TYPES[dtype]

    return size // 8


# Parse a label.
def parse_label(args, label, error_prefix, section, sections, labels, indent):
    if not section:
        raise Exception(f'{error_prefix}Label not in section: {label}')

    # Local labels are numerical and must be referenced relative to each
    # instruction by appending a 'b' for backwards or 'f' for forwards.
    local = label.isdigit()
    addr = section_size(sections[section])

    # Labels are stored as the section and the offset within the offset. Local
    # labels may have multiple offsets.
    if local:
        if label not in labels:
            labels[label] = (section, [])
        labels[label][-1].append(addr)
    else:
        if label in labels:
            raise Exception(f'{error_prefix}Duplicate non-local label: {label}')

        labels[label] = (section, addr)

    if args.verbose:
        print(
            f'{" " * indent}- Label: name={label} section={section} '
            f'addr=0x{addr:04x}'
        )


# Parse directives. These change section, include other files, or add data.
def parse_directive(
    args,
    parts,
    parent_dir,
    error_prefix,
    section,
    sections,
    labels,
    indent
):
    assert parts[0].startswith('.')
    name = parts.pop(0)[1:]

    # Change the section to data or text.
    if name in ('text', 'data'):
        if parts:
            raise Exception(f'{error_prefix}Junk at end of line')

        return name

    # Include another file and recursively parse.
    # TODO This assumes the include path doesn't have any commas or spaces but
    # assume this won't happen for now...
    if name == 'include':
        if len(parts) != 1:
            raise Exception(f'{error_prefix}Bad .include form')

        path = parts[0]
        if not path.startswith('"') or not path.endswith('"'):
            raise Exception(f'{error_prefix}Include path missing quotes')

        path = parent_dir / path[1:-1]
        if not path.is_file():
            raise Exception(f'{error_prefix}Bad include path: {path}')

        return parse_file(
            args,
            path,
            section,
            sections,
            labels,
            indent + 1
        )

    # Add the specified number of zero bytes.
    if name in ('zeros', 'zeroes'):
        if len(parts) != 1:
            raise Exception(f'{error_prefix}Missing zero padding size')

        size = isa.parse_imm(parts[0], error_prefix, 64)
        if size < 1:
            raise Exception(f'{error_prefix}Bad zero padding size: {size}')

        sections[section] += [('byte', 0)] * size
        return section

    # Otherwise it must be a single data type and value.
    bits = DATA_TYPES.get(name)
    if not bits:
        raise Exception(f'{error_prefix}Bad directive: {name}')
    if len(parts) != 1:
        raise Exception(f'{error_prefix}No value for data')

    val = isa.parse_imm(parts[0], error_prefix, bits)
    sections[section].append((name, val))

    return section


# Parse the line, returning the active section after parsing.
def parse_line(
    args,
    line,
    parent_dir,
    error_prefix,
    section,
    sections,
    labels,
    indent
):
    # Remove any comments - these are the same as in python.
    try:
        line = line[:line.index('#')].strip()
    except ValueError:
        pass

    # If the line isn't empty that split it into parts.
    if not line:
        return section

    if args.verbose:
        print(f'{" " * indent}- Parse line: {line}')

    parts = re.split(r'[\s,]+', line)

    # If the first part of the line ends with a colon then it indicates a label
    # name - parse it then throw away the part.
    if parts[0][-1] == ':':
        parse_label(
            args,
            parts[0][:-1],
            error_prefix,
            section,
            sections,
            labels,
            indent + 1,
        )

        parts.pop(0)
        if not parts:
            return section

    # Directives start with a '.' character and consume the rest of the line.
    if parts[0].startswith('.'):
        return parse_directive(
            args,
            parts,
            parent_dir,
            error_prefix,
            section,
            sections,
            labels,
            indent + 1,
        )

    # Otherwise it must be an instruction so parse and add to the section.
    addr = section_size(sections[section])
    instr = isa.Instruction.from_str(' '.join(parts))
    sections[section].append(instr)

    if args.verbose:
        print(
            f'{" " * (indent + 1)}- Instruction: addr=0x{addr:04x} '
            f"instr='{instr}'"
        )


    return section


# Parse the specified input file and return the active section.
def parse_file(args, path, section, sections, labels, indent=0):
    if args.verbose:
        print(f'{" " * indent}- Parse file: {path}')

    with open(path, 'r') as f:
        for i, line in enumerate(f):
            section = parse_line(
                args,
                line.strip(),
                path.parent,
                f'{path}:{i}: ',
                section,
                sections,
                labels,
                indent + 1,
            )

    return section


# Parse the input file into a list of sections, their contents, and labels.
def parse(args):
    section = None
    sections = {
        'text': [],
        'data': [],
    }
    labels = {}

    parse_file(args, args.input, section, sections, labels)

    return sections, labels


# Resolve all labels to their final addresses and update immediates stored in
# the instructions accordingly. Text starts at address zero with data starting
# immediately after text ends.
def resolve_labels(args, sections, labels):
    if args.verbose:
        print(f'- Resolve labels:')

    pc = 0
    text_size = section_size(sections['text'])

    for instr in sections['text']:
        imm = instr.ops.get('imm')
        if isinstance(imm, tuple):
            label, mode = imm

            # For a local label we need to find the closest one based on the
            # direction. For others we can just look up the direct address.
            if label[:-1].isdigit() and label[-1] in 'fb':
                section, addrs = labels[label[:-1]]
                label_addr = None

                if label[-1] == 'f':
                    for addr in addrs:
                        if addr > pc:
                            label_addr = addr
                            break
                else:
                    for addr in reversed(addrs):
                        if addr <= pc:
                            label_addr = addr
                            break
            else:
                section, label_addr = labels[label]

            # Offset by text size if the label is in the data section.
            if section == 'data':
                label_addr += text_size

            # Generate relative offset if required. This is calculated as
            # relative to the next PC to account for the hardware pipeline.
            if mode == '$':
                imm = label_addr
            else:
                imm = label_addr - (pc + isa.ILEN // 8)

            if args.verbose:
                print(
                    f'  - Resolve: label={label} (0x{label_addr:04x}) '
                    f'pc=0x{pc:04x} imm={hex(imm)}'
                )

            # Store updated immediate.
            instr.ops['imm'] = imm

        pc += instr.size() // 8


# Generate encodings and write to output file.
def write_binary(args, sections):
    if args.verbose:
        print(f'- Write binary: {args.output}')

    with open(args.output, 'wb') as f:
        for instr in sections['text']:
            f.write(instr.encode())

        for dtype, val in sections['data']:
            if dtype == 'byte':
                fmt = 'b'
            elif dtype == 'half':
                fmt = 'h'
            elif dtype == 'word':
                fmt = 'i'
            else:
                fmt = 'q'

            f.write(struct.pack(f'<{fmt}', val))


# Entry point.
if __name__ == '__main__':
    args = parse_args()

    sections, labels = parse(args)
    resolve_labels(args, sections, labels)
    write_binary(args, sections)
