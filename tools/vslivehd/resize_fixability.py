#!/usr/bin/env python3
"""Resize study, measurement C: is a failing setup endpoint fixable at all?

  resize_fixability.py run KEY SOURCE       SOURCE: xchg | ours | ours_resize
  resize_fixability.py collect [KEY...]

For SOURCE xchg the input is OpenROAD's 3_place.odb (3_place.sdc); for ours/ours_resize it
is the LiveHD study_noresize/study_resize DEF with the same adapted SDC the common scorer
used. sta_fixability.tcl runs twice (MODE=rc with placement RC, MODE=ideal without
parasitics) on the 20 worst failing endpoints of the rc run.

Classes per endpoint (rc slack < 0):
  wire        ideal-wire slack >= 0 (fails only with wire RC: placement/buffering can fix it)
  sizing      strongest-drive path slack >= 0 with RC
  sizing+wire strongest-drive path slack >= 0 only with ideal wires
  unfixable   fails with ideal wires AND strongest drives on the (iterated) worst path
"""
import json, re, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import guard
import lhdsweep as ls
from resize_study import def_components, REBUF

STUDY = ls.SWEEP / 'resize_study'
FAM = re.compile(r'^(?P<base>.+?)x(?P<int>\d*)(?:p(?P<frac>\d+))?(?P<suf>f|DC)?_ASAP7_75t_R$')


def dont_use(name):
    import fnmatch
    return any(fnmatch.fnmatch(name, p) for p in ls.DONT_USE)


def strong_map(d):
    lib = ls.merged_liberty(d)
    names = sorted(set(re.findall(r'^\s*cell\s*\(\s*"?([A-Za-z0-9_]+)"?\s*\)', Path(lib).read_text(), re.M)))
    fam = {}
    for n in names:
        m = FAM.match(n)
        if not m:
            continue
        size = float((m['int'] or '0') + '.' + (m['frac'] or '0'))
        fam.setdefault(m['base'], []).append((size, n))
    out = STUDY / 'C' / ('strong_%s.tsv' % d.safe)
    out.parent.mkdir(parents=True, exist_ok=True)
    lines = []
    for base, members in fam.items():
        allowed = [x for x in members if not dont_use(x[1])]
        if not allowed:
            continue
        best = max(allowed)[1]
        for _, n in members:
            lines.append('%s\t%s' % (n, best))
    out.write_text('\n'.join(lines) + '\n')
    return out


def inputs(d, source):
    if source == 'xchg':
        return d.ref_dir / '3_place.odb', d.ref_dir / '3_place.sdc'
    if source == 'xchg_lhd':  # LiveHD's repaired exchange DEF (same names as the ODB)
        return STUDY / 'B' / d.safe / 'lhd/out.def', d.ref_dir / '3_place.sdc'
    tag = 'study_noresize' if source == 'ours' else 'study_resize'
    r = ls.SWEEP / 'runs' / d.safe / tag
    return sorted((r / 'def').glob('*.def'))[0], r / 'score_pins.sdc'


def run(d, source):
    o = STUDY / 'C' / d.safe / source
    o.mkdir(parents=True, exist_ok=True)
    guard.root = o
    src, sdc = inputs(d, source)
    env = ls.score_env(d, sdc)
    env = {k: env[k] for k in ('LIB_FILES', 'TECH_LEF', 'SC_LEF', 'ADDITIONAL_LEFS', 'SET_RC_TCL', 'SDC_FILE')}
    env.update(INPUT=str(src), STRONG_MAP=str(strong_map(d)), GUARD_MEMORY_LIMIT_GIB='64')
    cmd = [ls.OPENROAD, '-no_init', '-exit', '-threads', '1', ls.TOOLS / 'sta_fixability.tcl']
    tmo = 6 * 3600
    if source == 'xchg_lhd':
        guard.run('rc', cmd, cwd=o, timeout=tmo, extra_env=dict(env, MODE='rc', TOPN='0', LIST_PATHS='0', OUT=str(o / 'rc.tsv')))
        return
    if source == 'ours_resize':
        guard.run('rc', cmd, cwd=o, timeout=tmo, extra_env=dict(env, MODE='rc', TOPN='0', LIST_PATHS='50000', OUT=str(o / 'rc.tsv')))
        return
    guard.run('rc', cmd, cwd=o, timeout=tmo, extra_env=dict(env, MODE='rc', TOPN='20', LIST_PATHS='0', OUT=str(o / 'rc.tsv')))
    sel = [l.split('\t')[1] for l in (o / 'rc.tsv').read_text().splitlines() if l.startswith('P\t')]
    (o / 'select.txt').write_text('\n'.join(sel) + '\n')
    guard.run('ideal', cmd, cwd=o, timeout=tmo,
              extra_env=dict(env, MODE='ideal', SELECT_FILE=str(o / 'select.txt'), LIST_PATHS='0', OUT=str(o / 'ideal.tsv')))


def parse(path):
    E, P, S, I = {}, {}, {}, {}
    for line in Path(path).read_text().splitlines():
        t = line.split('\t')
        if t[0] == 'E':
            E[t[1]] = float(t[2])
        elif t[0] == 'P':
            P[t[1]] = dict(slack=float(t[2]), start=t[3], cells=[c.rsplit(':', 1) for c in t[4].split(' ') if c])
        elif t[0] == 'S' and len(t) >= 5:
            S[t[1]] = [float(t[2])] + [float(x) for x in t[3].split(',') if x]  # unmodified path first
        elif t[0] == 'I':
            I[t[1]] = dict(slack=float(t[2]), cells=[c.rsplit(':', 1) for c in t[3].split(' ') if c])
    return E, P, S, I


def classify(o):
    if not (o / 'rc.tsv').exists() or not (o / 'ideal.tsv').exists():
        return None
    Erc, Prc, Src, _ = parse(o / 'rc.tsv')
    Eid, Pid, Sid, _ = parse(o / 'ideal.tsv')
    fail = {k: v for k, v in Erc.items() if v < 0}
    tns_rc = sum(fail.values())
    tns_ideal = sum(min(0.0, Eid.get(k, 0.0)) for k in fail)
    rows = []
    for ep, p in Prc.items():
        s_rc, s_id = p['slack'], Eid.get(ep)
        # Best of the unmodified worst path and each strongest-drive round (upsizing can hurt).
        st_rc = max(Src.get(ep) or [s_rc])
        st_id = max(Sid.get(ep) or [s_id]) if s_id is not None else None
        if s_id is not None and s_id >= 0:
            cls = 'wire'
        elif st_rc >= 0:
            cls = 'sizing'
        elif st_id is not None and st_id >= 0:
            cls = 'sizing+wire'
        else:
            cls = 'unfixable'
        rows.append(dict(endpoint=ep, slack_rc=s_rc, slack_ideal=s_id, strong_rc=st_rc, strong_ideal=st_id, cls=cls,
                         depth=len(p['cells']), start=p['start']))
    hist = {}
    for r in rows:
        hist[r['cls']] = hist.get(r['cls'], 0) + 1
    return dict(failing=len(fail), tns_rc=tns_rc, tns_ideal_on_failing=tns_ideal,
                tns_ideal_share=(tns_ideal / tns_rc) if tns_rc else None,
                failing_ideal=sum(1 for k in fail if Eid.get(k, 0) < 0), top=rows, class_hist=hist,
                top_tns_rc=sum(r['slack_rc'] for r in rows),
                top_tns_unfixable=sum(r['slack_rc'] for r in rows if r['cls'] == 'unfixable'))


def attribute(d):
    """Resize-added/resized cells on post-resize failing paths, by the pre-resize class of the endpoint."""
    o = STUDY / 'C' / d.safe
    if not (o / 'ours_resize/rc.tsv').exists() or not (o / 'ours/ideal.tsv').exists():
        return None
    E0, _, _, _ = parse(o / 'ours/rc.tsv')
    Eid, _, _, _ = parse(o / 'ours/ideal.tsv')
    E1, _, _, I1 = parse(o / 'ours_resize/rc.tsv')
    c0 = def_components(sorted((ls.SWEEP / 'runs' / d.safe / 'study_noresize/def').glob('*.def'))[0])
    c1 = def_components(sorted((ls.SWEEP / 'runs' / d.safe / 'study_resize/def').glob('*.def'))[0])
    added = {n for n in c1 if n not in c0}
    resized = {n for n in c1 if n in c0 and c0[n] != c1[n]}
    on_path, on_unfix, rs_path, rs_unfix = set(), set(), set(), set()
    for ep, info in I1.items():
        unfix_wire = Eid.get(ep, 0.0) < 0  # still fails pre-resize with ideal wires
        for name, _ in info['cells']:
            if name in added:
                on_path.add(name)
                if unfix_wire:
                    on_unfix.add(name)
            if name in resized:
                rs_path.add(name)
                if unfix_wire:
                    rs_unfix.add(name)
    return dict(added=len(added), resized=len(resized), failing_after=sum(1 for v in E1.values() if v < 0),
                listed_paths=len(I1), added_on_failing_paths=len(on_path), added_on_wire_unfixable_paths=len(on_unfix),
                resized_on_failing_paths=len(rs_path), resized_on_wire_unfixable_paths=len(rs_unfix),
                failing_before=sum(1 for v in E0.values() if v < 0),
                tns_before=sum(v for v in E0.values() if v < 0), tns_after=sum(v for v in E1.values() if v < 0))


def agreement(d, source):
    """LiveHD's own timer vs OpenSTA (the scorer) on the same placement, per setup endpoint."""
    o = STUDY / 'C' / d.safe / source
    if source == 'ours':
        tj = ls.SWEEP / 'runs' / d.safe / 'study_noresize/w/synth/timing.json'
    else:  # source xchg_lhd: LiveHD's final timing on its own repaired exchange netlist
        tj = STUDY / 'B' / d.safe / 'lhd/final_timing.json'
    if not (o / 'rc.tsv').exists() or not tj.exists():
        return None
    E, _, _, _ = parse(o / 'rc.tsv')
    norm = lambda s: s.replace('\\', '')
    E = {norm(k): v for k, v in E.items()}
    t = json.loads(tj.read_text())['designs'][0]
    unit = t.get('time_unit_ps', 1) or 1
    lh = {norm(p['pin'].replace(':', '/')): p for p in t.get('physical_pins', [])}
    both = [k for k in E if k in lh and lh[k].get('slack') is not None]
    if not both:
        return dict(matched=0, sta_endpoints=len(E))
    diff = sorted(lh[k]['slack'] * unit - E[k] for k in both)
    lf = {k for k in both if lh[k]['slack'] < 0}
    sf = {k for k in both if E[k] < 0}
    return dict(timing_json=str(tj), sta_endpoints=len(E), matched=len(both),
                lhd_wns=t.get('wns'), lhd_tns=t.get('tns'), lhd_hold_wns=t.get('hold_wns'), lhd_max_delay=t.get('max_delay'),
                sta_wns=min(E.values()) if E else None, sta_tns=sum(v for v in E.values() if v < 0),
                lhd_failing=len(lf), sta_failing=len(sf), both_failing=len(lf & sf),
                median_slack_diff_ps=diff[len(diff) // 2], p10_diff=diff[len(diff) // 10], p90_diff=diff[9 * len(diff) // 10],
                worst_disagreements=[(k, lh[k]['slack'] * unit, E[k]) for k in sorted(both, key=lambda k: -abs(lh[k]['slack'] * unit - E[k]))[:5]])


def collect(keys):
    rows = []
    for d in ls.discover():
        if keys and d.key not in keys:
            continue
        o = STUDY / 'C' / d.safe
        if not o.exists():
            continue
        row = dict(design=d.key, xchg=classify(o / 'xchg'), ours=classify(o / 'ours'), attribution=attribute(d),
                   agreement_ours=agreement(d, 'ours'), agreement_xchg=agreement(d, 'xchg_lhd'))
        rows.append(row)
    (STUDY / 'C/collect_c.json').write_text(json.dumps(rows, indent=1))
    return rows


if __name__ == '__main__':
    if sys.argv[1] == 'run':
        run(ls.get(sys.argv[2]), sys.argv[3])
    elif sys.argv[1] == 'collect':
        for r in collect(sys.argv[2:]):
            print(r['design'])
            for k in ('xchg', 'ours'):
                c = r[k]
                if c:
                    print('  %-5s failing %d tns %.0f ideal-tns-share %s classes %s top-unfixable-tns %.0f/%.0f'
                          % (k, c['failing'], c['tns_rc'], c['tns_ideal_share'] and round(c['tns_ideal_share'], 3),
                             c['class_hist'], c['top_tns_unfixable'], c['top_tns_rc']))
            print('  attribution', r['attribution'])
