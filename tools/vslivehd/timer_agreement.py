#!/usr/bin/env python3
"""LiveHD's timer (OpenTimer in a frozen physical_repair) vs OpenSTA on the exchange inputs.

  timer_agreement.py run TAG KEY --bin NAME     timing-only LiveHD report of resize_study/B/<d> input
  timer_agreement.py table TAG [KEY...]         per-endpoint agreement against OpenSTA

OpenSTA endpoint slacks come from resize_study/C/<d>/xchg/rc.tsv (sta_fixability.tcl on the same
3_place.odb); missing ones are produced here with MODE=rc. Output: resize_study/E/agree_<TAG>/<d>/.
"""
import json, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import guard
import lhdsweep as ls
import resize_exchange as rx
import resize_fixability as fx

STUDY = ls.SWEEP / 'resize_study'


def out_dir(tag, d):
    return STUDY / 'E' / ('agree_' + tag) / d.safe


def sta_tsv(tag, d):
    p = STUDY / 'C' / d.safe / 'xchg/rc.tsv'
    if p.exists():
        return p
    o = out_dir(tag, d) / 'sta'
    o.mkdir(parents=True, exist_ok=True)
    if not (o / 'rc.tsv').exists():
        guard.root = o
        src, sdc = fx.inputs(d, 'xchg')
        env = ls.score_env(d, sdc)
        env = {k: env[k] for k in ('LIB_FILES', 'TECH_LEF', 'SC_LEF', 'ADDITIONAL_LEFS', 'SET_RC_TCL', 'SDC_FILE')}
        env.update(INPUT=str(src), STRONG_MAP=str(fx.strong_map(d)), GUARD_MEMORY_LIMIT_GIB='64', MODE='rc', TOPN='0',
                   LIST_PATHS='0', OUT=str(o / 'rc.tsv'))
        guard.run('rc', [ls.OPENROAD, '-no_init', '-exit', '-threads', '1', ls.TOOLS / 'sta_fixability.tcl'], cwd=o,
                  timeout=6 * 3600, extra_env=env)
    return o / 'rc.tsv'


def run(tag, d, binary):
    o = out_dir(tag, d)
    o.mkdir(parents=True, exist_ok=True)
    guard.root = o
    b = rx.out_dir(d)
    cfg = json.loads((b / 'lhd_repair.json').read_text())
    cfg['output'] = str(o / 'lhd')
    cfg['timing_only'] = True
    (o / 'lhd_timing.json').write_text(json.dumps(cfg, indent=1))
    pr = ls.SWEEP / 'bin' / binary
    guard.run('lhd_timing', [pr / 'physical_repair', o / 'lhd_timing.json'], cwd=o, timeout=6 * 3600,
              extra_env={'GUARD_MEMORY_LIMIT_GIB': '64', 'RUNFILES_DIR': str(pr / 'physical_repair.runfiles')})
    sta_tsv(tag, d)


def compare(tag, d):
    tj = out_dir(tag, d) / 'lhd/final_timing.json'
    if not tj.exists():
        return None
    E, _, _, _ = fx.parse(sta_tsv(tag, d))
    norm = lambda s: s.replace('\\', '')
    E = {norm(k): v for k, v in E.items()}
    t = json.loads(tj.read_text())['designs'][0]
    unit = t.get('time_unit_ps', 1) or 1
    lh = {norm(p['pin'].replace(':', '/')): p for p in t.get('physical_pins', [])}
    both = [k for k in E if k in lh and lh[k].get('slack') is not None]
    diff = sorted(lh[k]['slack'] * unit - E[k] for k in both)
    lf = {k for k in both if lh[k]['slack'] < 0}
    sf = {k for k in both if E[k] < 0}
    q = lambda f: diff[min(len(diff) - 1, int(f * len(diff)))] if diff else None
    return dict(design=d.key, sta_endpoints=len(E), matched=len(both), lhd_failing=len(lf), sta_failing=len(sf),
                both_failing=len(lf & sf), lhd_wns=(t.get('wns') or 0) * unit, sta_wns=min(E.values()) if E else None,
                lhd_tns=(t.get('tns') or 0) * unit, sta_tns=sum(v for v in E.values() if v < 0),
                lhd_hold_wns=(t.get('hold_wns') or 0) * unit, median_diff=q(.5), p10_diff=q(.1), p90_diff=q(.9),
                worst=[(k, lh[k]['slack'] * unit, E[k]) for k in sorted(both, key=lambda k: -abs(lh[k]['slack'] * unit - E[k]))[:3]])


def table(tag, keys):
    rows = [r for r in (compare(tag, d) for d in ls.discover() if not keys or d.key in keys) if r]
    print('%-18s %7s %7s %7s %9s %9s %11s %11s %8s %8s %8s %9s' % ('design', 'matched', 'lhdF', 'staF', 'lhdWNS', 'staWNS', 'lhdTNS',
                                                                   'staTNS', 'med', 'p10', 'p90', 'lhdHold'))
    for r in rows:
        print('%-18s %7d %7d %7d %9.1f %9.1f %11.0f %11.0f %8.1f %8.1f %8.1f %9.1f' % (
            r['design'][:18], r['matched'], r['lhd_failing'], r['sta_failing'], r['lhd_wns'], r['sta_wns'], r['lhd_tns'],
            r['sta_tns'], r['median_diff'], r['p10_diff'], r['p90_diff'], r['lhd_hold_wns']))
    (STUDY / 'E' / ('agree_' + tag) / 'table.json').write_text(json.dumps(rows, indent=1))
    return rows


if __name__ == '__main__':
    if sys.argv[1] == 'run':
        run(sys.argv[2], ls.get(sys.argv[3]), sys.argv[sys.argv.index('--bin') + 1])
    elif sys.argv[1] == 'table':
        table(sys.argv[2], sys.argv[3:])
