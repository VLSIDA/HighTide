#!/usr/bin/env python3
"""Check archived OpenROAD ASAP7 buffer/inverter inputs against their manifest.

This catches the observed CTS defect that leaves a driven output with no A
connection. It does not certify arbitrary net drivers or macro interfaces.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--manifest', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
if a.output.exists():
    raise FileExistsError(a.output)
validator_copy = a.output.with_name(a.output.name + '.validator.py')
if validator_copy.exists():
    raise FileExistsError(validator_copy)
validator_bytes = Path(__file__).read_bytes()
manifest_bytes = a.manifest.read_bytes()
manifest = json.loads(manifest_bytes)
if not isinstance(manifest, dict) or not manifest:
    raise ValueError('Expected a nonempty physical-results manifest')
start = re.compile(r'^\s*((?:BUF|INV)\w*ASAP7\w*)\s+(\S+)\s*\(')
port = re.compile(r'\.([A-Za-z_][A-Za-z_0-9]*)\s*\(([^()]*)\)')
results = {}
for label, files in manifest.items():
    item = files['6_final.v']
    path = a.manifest.parent / item['path']
    digest = hashlib.sha256()
    block = None
    count = 0
    missing = []
    with path.open('rb') as handle:
        for raw in handle:
            digest.update(raw)
            line = raw.decode('utf-8', errors='surrogateescape')
            if block is None:
                match = start.match(line)
                if match:
                    master, instance = match.groups()
                    block = line
            else:
                block += line
            if block is not None and ');' in block:
                pins = dict(port.findall(block))
                count += 1
                if pins.get('Y', '').strip() and not pins.get('A', '').strip():
                    missing.append({'master': master, 'instance': instance,
                                    'output_net': pins['Y'].strip()})
                block = None
    if block is not None or count == 0:
        raise ValueError(f'Incomplete or unsupported netlist: {label}')
    actual = digest.hexdigest()
    if actual != item['sha256']:
        raise ValueError(f'Netlist differs from physical archive manifest: {label}')
    results[label] = {'checked_buffers_and_inverters': count,
                      'missing_A_inputs': missing, 'netlist_sha256': actual}
record = {'passed': not any(r['missing_A_inputs'] for r in results.values()),
          'targets_checked': len(results), 'results': results,
          'manifest_sha256': hashlib.sha256(manifest_bytes).hexdigest(),
          'validator_sha256': hashlib.sha256(validator_bytes).hexdigest(),
          'validator_source': validator_copy.name,
          'scope': 'ASAP7 BUF/INV instances with connected Y require connected A; '
                   'not a general driver or macro-interface check.'}
a.output.parent.mkdir(parents=True, exist_ok=True)
validator_copy.write_bytes(validator_bytes)
a.output.write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps({'passed': record['passed'], 'targets_checked': len(results),
                  'targets_with_missing_inputs': [k for k, v in results.items()
                                                  if v['missing_A_inputs']]}))
raise SystemExit(0 if record['passed'] else 1)
