#!/usr/bin/env python3
"""Coordinate-descent tuning of LiveHD options for one design.

  tune.py DESIGN [--rounds N] [--jobs J] [--timeout S] [--factors f1,f2,...]
          [--start k=v,...]  [--tag-prefix P]

Objective (lowest wins): (penalty, logic cells) where penalty is 0 exactly when
setup timing is met (lhdsweep.penalty). Each round visits the factors in order; for
a factor it runs every alternative value with the other factors held at the current
best (J at a time) and keeps the best strictly better configuration. A run is named
by the hash of its option set, so identical configurations are never rerun and the
whole search is resumable. The search log is runs/<design>/tune_log.jsonl.
"""
import argparse, hashlib, json, sys, threading
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, __file__.rsplit('/', 1)[0])
import lhdsweep as L

# factor -> candidate values; '' means "leave the option unset" (the LiveHD default)
FACTORS = {
    'pass.abc.max_fanout': ['', '24', '32', '48'],
    'synth.place.resize': ['', 'true'],
    'synth.delay_frac': ['', '0.3', '0.4', '0.5', '0.7', '1.0'],
    'pass.abc.area_relax': ['', '100', '50', '0'],
    'pass.abc.adder': ['', 'prefix', 'cla'],
    'synth.place.density': ['', '0.5', '0.6', '0.7', '0.8'],
    'synth.place.resynth': ['', 'true'],
    'synth.mapper': ['', 'usyn'],
}
DEFAULT_ORDER = ['pass.abc.max_fanout', 'synth.place.resize', 'synth.delay_frac', 'pass.abc.area_relax',
                 'pass.abc.adder', 'synth.place.density', 'synth.place.resynth', 'synth.mapper']


def key_of(sets):
    clean = {k: v for k, v in sets.items() if v != ''}
    return hashlib.md5(json.dumps(clean, sort_keys=True).encode()).hexdigest()[:10], clean


def known_results():
    out = {}
    f = L.SWEEP / 'results.jsonl'
    if f.exists():
        for line in f.read_text().splitlines():
            r = json.loads(line)
            out[(r['design'], r['tag'])] = r
    return out


def objective(r):
    if not r or not r.get('score'):
        return (float('inf'), float('inf'))
    p = r['penalty'] if r['penalty'] is not None else float('inf')
    return (p, r['score']['logical_cells'])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('design')
    ap.add_argument('--rounds', type=int, default=2)
    ap.add_argument('--jobs', type=int, default=3)
    ap.add_argument('--timeout', type=int, default=3600)
    ap.add_argument('--mem-gib', type=float, default=48)
    ap.add_argument('--factors', default=','.join(DEFAULT_ORDER))
    ap.add_argument('--start', default='')
    ap.add_argument('--tag-prefix', default='t_')
    a = ap.parse_args()
    d = L.get(a.design)
    order = a.factors.split(',')
    best = dict(x.split('=', 1) for x in a.start.split(',') if x)
    lock = threading.Lock()
    log = open(L.SWEEP / 'runs' / ('%s_tune_log.jsonl' % d.safe), 'a')

    def evaluate(sets):
        h, clean = key_of(sets)
        tag = a.tag_prefix + h
        results = known_results()
        r = results.get((d.key, tag))
        if r is None:
            if (L.SWEEP / 'runs' / d.safe / tag).exists():
                return (float('inf'), float('inf')), tag  # a failed/incomplete earlier attempt
            try:
                full = L.run_variant(d, tag, clean, 1, a.timeout, a.mem_gib)
                r = dict(score=full.get('score'), penalty=full.get('penalty'))
            except BaseException as exc:
                print('ERROR', tag, exc, flush=True)
                r = None
        obj = objective(r)
        with lock:
            log.write(json.dumps(dict(tag=tag, sets=clean, objective=obj)) + '\n'); log.flush()
            print('%-14s pen=%-10.3f cells=%-8s %s' % (tag, obj[0], obj[1], clean), flush=True)
        return obj, tag

    best_obj, _ = evaluate(best)
    print('START', best_obj, best, flush=True)
    for rnd in range(a.rounds):
        improved = False
        for f in order:
            cands = []
            for v in FACTORS[f]:
                if (best.get(f, '') == v):
                    continue
                c = dict(best); c[f] = v
                cands.append(c)
            with ThreadPoolExecutor(a.jobs) as ex:
                res = list(ex.map(evaluate, cands))
            for c, (obj, tag) in zip(cands, res):
                if obj < best_obj:
                    best_obj, best, improved = obj, {k: v for k, v in c.items() if v != ''}, True
            print('ROUND %d factor %-22s best=%s %s' % (rnd, f, best_obj, best), flush=True)
        if not improved:
            break
    print('FINAL', best_obj, json.dumps(best), flush=True)


if __name__ == '__main__':
    main()
