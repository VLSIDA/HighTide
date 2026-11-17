#!/usr/bin/env python3
"""Resize study, measurement D: where do the cells added by synth.place.resize go?

  resize_cells.py KEY        writes resize_study/D/<design>.json and prints a summary

Inputs: runs/<design>/study_noresize and study_resize (same netlist before placement).
Buffers inserted by the Steiner/forest repair are named __place_rebuffer_<owner>_<serial>,
where <owner> is the driving instance; a tree rooted at an earlier repair buffer therefore
nests the prefix, so the prefix count is the number of buffer layers stacked on one net.
"""
import json, re, sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import lhdsweep as ls
from resize_study import def_components, logical, REBUF, load

STUDY = ls.SWEEP / 'resize_study'


def def_nets(path):
    """{net: [(inst, pin)]} from a DEF NETS section (PIN for ports)."""
    nets, inside, cur, buf = {}, False, None, []
    with open(path) as f:
        for line in f:
            if line.startswith('NETS'):
                inside = True
                continue
            if line.startswith('END NETS'):
                break
            if not inside:
                continue
            buf.append(line)
            if line.rstrip().endswith(';'):
                text = ' '.join(buf)
                buf = []
                m = re.match(r'\s*-\s+(\S+)', text)
                if not m:
                    continue
                body = text.split('+')[0]
                nets[m.group(1)] = re.findall(r'\(\s*(\S+)\s+(\S+)\s*\)', body[m.end():])
    return nets


def root_owner(name):
    """Original driver of a (possibly nested) repair buffer."""
    while name.startswith(REBUF):
        name = name[len(REBUF):]
        name = name.rsplit('_', 1)[0]
    return name


def bucket(n):
    for lim in (1, 4, 16, 64, 256, 1024):
        if n <= lim:
            return '<=%d' % lim
    return '>1024'


def analyze(key):
    d = ls.get(key)
    r0 = ls.SWEEP / 'runs' / d.safe / 'study_noresize/w/synth/place'
    r1 = ls.SWEEP / 'runs' / d.safe / 'study_resize/w/synth/place'
    c0 = logical(def_components(r0 / 'out.def'))
    c1 = logical(def_components(r1 / 'out.def'))
    cfp = logical(def_components(r1 / 'macro/out.def')) if (r1 / 'macro/out.def').exists() else {}
    n0 = def_nets(r0 / 'out.def')
    n1 = def_nets(r1 / 'out.def')
    # output nets: driver = the component pin that is an output. Use master pin direction by LEF.
    tech_out = {}
    for lef in d.lef_list():
        macro = None
        pin = None
        for line in open(lef):
            t = line.split()
            if not t:
                continue
            if t[0] == 'MACRO':
                macro = t[1]
            elif t[0] == 'PIN' and macro:
                pin = t[1]
            elif t[0] == 'DIRECTION' and macro and pin:
                tech_out[(macro, pin)] = t[1] == 'OUTPUT'
    def driver_fanout(comps, nets):
        fo = {}
        for net, conns in nets.items():
            drv = [(i, p) for i, p in conns if i != 'PIN' and tech_out.get((comps.get(i), p))]
            if len(drv) == 1:  # multi-output owners (FA/HA, macros): sum sinks over all outputs
                prev = fo.get(drv[0][0], (None, []))[1]
                fo[drv[0][0]] = (net, prev + [(i, p) for i, p in conns if (i, p) != drv[0]])
        return fo
    fo0 = driver_fanout(c0, n0)
    fo1 = driver_fanout(c1, n1)
    rebuf_final = [n for n in c1 if REBUF in n]
    rebuf_fp = [n for n in cfp if REBUF in n]
    depth = Counter(n.count(REBUF) for n in rebuf_final)
    depth_fp = Counter(n.count(REBUF) for n in rebuf_fp)
    per_root = defaultdict(list)
    for n in rebuf_final:
        per_root[root_owner(n)].append(n)
    bucket_stats = defaultdict(lambda: dict(roots=0, buffers=0, sinks=0, over_one_per_sink=0))
    roots_detail = []
    for root, bufs in per_root.items():
        orig = len(fo0.get(root, (None, []))[1]) if root in fo0 else None
        b = bucket(orig) if orig is not None else 'unknown/port'
        s = bucket_stats[b]
        s['roots'] += 1
        s['buffers'] += len(bufs)
        s['sinks'] += orig or 0
        if orig and len(bufs) >= orig:
            s['over_one_per_sink'] += 1
        roots_detail.append((root, orig, len(bufs), max(x.count(REBUF) for x in bufs)))
    roots_detail.sort(key=lambda x: -x[2])
    # structure of the repair buffers in the final netlist
    single_sink = only_buffers = 0
    sink_hist = Counter()
    for n in rebuf_final:
        net, sinks = fo1.get(n, (None, []))
        sink_hist[bucket(len(sinks))] += 1
        if len(sinks) == 1:
            single_sink += 1
        if sinks and all(REBUF in i for i, _ in sinks):
            only_buffers += 1
    # masters
    masters = Counter(c1[n] for n in rebuf_final)
    common = set(c0) & set(c1)
    resized = Counter((c0[n], c1[n]) for n in common if c0[n] != c1[n])
    up = sum(v for (a, b), v in resized.items() if strength(b) > strength(a))
    down = sum(v for (a, b), v in resized.items() if strength(b) < strength(a))
    # non-rebuffer cells that appeared or vanished (reset trees, other repair, removed buffers)
    other_added = [n for n in set(c1) - set(c0) if REBUF not in n]
    removed = [n for n in set(c0) - set(c1)]
    fp = load(r1 / 'macro/fp_place.json') or {}
    fpt = [json.loads(l) for l in (r1 / 'macro/fp_timing.jsonl').read_text().splitlines()] if (r1 / 'macro/fp_timing.jsonl').exists() else []
    fp_trials = []
    for f in sorted((r1 / 'macro').glob('fp_repair_*.json'), key=lambda p: int(p.stem.split('_')[-1])):
        t = load(f)
        it = int(f.stem.split('_')[-1])
        fs = [x for x in t.get('trials', []) if x.get('kind') == 'forest_sweep']
        ind = [x for x in t.get('trials', []) if x.get('kind') != 'forest_sweep']
        fp_trials.append(dict(iteration=it, forest_changed=sum(x.get('changed', 0) for x in fs),
                              forest_accepted=any(x.get('accepted') for x in fs),
                              forest_failures=sum(len(x.get('eligibility_failures', [])) for x in fs),
                              individual=len(ind), individual_accepted=sum(1 for x in ind if x.get('accepted')),
                              individual_buffers_accepted=sum(x.get('buffers', 0) for x in ind if x.get('accepted'))))
    out = dict(design=key, cells_noresize=len(c0), cells_after_fp=len(cfp) or None, cells_final=len(c1),
               added_total=len(c1) - len(c0), rebuffers_final=len(rebuf_final), rebuffers_after_fp=len(rebuf_fp),
               other_added=len(other_added), removed_original=len(removed),
               removed_examples=sorted(removed)[:10], other_added_examples=sorted(other_added)[:10],
               nesting_depth_final=dict(sorted(depth.items())), nesting_depth_after_fp=dict(sorted(depth_fp.items())),
               roots=len(per_root), by_original_fanout=dict(bucket_stats), top_roots=roots_detail[:25],
               rebuffer_output_sinks=dict(sink_hist), rebuffer_single_sink=single_sink, rebuffer_drives_only_buffers=only_buffers,
               rebuffer_masters=dict(masters.most_common()), resized_up=up, resized_down=down,
               resized_total=sum(resized.values()), resized_top=[(a, b, v) for (a, b), v in resized.most_common(15)],
               fp_summary={k: fp.get(k) for k in ('fp_iterations', 'fp_density_ready_iteration', 'fp_continuation_deadline',
                                                  'fp_converged', 'fp_timing_satisfied_at_last_checkpoint', 'timing_checkpoints',
                                                  'timing_sta_calls', 'timing_resized_cells', 'timing_repair_edits')},
               fp_checkpoints=fpt, fp_trials=fp_trials)
    (STUDY / 'D').mkdir(parents=True, exist_ok=True)
    (STUDY / 'D' / ('%s.json' % d.safe)).write_text(json.dumps(out, indent=1))
    return out


def strength(master):
    m = re.search(r'x(\d*)(?:p(\d+))?[fD]?[C]?_ASAP7', master)
    return float((m.group(1) or '0') + '.' + (m.group(2) or '0')) if m else 0


if __name__ == '__main__':
    o = analyze(sys.argv[1])
    print(json.dumps({k: v for k, v in o.items() if k not in ('fp_checkpoints', 'fp_trials', 'top_roots')}, indent=1)[:4000])
    print('top roots (root, original fanout, buffers, max depth):')
    for x in o['top_roots'][:12]:
        print('  ', x)
