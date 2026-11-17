#!/usr/bin/env python3
"""Check physical FakeRAM signal inputs for a connected net with a driver.

This is a structural check, not a memory-function or general logic-cone proof.
Both standard fakeram_* and legacy process-suffixed names such as fakeram7_*
are included.
Inputs on explicit power/ground nets are treated as supply-driven constants.
Each immutable output directory retains the validator, native Tcl, and logs.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--manifest', type=Path, required=True)
p.add_argument('--native', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
p.add_argument('--jobs', type=int, choices=range(1, 5), default=2)
a = p.parse_args()
manifest_bytes = a.manifest.read_bytes()
manifest = json.loads(manifest_bytes)
if not isinstance(manifest, dict) or not manifest:
    raise ValueError('Expected a nonempty physical-results manifest')
a.output.mkdir(parents=True, exist_ok=False)
validator = Path(__file__).read_bytes()
(a.output / 'validator.py').write_bytes(validator)
(a.output / 'source-manifest.json').write_bytes(manifest_bytes)

def sha(path):
    h = hashlib.sha256()
    with path.open('rb') as handle:
        for block in iter(lambda: handle.read(8 * 1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()

body = r'''
set block [ord::get_db_block]
set ram_count 0
set input_count 0
set missing 0
set driver_cache {}
foreach inst [$block getInsts] {
  set master [$inst getMaster]
  if {![regexp {^fakeram[0-9]*_} [$master getName]]} {continue}
  incr ram_count
  foreach pin [$inst getITerms] {
    if {[$pin getIoType] ne "INPUT"} {continue}
    set mterm [$pin getMTerm]
    if {[$mterm getSigType] in {POWER GROUND}} {continue}
    incr input_count
    set net [$pin getNet]
    set driven 0
    set net_name NULL
    if {$net ne "NULL"} {
      set net_name [$net getName]
      if {[dict exists $driver_cache $net_name]} {
        set driven [dict get $driver_cache $net_name]
      } else {
        if {[$net getSigType] in {POWER GROUND}} {set driven 1}
        foreach source [$net getBTerms] {
          if {[$source getIoType] in {INPUT INOUT}} {set driven 1}
        }
        foreach source [$net getITerms] {
          if {[$source getIoType] in {OUTPUT INOUT}} {set driven 1}
        }
        dict set driver_cache $net_name $driven
      }
    }
    if {!$driven} {
      incr missing
      puts [list RAM_MISSING [$master getName] [$inst getName] [$mterm getName] $net_name]
    }
  }
}
puts "RAM_SUMMARY $ram_count $input_count $missing"
'''

def check(entry):
    label, files = entry
    item = files['6_final.odb']
    db = (a.manifest.parent / item['path']).resolve()
    if sha(db) != item['sha256']:
        raise ValueError(f'Database differs from physical manifest: {label}')
    if any(c in str(db) for c in '{}\n\r'):
        raise ValueError('Unsupported database path')
    folder = a.output / label.removeprefix('//').replace(':', '/')
    folder.mkdir(parents=True)
    script = folder / 'check.tcl'
    script.write_text('read_db {' + str(db) + '}\n' + body)
    log = folder / 'check.log'
    with log.open('w') as output:
        code = subprocess.run([str(a.native.resolve()), '-exit', '-no_init',
                               '-threads', '1', str(script.resolve())],
                              stdout=output, stderr=subprocess.STDOUT).returncode
    lines = log.read_text().splitlines()
    summaries = [line.split()[1:] for line in lines if line.startswith('RAM_SUMMARY ')]
    if len(summaries) != 1 or len(summaries[0]) != 3:
        raise ValueError(f'Incomplete native audit ({code}): {label}; see {log}')
    rams, inputs, missing = map(int, summaries[0])
    errors = [line for line in lines if line.startswith('RAM_MISSING ')]
    if len(errors) != missing or (rams and not inputs):
        raise ValueError(f'Incomplete input enumeration: {label}')
    return label, {'passed': code == 0 and missing == 0, 'native_exit_code': code,
                   'fakerams_checked': rams, 'signal_inputs_checked': inputs,
                   'undriven_input_count': missing, 'undriven_inputs': errors,
                   'odb_sha256': item['sha256'], 'script_sha256': sha(script),
                   'log_sha256': sha(log), 'log': str(log.relative_to(a.output))}

with ThreadPoolExecutor(max_workers=a.jobs) as pool:
    results = dict(pool.map(check, sorted(manifest.items())))
record = {'passed': all(r['passed'] for r in results.values()),
          'targets_checked': len(results), 'results': results,
          'manifest_sha256': hashlib.sha256(manifest_bytes).hexdigest(),
          'manifest_files_root': str(a.manifest.parent.resolve()),
          'validator_sha256': hashlib.sha256(validator).hexdigest(),
          'native_sha256': sha(a.native),
          'scope': __doc__}
(a.output / 'result.json').write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps({'passed': record['passed'], 'targets_checked': len(results),
                  'targets_with_undriven_inputs': [k for k, v in results.items()
                                                   if not v['passed']]}))
raise SystemExit(0 if record['passed'] else 1)
