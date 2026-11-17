#!/usr/bin/env python3
"""Resize study, measurement B: shared-input repair exchange on OpenROAD's 3_place.odb.

  resize_exchange.py run KEY [--steps export,score_input,or,lhd]   (all steps by default)
  resize_exchange.py collect [KEY...]

Output: artifacts/lhdsweep/resize_study/B/<design>/
  input.def                 3_place.odb exported unchanged (frozen openroad, write_def)
  score_input/              common scorer on input.def (must reproduce ref/<design>/score)
  or/                       or_repair_setup.tcl: repair_design + repair_timing -setup + DP
  score_or/                 common scorer on or/repaired.odb
  lhd/                      frozen physical_repair (source_def, retained placement, sizing + design repair)
  score_lhd/                common scorer on lhd/out.def
"""
import json, os, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import guard
import lhdsweep as ls
from resize_study import def_components, logical, REBUF

STUDY = ls.SWEEP / 'resize_study'
PR = ls.SWEEP / 'bin/physical_repair_g'
TOP_SDC = 'constraint.sdc'  # LiveHD's SDC reader rejects OpenSTA write_sdc output (3_place.sdc)
TIMEOUT = {'eyeriss': 6 * 3600}


def out_dir(d):
    return STUDY / 'B' / d.safe


def run(d, steps):
    o = out_dir(d)
    o.mkdir(parents=True, exist_ok=True)
    guard.root = o
    info = json.loads((d.ref_dir / 'info.json').read_text())
    tmo = TIMEOUT.get(d.key, 3 * 3600)
    env64 = {'GUARD_MEMORY_LIMIT_GIB': '64', 'OMP_NUM_THREADS': '1'}
    if 'export' in steps and not (o / 'input.def').exists():
        guard.run('export', [ls.OPENROAD, '-no_init', '-exit', '-threads', '1', ls.TOOLS / 'or_export_def.tcl'], cwd=o,
                  timeout=tmo, extra_env=dict(env64, INPUT_ODB=str(d.ref_dir / '3_place.odb'), OUTPUT_DEF=str(o / 'input.def')))
    if 'score_input' in steps:
        ls.run_score(d, o / 'input.def', o / 'score_input', d.ref_dir / '3_place.sdc', timeout=tmo)
    if 'or' in steps:
        env = dict(env64, INPUT_ODB=str(d.ref_dir / '3_place.odb'), LIB_FILES=' '.join(info['lib_files']),
                   SDC_FILE=str(d.ref_dir / '3_place.sdc'), SET_RC_TCL=str(ls.PLATFORM / 'setRC.tcl'),
                   DONT_USE=' '.join(ls.DONT_USE), OUT=str(o / 'or'))
        try:
            guard.run('or_repair', [ls.OPENROAD, '-no_init', '-exit', '-threads', '1', ls.TOOLS / 'or_repair_setup.tcl'],
                      cwd=o, timeout=tmo, extra_env=env)
            ls.run_score(d, o / 'or/repaired.odb', o / 'score_or', d.ref_dir / '3_place.sdc', timeout=tmo)
        except Exception as exc:
            print('openroad repair failed:', exc, flush=True)
    if 'lhd' in steps:
        cfg = dict(top=d.name, source_def=True, liberty=str(ls.merged_liberty(d)),
                   lefs=[str(p) for p in d.lef_list()], sdc=str(d.ref_dir / TOP_SDC),
                   tech_rc=str(ls.PLATFORM / 'setRC.tcl'), halo=0, output=str(o / 'lhd'))
        src = o / 'input.def'
        text = src.read_text()
        if '\nBLOCKAGES ' in text:  # LiveHD's DEF reader refuses BLOCKAGES (no row-segment support)
            head, rest = text.split('\nBLOCKAGES ', 1)
            src = o / 'input_noblockages.def'
            src.write_text(head + '\n' + rest.split('END BLOCKAGES\n', 1)[1])
        text = src.read_text()
        rows = [l for l in text.splitlines() if l.startswith('ROW ')]
        merged = merge_rows(rows)
        if len(merged) != len(rows):  # LiveHD requires contiguous rows; OpenROAD cuts rows at macros
            body = [l for l in text.splitlines() if not l.startswith('ROW ')]
            i = next(k for k, l in enumerate(text.splitlines()) if l.startswith('ROW '))
            src = o / 'input_lhd.def'
            src.write_text('\n'.join(body[:i] + merged + body[i:]) + '\n')
        cfg['def'] = str(src)
        (o / 'lhd_repair.json').write_text(json.dumps(cfg, indent=1))
        try:
            guard.run('lhd_repair', [PR / 'physical_repair', o / 'lhd_repair.json'], cwd=o, timeout=tmo,
                      extra_env=dict(env64, RUNFILES_DIR=str(PR / 'physical_repair.runfiles')))
            ls.run_score(d, o / 'lhd/out.def', o / 'score_lhd', d.ref_dir / '3_place.sdc', timeout=tmo)
        except Exception as exc:
            print('livehd repair failed:', exc, flush=True)


def merge_rows(rows):
    """One row per y spanning all of that y's segments (same site/orientation/step)."""
    by = {}
    for l in rows:
        t = l.split()  # ROW name site x y orient DO n BY 1 STEP sx sy ;
        x, y, n, sx = int(t[3]), int(t[4]), int(t[7]), int(t[11])
        e = by.setdefault(y, dict(name=t[1], site=t[2], orient=t[5], sx=sx, sy=t[12], lo=x, hi=x + n * sx))
        if (t[2], t[5], sx) != (e['site'], e['orient'], e['sx']):
            raise RuntimeError('incompatible row segments at y=%d' % y)
        e['lo'], e['hi'] = min(e['lo'], x), max(e['hi'], x + n * sx)
    return ['ROW %s %s %d %d %s DO %d BY 1 STEP %d %s ;' % (e['name'], e['site'], e['lo'], y, e['orient'],
                                                           (e['hi'] - e['lo']) // e['sx'], e['sx'], e['sy'])
            for y, e in sorted(by.items())]


def diff(before, after):
    b, a = logical(before), logical(after)
    common = set(a) & set(b)
    added = set(a) - set(b)
    return dict(cells_before=len(b), cells_after=len(a), added=len(added), removed=len(set(b) - set(a)),
                resized=sum(1 for n in common if a[n] != b[n]),
                added_buffers=sum(1 for n in added if a[n].upper().startswith(('BUF', 'HB')) or REBUF in n))


def collect(keys):
    rows = []
    for d in ls.discover():
        if keys and d.key not in keys:
            continue
        o = out_dir(d)
        if not (o / 'input.def').exists():
            continue
        row = dict(design=d.key)
        inp = def_components(o / 'input.def')
        for tag, path, score in (('or', o / 'or/repaired.def', o / 'score_or/score.json'),
                                 ('lhd', o / 'lhd/out.def', o / 'score_lhd/score.json')):
            if path.exists():
                row[tag] = diff(inp, def_components(path))
            if score.exists():
                row[tag + '_score'] = json.loads(score.read_text())
        for tag, f in (('input_score', o / 'score_input/score.json'), ('or_runtime', o / 'or/runtime.json'),
                       ('lhd_runtime', o / 'lhd/runtime.json')):
            if f.exists():
                row[tag] = json.loads(f.read_text())
        for f in ('resize', 'repair'):
            p = o / 'lhd' / (f + '.json')
            if p.exists():
                t = json.loads(p.read_text())
                row['lhd_' + f] = {k: v for k, v in t.items() if k != 'trials'}
                row['lhd_' + f]['trials'] = len(t['trials'])
                row['lhd_' + f]['accepted_trials'] = [
                    {k: x.get(k) for k in ('action', 'changed', 'upsized', 'downsized', 'buffers')} for x in t['trials'] if x.get('accepted')]
        ft = o / 'lhd/final_timing.json'
        if ft.exists():
            x = json.loads(ft.read_text())['designs'][0]
            row['lhd_internal_final'] = {k: x.get(k) for k in ('wns', 'tns', 'hold_wns', 'max_delay', 'critical_pin')}
        rows.append(row)
    (STUDY / 'B').mkdir(parents=True, exist_ok=True)
    (STUDY / 'B/collect_b.json').write_text(json.dumps(rows, indent=1))
    return rows


if __name__ == '__main__':
    if sys.argv[1] == 'run':
        steps = sys.argv[sys.argv.index('--steps') + 1].split(',') if '--steps' in sys.argv else ['export', 'score_input', 'or', 'lhd']
        run(ls.get(sys.argv[2]), steps)
    elif sys.argv[1] == 'collect':
        for r in collect(sys.argv[2:]):
            print(json.dumps(r)[:600])
