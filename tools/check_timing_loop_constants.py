#!/usr/bin/env python3
"""Qualify reported STA loops against native constant-disabled arcs.

The coverage directory must contain check.tcl and its check_setup -verbose log.
No constraints or netlists are changed. A loop with no constant-disabled edge
remains unresolved; this diagnostic does not establish functional equivalence.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--coverage-dir', type=Path, required=True)
p.add_argument('--native', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
a.output.mkdir(parents=True, exist_ok=False)
source_log = a.coverage_dir / 'check.log'
source_script = a.coverage_dir / 'check.tcl'
text = source_log.read_text().split('CHECK_SETUP_BEGIN', 1)[1]
header = re.search(r'Warning: There (?:are|is) (\d+) combinational loops? in the design\.', text)
expected_loops = int(header[1]) if header else 0
text = text[header.end():] if header else ''
loops = []
for section in text.split('--------------------------------')[:-1]:
    pins = [s.strip() for s in section.splitlines() if s.startswith('  ') and '/' in s]
    if pins:
        loops.append(pins)
if len(loops) != expected_loops:
    raise ValueError(f'Parsed {len(loops)} loops; STA reported {expected_loops}')
commands = source_script.read_text().split('puts CHECK_SETUP_BEGIN', 1)[0]
commands += '\ncheck_setup -loops\n'
commands += '''
proc inspect_edge {index from to} {
 set p [sta::find_pin $from]
 set q [sta::find_pin $to]
 if {$p == "NULL" || $q == "NULL"} {error "Missing loop pin $from / $to"}
 # Ensure the simulator has propagated the actual netlist constants.
 sta::pin_sim_logic_value $p
 set found 0
 foreach vertex [$p vertices] {
  set it [$vertex out_edge_iterator]
  while {[$it has_next]} {
   set edge [$it next]
   if {[$edge to_pin] == $q} {
    set found 1
    if {[$edge is_disabled_constant]} {puts "CONSTANT_EDGE $index {$from} {$to}"}
   }
  }
  $it finish
 }
 if {!$found} {puts "MISSING_EDGE $index {$from} {$to}"}
}
'''
edge_commands = []
for index, pins in enumerate(loops):
    for start, end in zip(pins, pins[1:]):
        if any(c in start + end for c in '{}\n'):
            raise ValueError('Unsupported pin-name character')
        edge_commands.append(f'inspect_edge {index} {{{start}}} {{{end}}}\n')
commands += ''.join(edge_commands)
script = a.output / 'check.tcl'
script.write_text(commands)
log = a.output / 'check.log'
with log.open('w') as handle:
    status = subprocess.run([str(a.native), '-exit', '-no_init', '-threads', '2', str(script)],
                            stdout=handle, stderr=subprocess.STDOUT).returncode
constant_edges = {i: [] for i in range(len(loops))}
missing = []
for line in log.read_text().splitlines():
    if line.startswith('CONSTANT_EDGE '):
        _, index, pins = line.split(' ', 2)
        constant_edges[int(index)].append(pins)
    elif line.startswith('MISSING_EDGE '):
        missing.append(line)
unresolved = [i for i, edges in constant_edges.items() if not edges]
record = {
    'passed': status == 0 and not missing and not unresolved,
    'native_exit_code': status, 'loops': len(loops),
    'unresolved_loops': unresolved, 'missing_edges': missing,
    'constant_disabled_edges': constant_edges,
    'source_check_script_sha256': hashlib.sha256(source_script.read_bytes()).hexdigest(),
    'source_check_log_sha256': hashlib.sha256(source_log.read_bytes()).hexdigest(),
    'scope': 'Constant-disabled arcs in reported structural loops; no added timing exceptions.',
}
(a.output / 'result.json').write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps({k: v for k, v in record.items() if k != 'constant_disabled_edges'}))
raise SystemExit(0 if record['passed'] else 1)
