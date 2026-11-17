#!/usr/bin/env python3
"""Run a list of LiveHD variants for one design, N at a time.

  exp.py DESIGN specs.json [--jobs N] [--timeout S] [--mem-gib G]

specs.json: [{"tag": "name", "sets": {"key": "value", ...}}, ...]
A tag that already has a run directory is skipped, so a spec list can be rerun
after an interruption. Results land in results.jsonl via lhdsweep.run_variant.
"""
import argparse, json, sys, threading
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, __file__.rsplit('/', 1)[0])
import lhdsweep as L


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('design'); ap.add_argument('specs')
    ap.add_argument('--jobs', type=int, default=2)
    ap.add_argument('--timeout', type=int, default=3600)
    ap.add_argument('--mem-gib', type=float, default=48)
    a = ap.parse_args()
    d = L.get(a.design)
    specs = json.load(open(a.specs))
    lock = threading.Lock()

    def one(spec):
        if (L.SWEEP / 'runs' / d.safe / spec['tag']).exists():
            return
        try:
            r = L.run_variant(d, spec['tag'], spec.get('sets', {}), 1, a.timeout, a.mem_gib)
            s = r.get('score')
            with lock:
                if s:
                    print('%-28s wns=%9.1f tns=%11.1f cells=%7d pen=%9.3f  %s' % (spec['tag'], s['setup_wns_ps'], s['setup_tns_ps'], s['logical_cells'], r['penalty'], r['meta']['status']), flush=True)
                else:
                    print('%-28s %s' % (spec['tag'], r['meta']['status']), flush=True)
        except BaseException as exc:
            with lock:
                print('%-28s ERROR %s' % (spec['tag'], exc), flush=True)

    with ThreadPoolExecutor(a.jobs) as ex:
        list(ex.map(one, specs))


if __name__ == '__main__':
    main()
