#!/usr/bin/env python3
"""Generate livehd/todo/tuneup.html from the sweep results.

  make_tuneup.py --out /lscratch/renau/livehd/todo/tuneup.html [--shas PREFIX,...] [--notes notes.json]

The best run per design is the lowest (penalty, logic cells) among the runs whose lhd binary
sha256 starts with one of --shas (all runs when omitted). Everything printed comes from the
stored score.json / result_full.json of that run; nothing is estimated. notes.json holds the
hand-written text: {"intro": "...", "defaults": {...}, "designs": {"<key>": "note"}}.
"""
import argparse, html, json, sys, time
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
import lhdsweep as L

BASE_KEYS = {'synth.liberty', 'synth.sdc', 'synth.lef', 'synth.place', 'synth.place.density', 'synth.place.tech_rc',
             'synth.place.threads', 'synth.memory', 'pass.abc.drop_init', 'pass.abc.derived_clock',
             'synth.place.unknown_const', 'synth.place.utilization'}

GLOSSARY = {
    'synth.delay_frac': 'ABC timing budget as a fraction of the SDC clock period (shareable across designs)',
    'pass.abc.area_relax': 'percent of measured slack ABC may trade back for area (0 = keep the timing)',
    'pass.abc.max_fanout': 'fanout cap for every net ABC maps',
    'pass.abc.adder': 'adder architecture (auto, rca, cska, cla, prefix, brent)',
    'synth.place.resize': 'timing-checked gate sizing, buffer removal and Steiner repair after placement',
    'synth.place.repair.reset': 'let post-placement repair size and buffer reset cones',
    'synth.place.reset_fanout': 'flat pre-placement buffer tree on async reset nets (max pins per buffer)',
    'pass.abc.reset_fanout': 'region-local async reset buffer tree (max pins per buffer)',
    'pass.usyn.reset_fanout': 'async reset buffer tree for the USYN mapper',
    'synth.state_sweep': 'drop registers and register bits that cannot reach an output',
    'synth.merge_registers': 'merge word-level registers that are the same machine',
    'synth.partition': 'ABC region granularity (fine cuts at muxes/arithmetic, coarse keeps register-to-register cones)',
    'synth.mapper': 'technology mapper (abc or usyn)',
    'compile.specialize_modules': 'specialize constant instance inputs before cycle checking',
    'pass.abc.ware_zero_bits': 'mask known-zero bits inside extracted adder/shifter modules',
    'pass.abc.memory_prune_reads': 'drop unobserved memory read bits, mask zero inputs',
    'pass.abc.large_flow_latches': 'map ICG/derived-clock/async-reset registers in large regions',
    'synth.place.timing_driven': 'timing-weighted placement refinement',
    'synth.place.timing_rounds': 'timing-driven placement checkpoints',
    'synth.place.density': 'global-placement target density',
    'compile.flatten': 'inline hierarchy before legalization', 'compile.sweep': 'inductive constant-register and demanded-bit sweep',
    'reader': 'harness front end (native LiveHD slang reader or yosys-slang)',
}


def fmt(x, p=1):
    return '—' if x is None else ('%.*f' % (p, x))


def load_runs(shas):
    rows = {}
    for line in (L.SWEEP / 'results.jsonl').read_text().splitlines():
        r = json.loads(line)
        if not r.get('score'):
            continue
        d = r['design']
        safe = d.replace('/', '__')
        full = L.SWEEP / 'runs' / safe / r['tag'] / 'result_full.json'
        try:
            meta = json.loads(full.read_text())['meta']
        except Exception:
            continue
        sha = meta.get('lhd_sha256', '')
        if shas and not any(sha.startswith(s) for s in shas):
            continue
        p = r['penalty'] if r['penalty'] is not None else float('inf')
        key = (p, r['score']['logical_cells'])
        if d not in rows or key < rows[d][0]:
            rows[d] = (key, r, meta)
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', required=True)
    ap.add_argument('--shas', default='')
    ap.add_argument('--notes', default='')
    a = ap.parse_args()
    shas = [s for s in a.shas.split(',') if s]
    notes = json.loads(Path(a.notes).read_text()) if a.notes else {}
    best = load_runs(shas)
    designs = [d for d in L.discover() if (d.ref_dir / 'score/score.json').exists()]
    body = []
    used_params = set()
    met = beat = 0
    for d in designs:
        ref = json.loads((d.ref_dir / 'score/score.json').read_text())
        info = json.loads((d.ref_dir / 'info.json').read_text())
        period = info.get('clock_period_ps')
        if d.key not in best:
            body.append('<tr><td><code>%s</code></td><td colspan="13">no scored run with the selected binary</td></tr>' % html.escape(d.key))
            continue
        key, r, meta = best[d.key]
        s = r['score']
        sets = {k: v for k, v in meta['effective_sets'].items() if k not in BASE_KEYS}
        used_params.update(sets)
        ok = key[0] == 0
        met += ok
        dc = 100.0 * (s['logical_cells'] - ref['logical_cells']) / ref['logical_cells']
        beat += ok and dc <= 0
        ref_ok = ref['setup_wns_ps'] >= 0
        status = ('<span class="status landed">met</span>' if ok else '<span class="status">violated</span>')
        params = '<br>'.join('<code>%s=%s</code>' % (html.escape(k), html.escape(str(v))) for k, v in sorted(sets.items())) or '(base only)'
        note = notes.get('designs', {}).get(d.key, '')
        body.append(
            '<tr><td><code>%s</code></td><td>%s</td>'
            '<td>%s</td><td>%s</td><td>%d</td><td>%s</td>'
            '<td>%s</td><td>%s</td><td>%d</td><td>%s</td><td>%+.1f%%</td><td>%s</td><td>%s</td><td>%s<br><small>%s</small></td></tr>' % (
                html.escape(d.key), fmt(period, 0),
                fmt(ref['setup_wns_ps']), fmt(ref['setup_tns_ps'], 0), ref['logical_cells'], fmt(ref['hpwl_um'] / 1e6, 3),
                fmt(s['setup_wns_ps']), fmt(s['setup_tns_ps'], 0), s['logical_cells'], fmt(s['hpwl_um'] / 1e6, 3), dc,
                status, fmt(r['lhd_seconds'] / 60, 0),
                params, html.escape(r['tag'] + (' — ' + note if note else ''))))
    gl = ''.join('<li><code>%s</code> — %s</li>' % (html.escape(k), html.escape(GLOSSARY.get(k, ''))) for k in sorted(used_params))
    defaults = notes.get('defaults', {})
    dtxt = ''.join('<tr><td><code>%s</code></td><td><code>%s</code></td><td>%s</td></tr>' % (html.escape(k), html.escape(v['value']), html.escape(v['why']))
                   for k, v in sorted(defaults.items()))
    out = '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>LiveHD tune-up per HighTide benchmark</title>
<link rel="stylesheet" href="todo.css">
<style>td,th{font-size:.82rem;padding:.3rem .45rem} main{max-width:1500px} td small{color:var(--muted)}</style>
</head>
<body>
<nav><span class="brand">LiveHD TODO</span><a href="index.html">← All tasks</a></nav>
<main>
<h1>Tune-up per HighTide benchmark (asap7, pre-CTS)</h1>
<p>%(intro)s</p>
<h2>Method</h2>
<ul>
<li>Flow: RTL → <code>lhd synth</code> (mapping + native DREAMPlace) → one OpenSTA scorer (placement RC, ideal clocks, the OpenROAD flow's own SDC and Liberty set). The reference is the HighTide OpenROAD flow's <code>3_place.odb</code> scored by the same script, so both columns are directly comparable. Pre-CTS only; setup only.</li>
<li>Objective per benchmark, lowest wins: <code>penalty = max(0,-WNS)/s_w + max(0,-TNS)/s_t</code> with <code>s = max(reference negative slack, 5%% of the clock period)</code>; penalty is 0 exactly when setup timing is met. Then fewest logic cells (no fill/tap/endcap). WNS/TNS are in ps; HPWL in metres; cells exclude physical-only instances.</li>
<li>Every row is the best stored run of the selected LiveHD binary for that benchmark; the tag names the run directory under <code>HighTide/artifacts/lhdsweep/runs/</code>. Each tune-up parameter list is the complete set of non-base options of that run. Base settings applied to every run: merged asap7 RVT FF Liberty with the platform dont_use list, benchmark utilization and density, <code>synth.memory=flops</code>, <code>pass.abc.drop_init=true</code>, <code>pass.abc.derived_clock=true</code>, <code>synth.place.unknown_const=zero</code>.</li>
<li>Run times are wall minutes on a shared, heavily loaded machine (single placer thread unless noted); use them for order of magnitude only.</li>
</ul>
<h2>Summary</h2>
<p>%(met)d of %(n)d benchmarks meet setup timing; %(beat)d of them with no more cells than OpenROAD.</p>
<h2>Results and recommended parameters</h2>
<table>
<tr><th rowspan="2">Benchmark</th><th rowspan="2">clock ps</th><th colspan="4">OpenROAD reference</th><th colspan="6">LiveHD</th><th rowspan="2">min</th><th rowspan="2">Recommended parameters (tag)</th></tr>
<tr><th>WNS</th><th>TNS</th><th>cells</th><th>HPWL m</th><th>WNS</th><th>TNS</th><th>cells</th><th>HPWL m</th><th>Δcells</th><th>setup</th></tr>
%(rows)s
</table>
<h2>Recommended shared defaults</h2>
%(defaults)s
<h2>Parameter glossary</h2>
<ul>%(glossary)s</ul>
<footer>Generated %(date)s by HighTide/tools/vslivehd/make_tuneup.py from artifacts/lhdsweep/results.jsonl.</footer>
</main>
</body>
</html>
''' % dict(intro=notes.get('intro', ''), met=met, n=len(designs), beat=beat, rows='\n'.join(body),
           defaults=('<table><tr><th>Option</th><th>Value</th><th>Evidence</th></tr>%s</table>' % dtxt) if dtxt else '<p>To be determined from the cross-benchmark validation.</p>',
           glossary=gl, date=time.strftime('%Y-%m-%d'))
    Path(a.out).write_text(out)
    print('wrote', a.out, 'rows', len(designs), 'met', met)


if __name__ == '__main__':
    main()
