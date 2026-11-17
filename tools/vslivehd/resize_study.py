#!/usr/bin/env python3
"""Resize study (measurement only): job generation and data collection.

  resize_study.py jobs-a [KEY...]      print queue lines for measurement A (our flow)
  resize_study.py collect-a [KEY...]   tables for A from the run directories

Every run uses the frozen lhd_g binary, the design_config options, the tune-up's best
non-resize options (todo/tuneup.html), synth.place.fp=true, and resize false/true.
"""
import json, os, re, sys
from pathlib import Path

HT = Path('/lscratch/renau/HighTide')
SWEEP = HT / 'artifacts/lhdsweep'
STUDY = SWEEP / 'resize_study'
TOOLS = HT / 'tools/vslivehd'
LHD = SWEEP / 'bin/lhd_g/lhd'

# Tune-up (todo/tuneup.html) options per design, minus synth.place.resize. Options already in
# design_config.json (slang flags, timing_driven=false on litepci) are applied by lhdsweep itself.
TUNEUP = {
    'NVDLA/partition_m': {'pass.usyn.reset_fanout': '32', 'synth.mapper': 'usyn'},
    'NVDLA/partition_a': {'compile.specialize_modules': 'true', 'pass.abc.large_flow_latches': 'true',
                          'synth.merge_registers': 'true', 'synth.partition': 'coarse',
                          'synth.place.repair.reset': 'true', 'synth.state_sweep': 'true'},
    'liteeth': {'compile.specialize_modules': 'true', 'synth.place.repair.reset': 'true'},
    # utilization 0.45 is part of the tune-up run (the page omits it); 0.75 fails macro legalization.
    'litepci': {'compile.specialize_modules': 'true', 'synth.place.utilization': '0.45', 'pass.abc.large_flow_latches': 'true', 'synth.merge_registers': 'true', 'synth.partition': 'coarse',
                'synth.place.repair.reset': 'true', 'synth.state_sweep': 'true'},
    'NVDLA/partition_p': {'pass.abc.max_fanout': '48', 'pass.abc.reset_fanout': '32', 'synth.place.reset_fanout': '32'},
    'coralnpu': {'compile.specialize_modules': 'true', 'pass.abc.large_flow_latches': 'true', 'synth.delay_frac': '0.5',
                 'synth.merge_registers': 'true', 'synth.partition': 'coarse', 'synth.place.repair.reset': 'true',
                 'synth.state_sweep': 'true'},
    # Master's FP snap refuses eyeriss ("could not contain centroid circles inside the core"), so the
    # snap is bypassed; FP resize at the default 50-iteration cadence costs >35 min per checkpoint
    # (first checkpoint never finished), so FP timing runs every 250 iterations (6 checkpoints).
    'eyeriss': {'synth.place.fp.snap': 'false', 'synth.place.fp.timing_interval': '250'},
}
COMMON = {'synth.place.fp': 'true'}
TIMEOUT = {'eyeriss': 43200, 'coralnpu': 14400}


def sets(key, resize):
    s = dict(TUNEUP[key])
    s.update(COMMON)
    s['synth.place.resize'] = 'true' if resize else 'false'
    return s


def jobs_a(keys):
    for key in keys or TUNEUP:
        for resize in (False, True):
            tag = 'study_resize' if resize else 'study_noresize'
            cmd = [sys.executable, str(TOOLS / 'lhdsweep.py'), 'run', key, tag, '--timeout', str(TIMEOUT.get(key, 7200))]
            if key == 'eyeriss' and resize:
                cmd += ['--mem-gib', '160']  # the default 64 GiB guard stopped FP resize in its first checkpoint
            for k, v in sets(key, resize).items():
                cmd += ['--set', '%s=%s' % (k, v)]
            print(json.dumps(dict(id='A_%s_%s' % (key.replace('/', '__'), tag), cmd=cmd, cwd=str(TOOLS), env={'LHD': str(LHD)})))


def def_components(path):
    """{instance: master} from a DEF COMPONENTS section (escaped names kept verbatim)."""
    out, inside = {}, False
    with open(path) as f:
        for line in f:
            if line.startswith('COMPONENTS'):
                inside = True
                continue
            if line.startswith('END COMPONENTS'):
                break
            if inside:
                t = line.split()
                if len(t) >= 3 and t[0] == '-':
                    out[t[1]] = t[2]
    return out


PHYSICAL = re.compile(r'^(TAPCELL|FILLER|FILLERxp|DECAP)', re.I)
REBUF = '__place_rebuffer_'


def logical(comps):
    return {k: v for k, v in comps.items() if not PHYSICAL.match(v)}


def rebuffer_depth(name):
    return name.count(REBUF)


def load(path):
    return json.loads(Path(path).read_text()) if Path(path).exists() else None


def run_dir(key, tag):
    return SWEEP / 'runs' / key.replace('/', '__') / tag


def summarize_repair(rep):
    """Accepted edits per kind from a resize.json / repair.json trace."""
    if not rep:
        return None
    s = dict(attempts=rep.get('attempts'), accepted=rep.get('accepted'), sizing_trials=0, forest_trials=0,
             sizing_accepted=0, forest_accepted=0, upsized=0, downsized=0, buffers=0, proposed_buffers=0,
             proposed_resizes=0, rejection=dict(), seconds=0.0, timing_s=0.0, placement_rc_s=0.0)
    for t in rep.get('trials', []):
        kind = 'forest' if t.get('action') == 'forest_sweep' else 'sizing'
        s[kind + '_trials'] += 1
        s['seconds'] += t.get('total_s', 0)
        s['timing_s'] += t.get('timing_s', 0)
        s['placement_rc_s'] += t.get('placement_rc_s', 0)
        s['proposed_buffers'] += t.get('buffers', 0)
        s['proposed_resizes'] += t.get('upsized', 0) + t.get('downsized', 0) + t.get('same_area_resized', 0)
        for r in t.get('rejection_reasons') or []:
            s['rejection'][r] = s['rejection'].get(r, 0) + 1
        if t.get('accepted'):
            s[kind + '_accepted'] += 1
            s['upsized'] += t.get('upsized', 0)
            s['downsized'] += t.get('downsized', 0)
            s['buffers'] += t.get('buffers', 0)
    for k in ('before_delay', 'after_delay', 'before_area', 'after_area', 'setup_wns', 'hold_wns'):
        s[k] = rep.get(k)
    return s


def fp_summary(place):
    fp = load(place / 'macro/fp_place.json') or {}
    out = {k: fp.get(k) for k in ('timing_checkpoints', 'timing_sta_calls', 'timing_resized_cells', 'timing_repair_edits')}
    out['candidates'] = len(fp.get('candidates') or [])
    rows = []
    tl = place / 'macro/fp_timing.jsonl'
    if tl.exists():
        rows = [json.loads(l) for l in tl.read_text().splitlines() if l.strip()]
    out['checkpoints'] = rows
    out['timing_seconds'] = sum(r.get('timing_seconds', 0) for r in rows)
    trials = dict(forest=0, forest_accepted=0, forest_changed_accepted=0, individual=0, individual_accepted=0,
                  individual_buffers_accepted=0)
    for f in sorted((place / 'macro').glob('fp_repair_*.json')):
        d = load(f)
        for t in d.get('trials', []):
            if t.get('kind') == 'forest_sweep':
                trials['forest'] += 1
                if t.get('accepted'):
                    trials['forest_accepted'] += 1
                    trials['forest_changed_accepted'] += t.get('changed', 0)
            else:
                trials['individual'] += 1
                if t.get('accepted'):
                    trials['individual_accepted'] += 1
                    trials['individual_buffers_accepted'] += t.get('buffers', 0)
    out['repair_trials'] = trials
    return out


def collect_one(key):
    d0, d1 = run_dir(key, 'study_noresize'), run_dir(key, 'study_resize')
    r0, r1 = load(d0 / 'result_full.json'), load(d1 / 'result_full.json')
    row = dict(design=key)
    if not r0 or not r1 or 'score' not in r0 or 'score' not in r1:
        row['status'] = 'incomplete: %s / %s' % (r0 and r0['meta']['status'], r1 and r1['meta']['status'])
        return row
    p0, p1 = d0 / 'w/synth/place', d1 / 'w/synth/place'
    c0 = logical(def_components(p0 / 'out.def'))
    cfp = logical(def_components(p1 / 'macro/out.def')) if (p1 / 'macro/out.def').exists() else None
    c1 = logical(def_components(p1 / 'out.def'))
    common = set(c0) & set(c1)
    row.update(
        status='ok',
        cells_noresize=len(c0), cells_after_fp=len(cfp) if cfp is not None else None, cells_resize=len(c1),
        added=len(set(c1) - set(c0)), removed=len(set(c0) - set(c1)),
        master_changes=sum(1 for n in common if c0[n] != c1[n]),
        rebuffers_final=sum(1 for n in c1 if REBUF in n),
        rebuffers_after_fp=sum(1 for n in cfp if REBUF in n) if cfp is not None else None,
        rebuffer_depth_hist={},
        sta_noresize={k: r0['score'][k] for k in ('setup_wns_ps', 'setup_tns_ps', 'hold_wns_ps', 'logical_cells', 'hpwl_um')},
        sta_resize={k: r1['score'][k] for k in ('setup_wns_ps', 'setup_tns_ps', 'hold_wns_ps', 'logical_cells', 'hpwl_um')},
        penalty_noresize=r0.get('penalty'), penalty_resize=r1.get('penalty'),
        lhd_seconds_noresize=r0['meta']['lhd_seconds'], lhd_seconds_resize=r1['meta']['lhd_seconds'])
    for n in c1:
        if REBUF in n:
            k = rebuffer_depth(n)
            row['rebuffer_depth_hist'][k] = row['rebuffer_depth_hist'].get(k, 0) + 1
    for tag, p in (('noresize', p0), ('resize', p1)):
        q = load(p / 'qor.json') or {}
        t = (load(p.parent / 'timing.json') or {}).get('designs', [{}])[0]
        row['lhd_internal_' + tag] = dict(wns=q.get('wns'), tns=q.get('tns'), hold_wns=t.get('hold_wns'),
                                          negative_endpoints=t.get('negative_setup_endpoints'))
    row['fp'] = fp_summary(p1)
    row['resize'] = summarize_repair(load(p1 / 'resize.json'))
    row['repair'] = summarize_repair(load(p1 / 'repair.json'))
    res = load(d1 / 'result.json') or {}
    ph = {}
    for x in res.get('phases', []):
        e = ph.setdefault(x['name'], [0, 0.0])
        e[0] += 1
        e[1] += x['ms'] / 1000
    row['phases_resize'] = {k: ph[k] for k in ph if k.startswith('pass.place') or k.startswith('pass.opentimer')}
    return row


def collect_a(keys):
    rows = [collect_one(k) for k in (keys or TUNEUP)]
    (STUDY / 'A').mkdir(parents=True, exist_ok=True)
    (STUDY / 'A/collect_a.json').write_text(json.dumps(rows, indent=1))
    for r in rows:
        if r.get('status') != 'ok':
            print(r['design'], r.get('status'))
            continue
        s0, s1 = r['sta_noresize'], r['sta_resize']
        print('%-18s cells %6d -> %6d (fp %s) added %d removed %d resized %d rebuf %d (fp %s) | STA wns %.0f/%.0f tns %.0f/%.0f pen %.3f/%.3f | lhd wns %s/%s hold %s/%s | t %.0f/%.0f s'
              % (r['design'], r['cells_noresize'], r['cells_resize'], r['cells_after_fp'], r['added'], r['removed'],
                 r['master_changes'], r['rebuffers_final'], r['rebuffers_after_fp'], s0['setup_wns_ps'], s1['setup_wns_ps'],
                 s0['setup_tns_ps'], s1['setup_tns_ps'], r['penalty_noresize'] or 0, r['penalty_resize'] or 0,
                 r['lhd_internal_noresize']['wns'], r['lhd_internal_resize']['wns'], r['lhd_internal_noresize']['hold_wns'],
                 r['lhd_internal_resize']['hold_wns'], r['lhd_seconds_noresize'], r['lhd_seconds_resize']))


if __name__ == '__main__':
    if sys.argv[1] == 'jobs-a':
        jobs_a(sys.argv[2:])
    elif sys.argv[1] == 'collect-a':
        collect_a(sys.argv[2:])
