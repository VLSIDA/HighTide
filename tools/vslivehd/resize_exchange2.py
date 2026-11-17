#!/usr/bin/env python3
"""Resize re-implementation: shared-input exchange with a chosen frozen physical_repair build.

  resize_exchange2.py run TAG KEY --bin NAME [--engine new|legacy] [--set k=v ...]
  resize_exchange2.py table TAG [KEY...]        (input / OpenROAD / LiveHD-legacy (B) / LiveHD TAG)

Reuses measurement B's input.def, OpenROAD repair and scores (resize_study/B/<design>), and writes
the LiveHD run of TAG to resize_study/E/<TAG>/<design>/{lhd,score_lhd} (never overwrites B).
"""
import json, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import guard
import lhdsweep as ls
from resize_study import def_components, logical, REBUF
import resize_exchange as rx

STUDY = ls.SWEEP / 'resize_study'
DONT_USE = ls.DONT_USE


def out_dir(tag, d):
    return STUDY / 'E' / tag / d.safe


def run(tag, d, binary, engine, extra):
    b = rx.out_dir(d)
    o = out_dir(tag, d)
    if (o / 'score_lhd/score.json').exists():
        raise SystemExit('%s exists; pick a new TAG' % o)
    o.mkdir(parents=True, exist_ok=True)
    guard.root = o
    src = b / 'input_lhd.def'
    if not src.exists():
        src = b / 'input_noblockages.def'
    if not src.exists():
        src = b / 'input.def'
    cfg = json.loads((b / 'lhd_repair.json').read_text())
    cfg.update(output=str(o / 'lhd'), def_=None)
    cfg.pop('def_')
    cfg['def'] = str(src)
    cfg['resize_engine'] = engine
    cfg['dont_use'] = DONT_USE
    for k, v in extra.items():
        cfg[k] = v
    (o / 'lhd_repair.json').write_text(json.dumps(cfg, indent=1))
    pr = ls.SWEEP / 'bin' / binary
    tmo = rx.TIMEOUT.get(d.key, 3 * 3600)
    guard.run('lhd_repair', [pr / 'physical_repair', o / 'lhd_repair.json'], cwd=o, timeout=tmo,
              extra_env={'GUARD_MEMORY_LIMIT_GIB': '64', 'OMP_NUM_THREADS': '1',
                         'RUNFILES_DIR': str(pr / 'physical_repair.runfiles')})
    ls.run_score(d, o / 'lhd/out.def', o / 'score_lhd', d.ref_dir / '3_place.sdc', timeout=tmo)


def score(path):
    p = Path(path)
    return json.loads(p.read_text()) if p.exists() else None


def row(tag, d):
    b = rx.out_dir(d)
    inp = logical(def_components(b / 'input.def'))
    r = dict(design=d.key, cells=len(inp))
    for name, deff, sc, rt in (('input', None, b / 'score_input/score.json', None),
                               ('openroad', b / 'or/repaired.def', b / 'score_or/score.json', b / 'or/runtime.json'),
                               ('legacy', b / 'lhd/out.def', b / 'score_lhd/score.json', b / 'lhd/runtime.json'),
                               (tag, out_dir(tag, d) / 'lhd/out.def', out_dir(tag, d) / 'score_lhd/score.json',
                                out_dir(tag, d) / 'lhd/runtime.json')):
        s = score(sc)
        e = dict(wns=s and s['setup_wns_ps'], tns=s and s['setup_tns_ps'], hold=s and s['hold_wns_ps'])
        if deff is not None and Path(deff).exists():
            a = logical(def_components(deff))
            e['added'] = len(set(a) - set(inp))
            e['removed'] = len(set(inp) - set(a))
            e['resized'] = sum(1 for n in set(a) & set(inp) if a[n] != inp[n])
            e['cells_pct'] = 100.0 * (len(a) - len(inp)) / len(inp)
        t = score(rt) if rt else None
        if t:
            if name == 'openroad':
                e['runtime_s'] = t.get('repair_design_s', 0) + t.get('repair_timing_s', 0) + t.get('detailed_placement_s', 0)
            else:
                e['runtime_s'] = t.get('resize_s', t.get('sizing_s', 0) + t.get('repair_s', 0))
        r[name] = e
    return r


def table(tag, keys):
    rows = []
    for d in ls.discover():
        if keys and d.key not in keys:
            continue
        if not (out_dir(tag, d) / 'lhd').exists():
            continue
        rows.append(row(tag, d))
    fmt = lambda e: '%8s %10s %+6.2f%% %6s' % (
        '%.1f' % e['wns'] if e.get('wns') is not None else '-', '%.0f' % e['tns'] if e.get('tns') is not None else '-',
        e.get('cells_pct', 0.0), '%.0fs' % e['runtime_s'] if e.get('runtime_s') is not None else '-')
    print('%-20s | %-34s | %-34s | %-34s | %-34s' % ('design', 'input', 'openroad', 'legacy', tag))
    for r in rows:
        print('%-20s | %s | %s | %s | %s' % (r['design'][:20], fmt(r['input']), fmt(r['openroad']), fmt(r['legacy']), fmt(r[tag])))
    (STUDY / 'E' / tag / 'table.json').write_text(json.dumps(rows, indent=1))
    return rows


if __name__ == '__main__':
    if sys.argv[1] == 'run':
        tag, key = sys.argv[2], sys.argv[3]
        binary = sys.argv[sys.argv.index('--bin') + 1]
        engine = sys.argv[sys.argv.index('--engine') + 1] if '--engine' in sys.argv else 'new'
        extra = {}
        for i, a in enumerate(sys.argv):
            if a == '--set':
                k, v = sys.argv[i + 1].split('=', 1)
                extra[k] = json.loads(v)
        run(tag, ls.get(key), binary, engine, extra)
    elif sys.argv[1] == 'table':
        table(sys.argv[2], sys.argv[3:])
