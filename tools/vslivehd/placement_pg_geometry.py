#!/usr/bin/env python3
"""Stream DEF PG geometry and via definitions; omit only terminal associations."""
import gzip, hashlib, json, re, sys
from pathlib import Path
source, output, metadata = map(Path, sys.argv[1:])
digest = hashlib.sha256(); rows = 0; size = 0; section = None; supply_count = None; net_count = 0; in_connections = False
connection_depth = 0

def property_start(line, depth):
    """Find a standalone '+' outside DEF connection tuples/escaped names."""
    index = 0
    while index < len(line):
        char = line[index]
        if char == ord('\\'):
            index += 2  # DEF escapes the following identifier character.
            continue
        if char == ord('('):
            depth += 1
        elif char == ord(')'):
            depth -= 1
            assert depth >= 0, 'Unbalanced SPECIALNETS connection tuple'
        elif (char == ord('+') and depth == 0
              and (index == 0 or line[index - 1:index].isspace())
              and (index + 1 == len(line) or line[index + 1:index + 2].isspace())):
            return index, depth
        index += 1
    return -1, depth

with source.open('rb') as src, gzip.open(output, 'wb', compresslevel=1) as dst:
    def emit(data):
        global rows, size
        normalized = b' '.join(data.split()) + b'\n'
        dst.write(normalized); digest.update(normalized); rows += 1; size += len(normalized)
    for raw in src:
        line = raw.strip()
        if line.startswith(b'VIAS '): section = 'VIAS'; emit(line); continue
        if line.startswith(b'SPECIALNETS '):
            section = 'SPECIALNETS'; supply_count = int(line.split()[1]); emit(line); continue
        if section == 'VIAS':
            emit(line)
            if line == b'END VIAS': section = None
        elif section == 'SPECIALNETS':
            if line == b'END SPECIALNETS': emit(line); section = None; continue
            if line.startswith(b'- '):
                match = re.match(rb'-\s+(\S+)(.*)', line); assert match
                emit(b'NET ' + match[1]); net_count += 1; in_connections = True; connection_depth = 0
                line = match[2].strip()
            if in_connections:
                # DEF connection tuples precede the first '+' net-property clause.
                # Coordinate tuples in subsequent routing clauses are retained.
                plus, connection_depth = property_start(line, connection_depth)
                if plus < 0: continue
                line = line[plus:]; in_connections = False
            if line: emit(line)
assert supply_count is not None and net_count == supply_count and section is None, 'Incomplete SPECIALNETS section'
metadata.write_text(json.dumps({'sha256':digest.hexdigest(),'geometry_rows':rows,'canonical_bytes':size,'special_nets':net_count,'scope':'All DEF VIAS definitions and SPECIALNETS properties/routes/masks/via placements; only terminal association tuples omitted'},indent=2)+'\n')
print(digest.hexdigest())
