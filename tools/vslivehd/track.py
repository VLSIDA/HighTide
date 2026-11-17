#!/usr/bin/env python3
"""Per-design gap between a tagged LiveHD sweep and the OpenROAD reference (pre-CTS, common OpenSTA scorer).

  track.py TAG [TAG...]     one row per design; with several tags the LAST one that has a scored run wins

Columns: setup WNS/TNS in ps (negative = violated), logic cells, HPWL in um. `verdict` compares setup timing
only: better (WNS and TNS at least as good), worse (both worse), mixed."""
import json, sys
from pathlib import Path

RESULTS = Path('/lscratch/renau/HighTide/artifacts/lhdsweep/results.jsonl')


def main():
    tags = sys.argv[1:]
    if not tags:
        sys.exit(__doc__)
    rows = [json.loads(l) for l in RESULTS.open()]
    ref, best, state = {}, {}, {}
    for r in rows:
        ref.setdefault(r['design'], r['ref'])
        if r['tag'] in tags:
            state[r['design']] = r['status'][:40]
            if r.get('score') and r['score'].get('setup_wns_ps') is not None:
                best[r['design']] = r
    fmt = '%-22s %9s %11s %7s | %9s %11s %7s %8s | %-7s %s'
    print(fmt % ('design', 'ref_wns', 'ref_tns', 'ref_c', 'wns', 'tns', 'cells', 'hpwl/ref', 'verdict', 'tag'))
    tally = {'better': 0, 'worse': 0, 'mixed': 0, 'no result': 0}
    for d in sorted(ref):
        f = ref[d]
        r = best.get(d)
        if not r:
            tally['no result'] += 1
            print(fmt % (d, '%.0f' % f['setup_wns_ps'], '%.0f' % f['setup_tns_ps'], f['logical_cells'], '-', '-', '-', '-',
                         'none', state.get(d, 'not run')))
            continue
        s = r['score']
        w, t = s['setup_wns_ps'] >= f['setup_wns_ps'] - 1, s['setup_tns_ps'] >= f['setup_tns_ps'] - 1
        # both meet timing: equal
        if s['setup_wns_ps'] >= 0 and f['setup_wns_ps'] >= 0:
            w = t = True
        verdict = 'better' if w and t else 'worse' if not w and not t else 'mixed'
        tally[verdict] += 1
        print(fmt % (d, '%.0f' % f['setup_wns_ps'], '%.0f' % f['setup_tns_ps'], f['logical_cells'], '%.0f' % s['setup_wns_ps'],
                     '%.0f' % s['setup_tns_ps'], s['logical_cells'], '%.2f' % (s['hpwl_um'] / f['hpwl_um']), verdict, r['tag']))
    print(', '.join('%s %d' % kv for kv in tally.items()))


if __name__ == '__main__':
    main()
