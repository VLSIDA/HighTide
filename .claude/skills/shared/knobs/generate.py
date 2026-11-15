#!/usr/bin/env python3
"""Regenerate the per-stage ORFS knob references from variables.json.

Usage:
  python3 generate.py <path-to>/external/orfs+/flow/scripts/variables.json

Everything ABOVE the '<!-- GENERATED-LIST -->' marker in each existing
<stage>.md (the hand-curated sections: command-level *_ARGS tables, tuning
lore) is preserved; the list below the marker is rewritten from the JSON.
Run on every toolchain bump so the lists match the pinned ORFS.
"""
import json
import os
import sys

STAGES = {
    'synth': 'Synthesis (yosys/abc)',
    'floorplan': 'Floorplan (init_floorplan, macro placement/RTLMP, PDN, IO)',
    'place': 'Placement (GPL global + DPL detailed)',
    'cts': 'Clock tree synthesis',
    'grt': 'Global routing (+ post-GRT repair)',
    'route': 'Detailed routing (+ antenna repair)',
    'final': 'Finishing (fill, extraction, GDS, reports)',
}
MARKER = '<!-- GENERATED-LIST -->'

def main(json_path):
    d = json.load(open(json_path))
    outdir = os.path.dirname(os.path.abspath(__file__))
    for st, title in STAGES.items():
        rows = []
        for k, v in sorted(d.items()):
            if st in v.get('stages', []) or 'All stages' in v.get('stages', []):
                desc = ' '.join((v.get('description') or '').split())
                dflt = v.get('default', '')
                dflt = f" (default: `{dflt}`)" if dflt not in ('', None) else ''
                rows.append(f"- **`{k}`**{dflt}: {desc}")
        path = os.path.join(outdir, f'{st}.md')
        head = f"# {title} — ORFS knobs\n\n"
        if os.path.exists(path):
            cur = open(path).read()
            if MARKER in cur:
                head = cur.split(MARKER)[0]
        open(path, 'w').write(head + MARKER + '\n' + '\n'.join(rows) + '\n')
        print(f'{st}: {len(rows)} knobs')

if __name__ == '__main__':
    main(sys.argv[1])
