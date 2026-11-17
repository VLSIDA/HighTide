#!/usr/bin/env python3
"""Matched three-arm LiveHD domplace experiments on HighTide asap7 designs
(LiveHD todo/livehd/2d-domplace.html, H; plan H5).

  domplace.py designs                         the H design list and its domino clocks
  domplace.py run KEY [options]               the arms of one design, serialized
  domplace.py report OUT                      tables from OUT/<design>/results.json

Arms, matched on RTL, clock target, technology, seed, density and budgets:
  1 abc-cmos     the existing all-CMOS baseline (synth.mapper=abc)
  2 usyn-cmos    USYN CMOS (synth.mapper=usyn, clock_phases=1, tmap=abc, tmap_trials=1)
  3 usyn-domino  arm 2 + pass.usyn.physical=domino_provisional and the domino clock

Every leg is lhdsweep.run_variant (same merged Liberty, LEFs, reader flags, ORFS
density and per-design sets, guard-measured lhd, OpenSTA scoring) with these pins:
no timing-driven placement, resizing or resynthesis, io_resynth=0, OpenTimer off,
lhd.seed, iterations, grid density, and the native stage timer
(synth.place.stage_timing) on the table's clock port, so every arm has one timer.
Arm 3's OpenSTA WNS/TNS is withheld (timing-unmeasured: its domino cells have no
Liberty timing); the stage period is the timing metric for every arm.

Cores (--core-mode): area-driven legs use the ORFS CORE_UTILIZATION; fixed legs place
into the frame (die, rows, FIXED IO pins) of the arm-1 area-driven run, and orfs legs
into the frame of the OpenROAD 3_place reference (synth.place.floorplan). Each is
reported separately.

Per leg: status class (ok, timeout (assumed pass) when the capped LEC runs out of time,
unproven, unsupported, infeasible, timeout, failed),
LEC against the RTL (lhd compile reference; gensim cell models, plus the bundle
models for arm 3), USYN eligible/converted coverage, area on the Liberty and LEF
bases (domino variants on their sidecar estimate and footprint, rail inverters
counted once), two-row legality and ECO displacement, the stage period with its
per-class slack and status, HPWL (LiveHD and OpenSTA) and a harness RUDY from the
DEF, clock sinks and C_clk, domino variants, lhd wall time and peak process-tree
RSS (guard.py). The H metrics are read with the LiveHD tree's
scripts/domplace/{arms,domplace_view}.py (--livehd-src), so the harness and
the in-repo runner read the same reports.

Output: OUT/manifest.json (binary hash, LiveHD source HEAD/dirty hash, inputs,
options, every leg's command), OUT/<design>/<leg>/ (the lhdsweep run directory),
OUT/<design>/results.json and OUT/results.tsv. Synthesis-bearing runs are
serialized; guard.py stops a leg at --mem-gib or when the OS reserve drops
below 4 GiB.
"""
import argparse
import datetime
import hashlib
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import lhdsweep as L  # noqa: E402

# Per-design clock port of the ORFS SDC (`create_clock ... [get_ports P]`). The
# ORFS SDCs name the port through Tcl variables, which LiveHD's SDC reader does
# not resolve, so the stage timer and USYN's domino_clock take it from here.
# sdc_clock_port() re-derives it at run time and a mismatch is an error. A multi-clock
# SDC names the domino clock here; the other clocks stay CMOS-only (the stage timer
# and the domino conversion see only this one).
DOMINO_CLOCK = {
    'lfsr': 'clk',
    'sha3': 'clock',
    'minimax': 'clk',
    'NVDLA/partition_m': 'nvdla_core_clk',
    'NVDLA/partition_o': 'nvdla_core_clk',  # two clocks: nvdla_core_clk 2000 ps (domino) + nvdla_falcon_clk 2500 ps
    'litedram': 'clk',
}
# The H list, smallest first: asap7, no macros, an OpenROAD 3_place reference,
# 50% clock waveform (the stage schedule is a fixed T/2; NVDLA/partition_a's
# {0 750} at 1265 ps is refused), and earlier lhdsweep runs that placed.
DESIGNS = ['lfsr', 'sha3', 'minimax', 'NVDLA/partition_m', 'litedram']

ARMS = {
    1: ('abc-cmos', {'synth.mapper': 'abc'}),
    2: ('usyn-cmos', {'synth.mapper': 'usyn', 'pass.usyn.clock_phases': '1', 'pass.usyn.tmap': 'abc',
                      'pass.usyn.tmap_trials': '1'}),
    3: ('usyn-domino', {'synth.mapper': 'usyn', 'pass.usyn.clock_phases': '1', 'pass.usyn.tmap': 'abc',
                        'pass.usyn.tmap_trials': '1', 'pass.usyn.physical': 'domino_provisional'}),
}
STATUS_OK = ('ok', 'timeout (assumed pass)', 'unproven')


def sha256(path):
    return L.sha(path) if Path(path).is_file() else None


def sdc_clock_port(sdc):
    """The port of the SDC's one create_clock, resolving `set var value` and `[get_ports $var]`."""
    text = Path(sdc).read_text()
    var = dict(re.findall(r'^\s*set\s+(\w+)\s+(.+?)\s*(?:;.*)?$', text, re.M))

    def value(token):
        token = token.strip('{}"')
        while token.startswith('$') and token[1:] in var:
            token = var[token[1:]].strip('{}"')
        return token
    ports = set()
    for line in re.findall(r'^\s*create_clock\b(.*)$', text, re.M):
        m = re.search(r'\[get_ports\s+([^\]]+)\]', line)
        if m:
            ports.add(value(m.group(1).strip()))
        else:  # create_clock ... $clk_port, with `set clk_port [get_ports X]`
            for word in line.split():
                if word.startswith('$') and word[1:] in var:
                    g = re.match(r'\[get_ports\s+([^\]]+)\]', var[word[1:]])
                    if g:
                        ports.add(value(g.group(1).strip()))
    return sorted(ports)


def livehd_modules(src):
    """scripts/domplace/{arms,domplace_view} from the LiveHD tree the binary was built from."""
    sys.path.insert(0, str(Path(src) / 'scripts/domplace'))
    import arms
    import domplace_view
    return arms, domplace_view


def git(src, *args):
    try:
        return subprocess.run(['git', '-C', str(src), *args], capture_output=True, text=True, timeout=30,
                              check=True).stdout
    except (OSError, subprocess.SubprocessError):
        return None


# --------------------------------------------------------------------- legs
def matched_sets(a, port):
    return {
        'synth.place.timing_driven': 'false', 'synth.place.resize': 'false', 'synth.place.resynth': 'false',
        'synth.place.io_resynth': '0', 'synth.opentimer': 'false',
        'synth.place.stage_timing': 'true', 'synth.place.stage_timing.clock_port': port,
        'lhd.seed': str(a.seed), 'synth.place.iterations': str(a.iterations),
        'synth.place.grid.density': str(a.grid_density),
    }


def plan(a, port):
    """(leg, arm, core, sets) in run order; the fixed-core legs follow the arm-1 area-driven run."""
    arms = sorted({int(x) for x in a.arms.split(',')})
    if not set(arms) <= set(ARMS):
        raise SystemExit('domplace.py: unknown arm in %s' % a.arms)
    modes = core_modes(a.core_mode)
    area = arms if 'area' in modes else []
    fixed = arms if 'fixed' in modes else []
    orfs = arms if 'orfs' in modes else []
    if fixed and 1 not in arms:
        raise SystemExit('domplace.py: fixed-core legs take the arm-1 area-driven floorplan; include arm 1')
    if fixed and not area:
        area = [1]
    common = matched_sets(a, port)
    common.update(dict(x.split('=', 1) for x in a.set))
    out = []
    for core, members in (('area', area), ('fixed', fixed), ('orfs', orfs)):
        for arm in members:
            sets = dict(common)
            sets.update(ARMS[arm][1])
            if arm == 3:
                sets['pass.usyn.domino_clock'] = port
                sets.update(dict(x.split('=', 1) for x in a.arm3_set))
            if a.utilization and core == 'area':
                sets['synth.place.utilization'] = a.utilization
            out.append(('arm%d-%s' % (arm, core), arm, core, sets))
    return out


def core_modes(text):
    """area (ORFS utilization, LiveHD sizes the core), fixed (the arm-1 area-driven run's frame),
    orfs (the frame of the OpenROAD 3_place reference); 'both' is area,fixed and 'all' all three."""
    modes = {'both': ['area', 'fixed'], 'all': ['area', 'fixed', 'orfs']}.get(text, text.split(','))
    if not set(modes) <= {'area', 'fixed', 'orfs'}:
        raise SystemExit('domplace.py: unknown core mode in %s' % text)
    return modes


def floorplan_frame(src_def, dst):
    """A synth.place.floorplan frame from a placed DEF: its DIEAREA, ROWs and signal PINS, the pins
    FIXED where they were placed; no components (tap cells and logic), special nets or blockages.
    Every arm of a frame mode places into the same die, rows and IO locations."""
    text = Path(src_def).read_text()
    head = [l for l in text.splitlines() if l.split()[:1] in (['VERSION'], ['DIVIDERCHAR'], ['BUSBITCHARS'], ['DESIGN'])
            or l.startswith('UNITS DISTANCE MICRONS') or l.startswith('DIEAREA')]
    rows = [l for l in text.splitlines() if l.startswith('ROW ')]
    cut = len(rows)
    rows = merge_cut_rows(rows)
    m = re.search(r'^PINS \d+ ;\n(.*?)^END PINS', text, re.M | re.S)
    pins = []
    for block in re.split(r'\n(?=\s*- )', m.group(1)) if m else []:
        block = block.rstrip()
        if not block.strip() or '+ SPECIAL' in block or 'USE POWER' in block or 'USE GROUND' in block:
            continue
        if '+ PLACED' not in block and '+ FIXED' not in block:
            raise SystemExit('domplace.py: %s: unplaced pin %s' % (src_def, block.split()[1]))
        pins.append(block.replace('+ PLACED', '+ FIXED'))
    body = head + rows + ['PINS %d ;' % len(pins)] + pins + ['END PINS', 'END DESIGN']
    Path(dst).write_text('\n'.join(body) + '\n')
    return {'source': str(src_def), 'source_sha256': sha256(src_def), 'frame': str(dst), 'frame_sha256': sha256(dst),
            'rows': len(rows), 'source_row_segments': cut, 'pins': len(pins),
            'die': next((l for l in head if l.startswith('DIEAREA')), None)}


ROW_RE = re.compile(r'^ROW\s+(\S+)\s+(\S+)\s+(-?\d+)\s+(-?\d+)\s+(\S+)\s+DO\s+(\d+)\s+BY\s+1\s+STEP\s+(\d+)\s+0\s*;\s*$')


def merge_cut_rows(rows):
    """One full-width row per y. ORFS cuts the rows around its placed macros (cut_rows), which
    leaves several segments at one y; the frame carries no components (LiveHD places the macros
    itself), so the segments of a y are rejoined into the span from the first segment's start to
    the last one's end. Rows that are already one per y are returned unchanged."""
    by_y = {}
    for line in rows:
        m = ROW_RE.match(line)
        if not m:
            return rows  # an unusual row form: leave the frame as exported
        name, site, x, y, orient, count, step = m.groups()
        by_y.setdefault(int(y), []).append((int(x), int(count), int(step), site, orient, name))
    if all(len(v) == 1 for v in by_y.values()):
        return rows
    every = [s for segs in by_y.values() for s in segs]
    if len({s[2] for s in every}) != 1 or len({s[3] for s in every}) != 1:
        raise SystemExit('domplace.py: row segments disagree on site or step')
    step = every[0][2]
    # The core span: the leftmost segment start to the rightmost segment end over every y, so
    # each rejoined row has the same width (a macro on the core edge cuts that y's end segment).
    x0, x1 = min(s[0] for s in every), max(s[0] + s[1] * step for s in every)
    out = []
    for y in sorted(by_y):
        segs = sorted(by_y[y])
        sites, orients = {s[3] for s in segs}, {s[4] for s in segs}
        if len(orients) != 1:
            raise SystemExit('domplace.py: row segments at y=%d disagree on orientation' % y)
        if (x1 - x0) % step or any((s[0] - x0) % step for s in segs):
            raise SystemExit('domplace.py: row segments at y=%d are off the site grid' % y)
        out.append('ROW ROW_%d %s %d %d %s DO %d BY 1 STEP %d 0 ;' % (len(out), sites.pop(), x0, y, orients.pop(),
                                                                       (x1 - x0) // step, step))
    return out


def orfs_frame(d, out):
    """The ORFS floorplan of the reference: 3_place.odb (die, rows, IO placement) exported to DEF."""
    import guard
    exported = out / 'orfs_3_place.def'
    if not exported.exists():
        guard.root = out
        env = {'INPUT_ODB': str(d.ref_dir / '3_place.odb'), 'OUTPUT_DEF': str(exported)}
        guard.run('orfs_export_def', [L.OPENROAD, '-no_init', '-exit', L.TOOLS / 'or_export_def.tcl'], cwd=out,
                  timeout=1800, extra_env=env)
    return floorplan_frame(exported, out / 'orfs_floorplan.def')


# ------------------------------------------------------------------ metrics
def classify(rundir, meta_status, arms_mod):
    """ok/unproven come later from LEC; here: timeout, infeasible, unsupported or failed."""
    result = json.loads((rundir / 'result.json').read_text()) if (rundir / 'result.json').is_file() else {}
    error = result.get('error') or {}
    if 'wall-time limit' in meta_status:
        return 'timeout', result
    if (meta_status == 'ok' or meta_status.startswith('score failed')) and result.get('status') == 'pass' and not error:
        return 'placed', result  # an OpenSTA scoring failure is recorded (opensta, lhd_status), not a LiveHD failure
    message = error.get('message', '') or meta_status
    if any(n in message for n in arms_mod.INFEASIBLE):
        return 'infeasible', result
    if error.get('class') in ('usage', 'unsupported'):
        return 'unsupported', result
    return 'failed', result


def rudy(view, sizes, bin_um=1.08, max_bins=512):
    """Harness RUDY on the die: each net spreads (w+h)/(w*h) wire density over its pin bounding
    box (pins at their cell centers; IO pins skipped; nets with one terminal ignored), on square
    bins of bin_um (four asap7 rows) so that a fixed core gives every arm the same grid. Returns
    the peak and mean bin density and the fraction of bins above 1.0."""
    xl, yl, xh, yh = view.die
    if xh <= xl or yh <= yl:
        return None
    nx = max(1, min(max_bins, round((xh - xl) / (bin_um * view.dbu))))
    ny = max(1, min(max_bins, round((yh - yl) / (bin_um * view.dbu))))
    bw, bh = (xh - xl) / nx, (yh - yl) / ny
    grid = [[0.0] * ny for _ in range(nx)]
    centers = {}
    for name, c in view.components.items():
        w, h = sizes.get(c.macro, (0.0, 0.0))
        centers[name] = (c.x + w * view.dbu / 2, c.y + h * view.dbu / 2)
    for terms in view.nets.values():
        pts = [centers[i] for i, _ in terms if i in centers]
        if len(pts) < 2:
            continue
        nx0, nx1 = min(p[0] for p in pts), max(p[0] for p in pts)
        ny0, ny1 = min(p[1] for p in pts), max(p[1] for p in pts)
        w, h = max(nx1 - nx0, bw / 2), max(ny1 - ny0, bh / 2)  # degenerate boxes span half a bin
        density = (w + h) / (w * h)
        for i in range(max(0, int((nx0 - xl) // bw)), min(nx, int((nx0 + w - xl) // bw) + 1)):
            ox = min(nx0 + w, xl + (i + 1) * bw) - max(nx0, xl + i * bw)
            if ox <= 0:
                continue
            for j in range(max(0, int((ny0 - yl) // bh)), min(ny, int((ny0 + h - yl) // bh) + 1)):
                oy = min(ny0 + h, yl + (j + 1) * bh) - max(ny0, yl + j * bh)
                if oy > 0:
                    grid[i][j] += density * ox * oy / (bw * bh)
    # Units: wire length per area in DBU^-1; scaled to wire tracks with the M2 pitch of asap7 (36 nm).
    pitch = 0.036 * view.dbu
    flat = [v * pitch for row in grid for v in row]
    return {'bins': [nx, ny], 'bin_um': [bw / view.dbu, bh / view.dbu], 'peak': max(flat), 'mean': sum(flat) / len(flat),
            'over_1': sum(v > 1.0 for v in flat) / len(flat),
            'definition': 'harness RUDY: (w+h)/(w*h) over cell-center pin bboxes, x M2 pitch 36 nm; IO pins skipped'}


REGISTER = re.compile(r'^(DFF|DHL|DLL|SDF|ASYNC|ICG)')


def master_counts(view, view_mod):
    """Cells per master (every master, most used first) and registers: Liberty flip-flops/latches
    plus domino instances (each owns one converted state's storage)."""
    counts = {}
    for c in view.components.values():
        counts[c.macro] = counts.get(c.macro, 0) + 1
    ordered = dict(sorted(counts.items(), key=lambda kv: (-kv[1], kv[0])))
    flops = sum(n for m, n in counts.items() if REGISTER.match(m))
    domino = sum(n for m, n in counts.items() if m.startswith(view_mod.DOMINO_PREFIX))
    return {'by_master': ordered, 'registers': {'cmos': flops, 'domino': domino, 'total': flops + domino}}


def rail_templates(view, view_mod):
    """Domino instances per PG rail template (t0 on N starts, t1 on FS starts) and how many sit
    on a start row whose orientation needs the other template (bundle schema 4)."""
    counts, mismatched = {}, 0
    for c in view.components.values():
        if not c.macro.startswith(view_mod.DOMINO_PREFIX):
            continue
        t = c.macro.rpartition('_')[2]
        counts[t] = counts.get(t, 0) + 1
        if hasattr(view_mod, 'rail_template') and not c.macro.startswith(view_mod.rail_template(c.macro, view.rows[c.y])):
            mismatched += 1
    if not counts:
        return None
    return {'by_template': counts, 'parity_mismatched': mismatched if hasattr(view_mod, 'rail_template') else None}


def clock_summary(stage):
    acc = stage.get('clock_accounting') or {}
    clocks = {}
    for name, c in (acc.get('clocks') or {}).items():
        masters = c.get('masters') or {}
        clocks[name] = {'sinks': len(c.get('sinks') or []),
                        'sinks_by_master': {m: v.get('sinks') for m, v in masters.items()},
                        **{k: c.get(k) for k in ('domino_sinks', 'cmos_sinks', 'missing_capacitance', 'sink_cap_ff',
                                                 'domino_cap_ff', 'cmos_cap_ff', 'wire_cap_ff')}}
    return {'c_clk_ff': acc.get('c_clk_ff'), 'clocks': clocks}


def leg_metrics(rundir, arm, lib, arms_mod, view_mod):
    """The H metrics of one placed leg, mostly through LiveHD's arms.leg_metrics."""
    result = json.loads((rundir / 'result.json').read_text())
    w = rundir / 'W'
    if not w.exists():
        w.symlink_to('w')  # arms.leg_metrics reads <leg>/W/synth/...
    m = arms_mod.leg_metrics(SimpleNamespace(liberty=str(lib)), rundir, result, arm)
    stage_file = rundir / 'w/synth/place/stage_timing.json'
    if stage_file.is_file():
        stage = json.loads(stage_file.read_text())
        m['stage_timing']['coverage'] = stage.get('coverage')
        m['stage_timing']['clock'] = clock_summary(stage)
    place_qor = rundir / 'w/synth/place/qor.json'
    if place_qor.is_file():
        q = json.loads(place_qor.read_text())
        m['gp'] = {'converged': q.get('gp_converged'), 'overflow': q.get('gp_overflow')}
    def_dir = rundir / 'def'
    if (def_dir / 'out.def').is_file():
        lefs = [def_dir / x for x in json.loads((def_dir / 'lefs.json').read_text())]
        view = view_mod.read_def(def_dir / 'out.def')
        m['rudy'] = rudy(view, view_mod.lef_sizes(lefs))
        m['rail_templates'] = rail_templates(view, view_mod)
        m['masters'] = master_counts(view, view_mod)
        m['core_die_um'] = dict(zip(('core', 'die'), arms_mod.fixed_core(view, lefs)))
    return m


LEC_GRACE_S = 30  # formal.timeout is the cap less this, so lhd usually writes its own timeout verdict
LEC_ASSUMED = 'timeout (assumed pass)'  # 2026-10-26 ruling: a LEC that runs out of time counts as a pass


def lec(a, d, rundir, arm, ref_lg, cells):
    """Sequential LEC of the placed netlist against the lhd compile reference of the RTL, capped at
    --lec-timeout seconds of wall time (guard.py stops the process there; formal.timeout is LEC_GRACE_S
    less, so lhd usually reports its own timeout first). Either way the verdict is timeout-time,
    recorded as 'timeout (assumed pass)'."""
    import guard
    cmd = [L.LHD, 'lec', '--impl', 'lg:%s' % (rundir / 'w/synth/net'), '--ref', 'lg:%s' % ref_lg, '--lib', 'lg:%s' % cells,
           '--top', d.name, '--set', 'formal.effort=proof',
           '--set', 'formal.timeout=%d' % max(1, int(float(a.lec_timeout)) - LEC_GRACE_S),
           '--workdir', rundir / 'lec', '--result-json', rundir / 'lec.json']
    if arm == 3:
        cmd += ['--lib', 'lg:%s' % (rundir / 'w/synth/qor.json.domino/models')]
    guard.root = rundir
    cap = float(a.lec_timeout)
    t0 = time.monotonic()
    try:
        guard.run('lec', cmd, cwd=rundir, timeout=cap, extra_env={'GUARD_MEMORY_LIMIT_GIB': str(a.mem_gib)})
    except Exception as exc:  # a refuted or unproven verdict also exits nonzero; the JSON decides
        note = str(exc)
    else:
        note = None
    proof = json.loads((rundir / 'lec.json').read_text()).get('lec', {}) if (rundir / 'lec.json').is_file() else {}
    verdict = proof.get('verdict')
    if verdict is None and note and 'wall-time limit' in note:
        verdict = 'timeout-time'  # stopped by the cap before lhd wrote its verdict
    out = {'verdict': verdict or 'failed', 'bounded': proof.get('bounded'), 'note': note, 'cap_s': cap,
           'wall_s': time.monotonic() - t0}
    if out['verdict'].startswith('timeout'):
        out['assumed'] = LEC_ASSUMED
    return out


def prepare_lec(a, d, out, lib):
    """Once per design: gensim cell models of the merged Liberty and an lhd compile reference."""
    import guard
    cells, ref_lg = out / 'cells', out / 'ref_lg'
    guard.root = out
    env = {'GUARD_MEMORY_LIMIT_GIB': str(a.mem_gib)}
    if not cells.exists():
        guard.run('gensim', [L.LHD, 'pass', 'liberty', 'gensim', lib, '--emit-dir', 'lg:%s' % cells,
                             '--workdir', out / 'gensim_w', '-q'], cwd=out, timeout=a.timeout, extra_env=env)
    if not ref_lg.exists():
        sets, slang = compile_inputs(d)
        cmd = [L.LHD, 'compile'] + [str(p) for p in d.verilog_files()] + ['--top', d.name, '--workdir', out / 'ref_w',
                                                                          '--emit-dir', 'lg:%s' % ref_lg]
        for k, v in sets.items():
            cmd += ['--set', '%s=%s' % (k, v)]
        if d.macro_lefs():
            # lhd synth resolves the fakeram macros from synth.liberty; the compile reference has no
            # Liberty, so the macros (the only modules without RTL) stay body-less blackbox instances.
            slang = slang + ['--ignore-unknown-modules']
        guard.run('ref_compile', cmd + ['--'] + slang, cwd=out, timeout=a.timeout, extra_env=env)
    return ref_lg, cells


def compile_inputs(d):
    """The reader flags run_variant gives lhd synth (compile.* design sets and slang args)."""
    cfg = json.loads((L.TOOLS / 'design_config.json').read_text()).get(d.key, {}).get('sets', {})
    sets = {k: v for k, v in cfg.items() if k.startswith('compile.')}
    slang = ['-D', 'SYNTHESIS', '--ignore-assertions', '--compat=vcs', '--timescale=1ns/1ps']
    for inc in d.include_dirs():
        slang += ['-I', str(inc)]
    slang += d.defines() + d.extra_slang()[0]
    return sets, slang


# ---------------------------------------------------------------------- run
def run_design(a, key, out_root, manifest):
    arms_mod, view_mod = livehd_modules(a.livehd_src)
    d = L.get(key)
    sdc = d.ref_dir / 'constraint.sdc'
    port = DOMINO_CLOCK.get(key)
    if not port:
        raise SystemExit('domplace.py: %s has no domino_clock entry' % key)
    found = sdc_clock_port(sdc)
    if port not in found:
        raise SystemExit('domplace.py: %s: table clock %s, SDC clocks %s' % (key, port, found))
    out = out_root / d.safe
    out.mkdir(parents=True, exist_ok=True)
    legs = plan(a, port)
    synth_sdc = sdc
    if a.sdc == 'flattened':
        # The OpenSTA-written SDC of the reference (3_place.sdc): the same clocks and IO delays as
        # constraint.sdc with Tcl variables resolved, which LiveHD's SDC reader (and so the stage
        # timer's input/output delays) can read. OpenSTA scoring already uses it.
        synth_sdc = L.adapt_sdc(d.ref_dir / '3_place.sdc', out / 'synth.sdc')
        if port not in sdc_clock_port(synth_sdc):
            raise SystemExit('domplace.py: %s: 3_place.sdc clocks %s' % (key, sdc_clock_port(synth_sdc)))
        legs = [(n, arm, c, dict(sets, **{'synth.sdc': str(synth_sdc)})) for n, arm, c, sets in legs]
    lib = L.merged_liberty(d)
    entry = {'design': key, 'top': d.name, 'domino_clock': port, 'sdc_clocks': found, 'clock_period_ps': L.clock_period(sdc),
             'utilization': a.utilization or d.utilization(), 'density': d.density(), 'merged_liberty': str(lib),
             'merged_liberty_sha256': sha256(lib), 'sdc_sha256': sha256(sdc), 'synth_sdc': str(synth_sdc),
             'synth_sdc_sha256': sha256(synth_sdc),
             'legs': [{'leg': n, 'arm': arm, 'arm_name': ARMS[arm][0], 'core': c, 'sets': s} for n, arm, c, s in legs]}
    manifest['designs'][key] = entry
    write_manifest(out_root, manifest)
    if a.dry_run:
        return []
    ref_lg = cells = None
    if a.lec:
        ref_lg, cells = prepare_lec(a, d, out, lib)
    frames = {}
    if any(c == 'orfs' for _, _, c, _ in legs):
        frames['orfs'] = entry['orfs_frame'] = orfs_frame(d, out)
        write_manifest(out_root, manifest)
    results = []
    for name, arm, core_mode, sets in legs:
        rundir = out / name
        row = {'design': key, 'leg': name, 'arm': arm, 'arm_name': ARMS[arm][0], 'core_mode': core_mode}
        if core_mode in ('fixed', 'orfs'):
            if core_mode not in frames:
                row.update(status='failed', error='the arm-1 area-driven run placed nothing')
                results.append(row)
                continue
            sets = dict(sets, **{'synth.place.utilization': None, 'synth.place.floorplan': frames[core_mode]['frame']})
            row['frame'] = frames[core_mode]
        t0 = time.monotonic()
        r = L.run_variant(d, name, sets, threads=1, timeout=a.timeout, mem_gib=a.mem_gib, rundir=rundir,
                          log=out_root / 'results.jsonl',
                          timing_unmeasured='provisional domino cells have no Liberty timing' if arm == 3 else None,
                          check_placement=a.check_placement)
        meta = r['meta']
        run_json = rundir / 'lhd.run.json'
        guard_meta = json.loads(run_json.read_text()) if run_json.is_file() else {}
        status, result = classify(rundir, meta['status'], arms_mod)
        score_log = rundir / 'score/score.log'
        check = (r.get('score') or {}).get('placement_check')
        if check is None and score_log.is_file():  # strict scoring stops at a failed check_placement
            log_text = score_log.read_text()
            check = 'failed: %s' % '; '.join(re.findall(r'\[(?:WARNING|ERROR) DPL-\d+\][^\n]*', log_text)) \
                if 'DPL-0033' in log_text else None
        row['opensta_check_placement'] = check
        row.update(lhd_wall_s=meta.get('lhd_seconds'), peak_rss_mib=guard_meta.get('tree_peak_mib'),
                   lhd_status=meta['status'], opensta=r.get('score'), opensta_timing=r.get('timing'),
                   opensta_penalty=r.get('penalty'))
        if result.get('error'):
            row['error'] = result['error']
        if status == 'placed':
            try:
                row.update(leg_metrics(rundir, arm, lib, arms_mod, view_mod))
            except Exception as exc:  # a missing report is recorded, never fatal for the remaining legs
                row['metrics_error'] = repr(exc)
            if a.lec:
                row['lec'] = lec(a, d, rundir, arm, ref_lg, cells)
                if row['lec']['verdict'] == 'proven-full' and not row['lec']['bounded']:
                    status = 'ok'
                elif row['lec'].get('assumed'):
                    status = LEC_ASSUMED
                else:
                    status = 'unproven'
            else:
                row['lec'] = {'verdict': 'skipped'}
                status = 'unproven'
            if name == 'arm1-area':
                frames['fixed'] = entry['fixed_frame'] = floorplan_frame(rundir / 'def/out.def', out / 'arm1_area_floorplan.def')
                frames['fixed']['core_die_um'] = row.get('core_die_um')
                write_manifest(out_root, manifest)
        row['status'] = status
        row['harness_wall_s'] = time.monotonic() - t0
        results.append(row)
        print('domplace.py: %s %s: %s in %.1f s (peak %s MiB)' % (key, name, status, row['harness_wall_s'],
                                                                   row.get('peak_rss_mib')), flush=True)
        (out / 'results.json').write_text(json.dumps({'schema': 1, 'design': key, 'legs': results}, indent=1) + '\n')
    return results


def write_manifest(out_root, manifest):
    (out_root / 'manifest.json').write_text(json.dumps(manifest, indent=1, default=str) + '\n')


def new_manifest(a, cmdline):
    src = Path(a.livehd_src)
    diff = git(src, 'diff', 'HEAD')
    harness = {p.name: sha256(p) for p in (HERE / 'domplace.py', HERE / 'lhdsweep.py', HERE / 'guard.py',
                                           HERE / 'score_flow.tcl', HERE / 'design_config.json')}
    return {
        'schema': 1, 'kind': 'hightide_domplace_arms', 'created': datetime.datetime.now().isoformat(timespec='seconds'),
        'dry_run': a.dry_run, 'command': cmdline,
        'lhd': {'path': str(L.LHD), 'sha256': sha256(L.LHD),
                'frozen_sha256_file': (Path(str(L.LHD)).parent / 'lhd.sha256').read_text().split()[0]
                if (Path(str(L.LHD)).parent / 'lhd.sha256').is_file() else None,
                'frozen_source': (Path(str(L.LHD)).parent / 'source.txt').read_text().splitlines()
                if (Path(str(L.LHD)).parent / 'source.txt').is_file() else None},
        'livehd_src': {'path': str(src), 'head': (git(src, 'rev-parse', 'HEAD') or '').strip() or None,
                       'dirty_diff_sha256': hashlib.sha256(diff.encode()).hexdigest() if diff else None,
                       'arms_py_sha256': sha256(src / 'scripts/domplace/arms.py'),
                       'domplace_view_py_sha256': sha256(src / 'scripts/domplace/domplace_view.py')},
        'hightide': {'head': (git(HERE, 'rev-parse', 'HEAD') or '').strip() or None,
                     'branch': (git(HERE, 'rev-parse', '--abbrev-ref', 'HEAD') or '').strip() or None,
                     'dirty_diff_sha256': (lambda t: hashlib.sha256(t.encode()).hexdigest() if t else None)(
                         git(HERE, 'diff', 'HEAD', '--', '.')),
                     'harness_sha256': harness},
        'openroad': {'path': str(L.OPENROAD), 'sha256': sha256(L.OPENROAD)},
        'options': {k: v for k, v in vars(a).items() if k not in ('func',)},
        'notes': ['arms matched: seed, iterations, grid density, ORFS density, no timing-driven placement, resizing or '
                  'resynthesis, io_resynth=0, OpenTimer off, native stage timing on the domino_clock port; '
                  'tmap_trials=1 in arms 2 and 3',
                  'arm 3 OpenSTA setup WNS/TNS withheld (timing-unmeasured); stage_timing.period is the timing metric',
                  'arm 3 stage coefficients are only the --arm3-set ones; none is built in, so without them the stage '
                  'status is incomplete',
                  'core modes: area (ORFS utilization), fixed (frame of the arm-1 area-driven DEF: die, rows, FIXED IO '
                  'pins), orfs (frame of the OpenROAD 3_place.odb: die, rows, FIXED IO pins; tap cells dropped); each '
                  'mode is its own table',
                  'OpenSTA scoring runs check_placement (--check-placement: strict stops the score of an illegal DEF, '
                  'report records it); opensta_check_placement holds the verdict, qor.place.legal is LiveHD legality',
                  'RUDY is the harness estimate (LiveHD final RUDY, plan H3, is not implemented)',
                  'pass.abc.drop_init/derived_clock (lhdsweep base sets) apply only to ABC (arm 1)'],
        'designs': {},
    }


# ------------------------------------------------------------------- report
TSV = ['design', 'core_mode', 'leg', 'arm_name', 'status', 'lec', 'lhd_wall_s', 'peak_rss_mib', 'eligible', 'converted',
       'liberty_um2', 'lef_um2', 'domino_lef_um2', 'domino_instances', 'cells', 'legal', 'multirow_cells', 'eco_displaced',
       'stage_status', 'period_ps', 'limiting', 'c_clk_ff', 'clock_sinks', 'hpwl_um', 'opensta_hpwl_um', 'rudy_peak',
       'rudy_mean', 'opensta_wns_ps', 'opensta_tns_ps', 'logical_cells', 'opensta_check_placement', 'error',
       'reg2reg_period_ps', 'reg2reg_class', 'reg2reg_worst', 'limiting_class', 'max_slew_violations',
       'max_cap_violations', 'max_fanout_violations', 'gp_converged', 'gp_overflow', 'selection_reasons']
# Stage-timing endpoints that are storage (flip-flops, domino states) or clock-gate enables;
# the register-to-register period is the worst class whose launch and capture are both storage.
STORAGE = ('flop', 'domino', 'latch', 'gate')


def reg2reg(stage):
    """(period_ps, 'launch->capture', worst endpoint) of the worst storage-to-storage class."""
    best = None
    for c in stage.get('classes') or []:
        if c.get('launch') in STORAGE and c.get('capture') in STORAGE and c.get('period_ps') is not None:
            if best is None or c['period_ps'] > best['period_ps']:
                best = c
    return (best['period_ps'], '%s->%s' % (best['launch'], best['capture']), best.get('worst')) if best else (None, None, None)


def limiting_class(stage):
    """The launch->capture class whose period is the stage period."""
    classes = [c for c in stage.get('classes') or [] if c.get('period_ps') is not None]
    if not classes:
        return None
    c = max(classes, key=lambda c: c['period_ps'])
    return '%s->%s' % (c['launch'], c['capture'])


def tsv_row(e):
    cov, area, stage = e.get('coverage') or {}, e.get('area') or {}, e.get('stage_timing') or {}
    eco = (e.get('sizing') or {}).get('eco') or e.get('multirow_eco') or {}
    score, rd = e.get('opensta') or {}, e.get('rudy') or {}
    clocks = ((stage.get('clock') or {}).get('clocks') or {})
    values = [e['design'], e['core_mode'], e['leg'], e['arm_name'], e['status'], (e.get('lec') or {}).get('verdict'),
              e.get('lhd_wall_s'), e.get('peak_rss_mib'), cov.get('eligible'), cov.get('converted'), area.get('liberty_um2'),
              area.get('lef_um2'), area.get('domino_lef_um2'), area.get('domino_instances'), area.get('cells'), e.get('legal'),
              (e.get('multirow') or {}).get('cells'), eco.get('displaced_cells'), stage.get('status'), stage.get('period_ps'),
              stage.get('limiting'), stage.get('c_clk_ff'), sum(c['sinks'] for c in clocks.values()) if clocks else None,
              e.get('hpwl_um'), score.get('hpwl_um'), rd.get('peak'), rd.get('mean'), score.get('setup_wns_ps'),
              score.get('setup_tns_ps'), score.get('logical_cells'), e.get('opensta_check_placement'),
              ((e.get('error') or {}).get('message') if isinstance(e.get('error'), dict) else e.get('error')),
              *reg2reg(stage), limiting_class(stage), score.get('max_slew_violations'), score.get('max_cap_violations'),
              score.get('max_fanout_violations'), (e.get('gp') or {}).get('converged'), (e.get('gp') or {}).get('overflow'),
              ','.join('%s=%s' % kv for kv in sorted((cov.get('reasons') or {}).items(), key=lambda kv: -kv[1])) or None]
    return '\t'.join('' if v is None else '%.4f' % v if isinstance(v, float) else str(v).replace('\t', ' ') for v in values)


def report(out_root):
    rows = []
    for f in sorted(Path(out_root).glob('*/results.json')):
        rows += json.loads(f.read_text())['legs']
    text = '\t'.join(TSV) + '\n' + ''.join(tsv_row(r) + '\n' for r in rows)
    (Path(out_root) / 'results.tsv').write_text(text)
    titles = {'area': 'area-driven core (ORFS utilization)', 'fixed': 'fixed frame of the arm-1 area-driven run',
              'orfs': 'fixed frame of the OpenROAD 3_place reference'}
    for mode in ('area', 'fixed', 'orfs'):  # each core mode is its own table
        if not any(r['core_mode'] == mode for r in rows):
            continue
        print('== %s' % titles[mode])
        print('%-18s %-12s %-22s %-12s %8s %6s %10s %10s %9s %9s %8s %7s' % ('design', 'arm', 'status', 'lec', 'lhd_s', 'GiB',
              'lib_um2', 'lef_um2', 'period', 'stage', 'conv', 'or_chk'))
        for r in rows:
            if r['core_mode'] != mode:
                continue
            area, stage, cov = r.get('area') or {}, r.get('stage_timing') or {}, r.get('coverage') or {}
            print('%-18s %-12s %-22s %-12s %8s %6s %10s %10s %9s %9s %8s %7s' % (
                r['design'][:18], r['arm_name'], r['status'], (r.get('lec') or {}).get('verdict', '-'),
                L.fmt(r.get('lhd_wall_s'), 8, 1), L.fmt((r.get('peak_rss_mib') or 0) / 1024, 6, 2),
                L.fmt(area.get('liberty_um2'), 10, 1), L.fmt(area.get('lef_um2'), 10, 1), L.fmt(stage.get('period_ps'), 9, 1),
                stage.get('status', '-'), '%s/%s' % (cov.get('converted', '-'), cov.get('eligible', '-')),
                (r.get('opensta_check_placement') or '-')[:7]))


# ---------------------------------------------------------------------- cli
def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    sub = ap.add_subparsers(dest='cmd', required=True)
    sub.add_parser('designs')
    p = sub.add_parser('run')
    p.add_argument('keys', nargs='+', help='design keys (run in order, serialized), or "all" for the H list')
    p.add_argument('--out', help='default artifacts/domplace_<date>')
    p.add_argument('--livehd-src', default=os.environ.get('LIVEHD_SRC', '/lscratch/renau/wt/dp_hightide'),
                   help='LiveHD tree the frozen lhd was built from (scripts/domplace readers, manifest HEAD)')
    p.add_argument('--arms', default='1,2,3')
    p.add_argument('--core-mode', default='all',
                   help='comma list of area, fixed (arm-1 area-driven frame: die, rows, IO), orfs (OpenROAD 3_place '
                        'frame); both = area,fixed; all = area,fixed,orfs')
    p.add_argument('--utilization', help='override the ORFS CORE_UTILIZATION for the area-driven legs')
    p.add_argument('--sdc', choices=('flattened', 'constraint'), default='flattened',
                   help='synth.sdc of every arm: the reference 3_place.sdc (literal, IO delays readable by '
                        'LiveHD) or the ORFS constraint.sdc (Tcl variables: clock only, IO cut)')
    p.add_argument('--check-placement', choices=('strict', 'report'), default='strict',
                   help="OpenROAD check_placement in scoring: strict stops the score of an illegal DEF (the "
                        "sweep's default); report records it and scores anyway")
    p.add_argument('--seed', type=int, default=1)
    p.add_argument('--iterations', type=int, default=1500)
    p.add_argument('--grid-density', type=int, default=64)
    p.add_argument('--set', action='append', default=[], help='KEY=VALUE for every arm')
    p.add_argument('--arm3-set', action='append', default=[], help='KEY=VALUE for arm 3 only (stage coefficients)')
    p.add_argument('--no-lec', dest='lec', action='store_false')
    p.add_argument('--lec-timeout', default='300', help='LEC wall-time cap (s; formal.timeout is %d s less); a timeout '
                   'is recorded as "timeout (assumed pass)"' % LEC_GRACE_S)
    p.add_argument('--timeout', type=int, default=7200, help='seconds per lhd invocation')
    p.add_argument('--mem-gib', type=float, default=48, help='process-tree memory limit per invocation (guard.py)')
    p.add_argument('--dry-run', action='store_true', help='write the manifest (every leg and its sets) only')
    p = sub.add_parser('report')
    p.add_argument('out')
    a = ap.parse_args()
    if a.cmd == 'designs':
        for key in DESIGNS:
            d = L.get(key)
            print('%-20s top=%-22s clock=%-15s sdc=%s period=%s util=%s dens=%s' % (
                key, d.name, DOMINO_CLOCK[key], sdc_clock_port(d.ref_dir / 'constraint.sdc'),
                L.clock_period(d.ref_dir / 'constraint.sdc'), d.utilization(), d.density()))
        return 0
    if a.cmd == 'report':
        report(a.out)
        return 0
    keys = DESIGNS if a.keys == ['all'] else a.keys
    out_root = Path(a.out or L.HT / 'artifacts' / ('domplace_%s' % datetime.date.today().strftime('%Y%m%d')))
    out_root.mkdir(parents=True, exist_ok=True)
    if (out_root / 'manifest.json').exists():
        manifest = json.loads((out_root / 'manifest.json').read_text())
        manifest.setdefault('invocations', []).append({'command': sys.argv, 'at': time.strftime('%Y-%m-%dT%H:%M:%S')})
    else:
        manifest = new_manifest(a, sys.argv)
    for key in keys:
        if (out_root / L.get(key).safe / 'results.json').exists() and not a.dry_run:
            raise SystemExit('domplace.py: %s already has results in %s (use a new --out)' % (key, out_root))
        run_design(a, key, out_root, manifest)
    if not a.dry_run:
        report(out_root)
    return 0


if __name__ == '__main__':
    sys.exit(main())
