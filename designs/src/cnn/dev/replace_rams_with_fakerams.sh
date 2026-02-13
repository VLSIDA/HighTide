#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CNN_PATH="${1:-$SCRIPT_DIR/cnn.v}"
if [[ ! -f "$CNN_PATH" ]]; then
  echo "Error: cnn.v not found at $CNN_PATH" >&2
  exit 1
fi
CNN_PATH="$(cd "$(dirname "$CNN_PATH")" && pwd)/$(basename "$CNN_PATH")"
CNN_DIR="$(dirname "$CNN_PATH")"
CNN_FILE="$(basename "$CNN_PATH")"

FAKERAM_MACRO_DIR_DEFAULT="$SCRIPT_DIR/fakeram_asap7"
FAKERAM_MACRO_DIR="${FAKERAM_MACRO_DIR:-$FAKERAM_MACRO_DIR_DEFAULT}"
if [[ ! -d "$FAKERAM_MACRO_DIR" ]]; then
  echo "Error: fakeram macro directory not found at $FAKERAM_MACRO_DIR" >&2
  exit 1
fi
FAKERAM_MACRO_DIR="$(cd "$FAKERAM_MACRO_DIR" && pwd)"

PACKAGE_DIR_DEFAULT="$CNN_DIR/cnn"
PACKAGE_DIR="${PACKAGE_DIR:-$PACKAGE_DIR_DEFAULT}"

BACKUP_PATH="$CNN_PATH.bak"
if [[ ! -e "$BACKUP_PATH" ]]; then
  cp "$CNN_PATH" "$BACKUP_PATH"
  echo "Backup created at $BACKUP_PATH"
fi

python3 - "$CNN_PATH" "$FAKERAM_MACRO_DIR" "$PACKAGE_DIR" <<'PY'
import os
import re
import sys
from collections import OrderedDict
import shutil
from pathlib import Path

cnn_path = Path(sys.argv[1]).resolve()
macro_dir = Path(sys.argv[2]).resolve()
package_arg = Path(sys.argv[3]).expanduser()
if not package_arg.is_absolute():
    package_dir = (cnn_path.parent / package_arg).resolve()
else:
    package_dir = package_arg.resolve()

MEM_RE = re.compile(r'reg\s+\[(\d+)\s*-\s*1:0\]\s+mem\s*\[\s*0\s*:\s*(\d+)\s*-\s*1\s*\];')
PORT_RE = re.compile(r'(input|output)\s+(?:\[(.+?)\]\s*)?(\w+)$')
BASE_RE = re.compile(r'(ram_w\d+_l\d+)')

lines = cnn_path.read_text().splitlines()
module_infos = []


def parse_width(expr: str | None) -> int:
    if not expr:
        return 1
    expr = expr.replace(' ', '')
    if expr.endswith(':0'):
        expr = expr[:-2]
    if '-' in expr:
        val = expr.split('-')[0]
        return int(val)
    if expr.isdigit():
        return int(expr) + 1
    raise ValueError(f"Unsupported range expression: {expr}")


def parse_module(module_lines: list[str]) -> dict | None:
    module_decl = module_lines[0].strip()
    parts = module_decl.split()
    if len(parts) < 2:
        return None
    module_name = parts[1]

    header_lines = []
    header_end_idx = None
    for idx, line in enumerate(module_lines):
        header_lines.append(line)
        if line.strip().endswith(');'):
            header_end_idx = idx
            break
    if header_end_idx is None:
        return None

    port_lines = header_lines[1:]
    groups = {}
    bits = None
    addr_width = None
    clk_signal = None

    for raw_line in port_lines:
        stripped = raw_line.strip().rstrip(',')
        if not stripped or stripped == ');':
            continue
        match = PORT_RE.match(stripped)
        if not match:
            continue
        direction, range_expr, name = match.groups()
        if name == 'CLK':
            clk_signal = name
            continue
        if not name.startswith(module_name + '_'):
            continue
        suffix = name[len(module_name) + 1:]
        if not suffix:
            continue
        parts = suffix.split('_', 1)
        if len(parts) != 2:
            continue
        group_id, field = parts
        field = field.lower()
        bucket = groups.setdefault(group_id, {})
        bucket[field] = name
        if direction == 'output' and field == 'rdata':
            bits = parse_width(range_expr)
        if direction == 'input' and field == 'addr':
            addr_width = parse_width(range_expr)

    mem_match = None
    for body_line in module_lines[header_end_idx + 1:-1]:
        mem_match = MEM_RE.search(body_line)
        if mem_match:
            break
    if not mem_match:
        return None

    mem_bits = int(mem_match.group(1))
    depth = int(mem_match.group(2))
    if bits is None:
        bits = mem_bits
    if addr_width is None:
        addr_width = int((depth - 1).bit_length())
    base_match = BASE_RE.match(module_name)
    base = base_match.group(1) if base_match else module_name

    return {
        'name': module_name,
        'header_idx': header_end_idx,
        'groups': groups,
        'bits': bits,
        'mem_bits': mem_bits,
        'addr_width': addr_width,
        'depth': depth,
        'base': base,
        'clk': clk_signal or 'CLK',
    }


line_idx = 0
while line_idx < len(lines):
    stripped = lines[line_idx].lstrip()
    if stripped.startswith('module ram_'):
        start = line_idx
        j = line_idx
        header_end = None
        while j < len(lines):
            if lines[j].strip().endswith(');'):
                header_end = j
                break
            j += 1
        if header_end is None:
            raise RuntimeError(f"Malformed module header near line {line_idx + 1}")
        k = header_end + 1
        while k < len(lines) and not lines[k].strip().startswith('endmodule'):
            k += 1
        if k >= len(lines):
            raise RuntimeError(f"Missing endmodule for module starting at line {line_idx + 1}")
        end = k
        module_lines = lines[start:end + 1]
        parsed = parse_module(module_lines)
        info = {
            'start': start,
            'end': end,
            'orig_lines': module_lines,
        }
        if parsed is None:
            info['skip'] = True
        else:
            info.update(parsed)
            info['header_lines'] = module_lines[:parsed['header_idx'] + 1]
        module_infos.append(info)
        line_idx = end + 1
    else:
        line_idx += 1

if not module_infos:
    print('No ram_ modules found; nothing to replace.')
    sys.exit(0)

base_meta: OrderedDict[str, dict] = OrderedDict()
for info in module_infos:
    if info.get('skip'):
        continue
    base = info['base']
    ports = len(info['groups'])
    if ports == 0:
        raise RuntimeError(f"Module {info['name']} has no ports detected")
    fakeram_name = base.replace('ram_', 'fakeram_', 1)
    meta = base_meta.get(base)
    if meta is None:
        base_meta[base] = {
            'bits': info['bits'],
            'depth': info['depth'],
            'addr_width': info['addr_width'],
            'ports': ports,
            'fakeram_name': fakeram_name,
        }
    else:
        if meta['bits'] != info['bits'] or meta['depth'] != info['depth'] or meta['ports'] != ports:
            raise RuntimeError(
                f"Inconsistent metadata for base {base}: existing {meta} vs module {info['name']}"
            )

if not base_meta:
    print('All RAM modules appear to be already replaced; skipping generation.')
    sys.exit(0)

for meta in base_meta.values():
    fakeram_file = macro_dir / meta['fakeram_name'] / f"{meta['fakeram_name']}.v"
    if not fakeram_file.exists():
        raise FileNotFoundError(f"Expected fakeram Verilog at {fakeram_file}. Please generate macros first.")

include_lines = []
for meta in base_meta.values():
    fakeram_file = macro_dir / meta['fakeram_name'] / f"{meta['fakeram_name']}.v"
    include_rel = os.path.relpath(fakeram_file, cnn_path.parent)
    include_lines.append(f'`include "{include_rel}"')

existing_include_set = {line.strip() for line in lines if line.strip().startswith('`include')}
includes_to_add = [line for line in include_lines if line not in existing_include_set]


def generate_wrapper(info: dict, fakeram_name: str) -> list[str]:
    header_lines = info['header_lines']
    groups = info['groups']
    clk = info['clk']
    ordered_groups = sorted(groups.items(), key=lambda kv: int(kv[0]))
    conn_entries: list[str] = []
    for idx, (_, fields) in enumerate(ordered_groups):
        try:
            enable_sig = fields['enable']
            wen_sig = fields.get('wenable') or fields.get('we') or fields.get('writeenable')
            if wen_sig is None:
                raise KeyError('wenable')
            addr_sig = fields['addr']
            wdata_sig = fields['wdata']
            rdata_sig = fields['rdata']
        except KeyError as exc:
            raise RuntimeError(f"Missing expected signal {exc} in module {info['name']}")
        conn_entries.extend([
            f'    .rw{idx}_clk({clk})',
            f'    .rw{idx}_ce_in({enable_sig})',
            f'    .rw{idx}_we_in({wen_sig})',
            f'    .rw{idx}_addr_in({addr_sig})',
            f'    .rw{idx}_wd_in({wdata_sig})',
            f'    .rw{idx}_rd_out({rdata_sig})',
        ])
    instance_lines = [f'  {fakeram_name} u_{info["name"]}_mem (']
    for idx, entry in enumerate(conn_entries):
        suffix = ',' if idx + 1 < len(conn_entries) else ''
        instance_lines.append(f'{entry}{suffix}')
    instance_lines.append('  );')
    return header_lines + [''] + ['  // Replaced with fakeram macro'] + instance_lines + ['', 'endmodule', '']

new_lines: list[str] = []
current = 0
for info in module_infos:
    start = info['start']
    end = info['end']
    new_lines.extend(lines[current:start])
    if info.get('skip'):
        new_lines.extend(info['orig_lines'])
    else:
        fakeram_name = base_meta[info['base']]['fakeram_name']
        wrapper = generate_wrapper(info, fakeram_name)
        new_lines.extend(wrapper)
    current = end + 1
new_lines.extend(lines[current:])

cnn_path.write_text('\n'.join(new_lines) + '\n')

if package_dir.exists():
    if package_dir.is_file():
        package_dir.unlink()
    else:
        shutil.rmtree(package_dir)
package_dir.mkdir(parents=True, exist_ok=True)

for meta in base_meta.values():
    src_dir = macro_dir / meta['fakeram_name']
    for ext in ('.v', '.bb.v', '.lef', '.lib'):
        src_file = src_dir / f"{meta['fakeram_name']}{ext}"
        if src_file.exists():
            shutil.copy2(src_file, package_dir / src_file.name)
        else:
            raise FileNotFoundError(f"Missing expected file {src_file}")

shutil.copy2(cnn_path, package_dir / cnn_path.name)

print('Using fakeram macros:')
for base, meta in base_meta.items():
    fakeram_file = macro_dir / meta['fakeram_name'] / f"{meta['fakeram_name']}.v"
    print(f"  {meta['fakeram_name']} -> {fakeram_file}")

replaced = [info['name'] for info in module_infos if not info.get('skip')]
print(f"Replaced {len(replaced)} RAM module definitions in {cnn_path.name}.")
print(f"Packaged modified design and macros under {package_dir}")
PY

rm cnn/*.bb.v
echo "fakeram replacement complete. Updated $CNN_FILE"
