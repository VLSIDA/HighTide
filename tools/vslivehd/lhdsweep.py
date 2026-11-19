#!/usr/bin/env python3
"""Whole-flow LiveHD vs OpenROAD pre-CTS sweeps over the HighTide asap7 designs.

  lhdsweep.py list                         designs with a pre-CTS OpenROAD reference
  lhdsweep.py snapshot [KEY...]            freeze reference inputs and score 3_place.odb
  lhdsweep.py run KEY TAG [--set k=v]...   one LiveHD variant: lhd synth+place, then score
  lhdsweep.py report [KEY...]              results table (best per design, objective)

`--set reader=orfs` starts from the OpenROAD flow's own synthesized netlist instead of the
RTL: ref/<design>/1_2_yosys.v is flattened once by OpenROAD (read_verilog + link_design +
write_verilog, cached in netlists/) and read by `lhd synth` with compile.slang.liberty_cells,
so the ORFS cells stay instances; per-design compile.* front-end sets are dropped.

Boundary: RTL -> `lhd synth` (mapping + native DREAMPlace, pre-CTS) -> common
OpenSTA scoring (score_flow.tcl, placement RC, ideal clocks, the reference SDC and
Liberty set) versus the same scorer on the OpenROAD flow's 3_place.odb.

Objective, lower is better and compared per design (setup only):
    penalty = max(0,-WNS)/scale_w + max(0,-TNS)/scale_t
    scale_w = max(reference max(0,-WNS), 0.05*clock_period)
    scale_t = max(reference max(0,-TNS), 0.05*clock_period)
penalty is 0 exactly when setup timing is met; then fewer logic cells win. Logic
cells exclude fill, tap and endcap cells and include macros only in `macros`.
"""
import argparse, gzip, hashlib, json, os, re, shlex, shutil, subprocess, sys, time
from pathlib import Path

HT = Path(__file__).resolve().parents[2]


def output_base_for_bin(bin_dir):
    """Recognize OUTPUT_BASE/execroot/WORKSPACE/bazel-out/CONFIG/bin."""
    path = Path(bin_dir).resolve()
    if (path.name == 'bin' and len(path.parents) >= 5
            and path.parents[1].name == 'bazel-out' and path.parents[3].name == 'execroot'):
        return path.parents[4]
    return None


# Importing the acceptance gates or asking for help needs no previous build.
OB = output_base_for_bin(HT / 'bazel-bin')
EXEC = OB / 'execroot/_main' if OB else None
SWEEP = HT / 'artifacts/lhdsweep'
TOOLS = Path(__file__).resolve().parent  # this checkout's scorer and configs (a worktree runs its own)
OPENROAD = SWEEP / 'bin/openroad'
LHD = Path(os.environ.get('LHD', str(SWEEP / 'bin/lhd_e/lhd')))
PLATFORM = OB / 'external/orfs+/flow/platforms/asap7' if OB else None
DESIGNS = HT / 'bazel-bin/designs/asap7'
DONT_USE = ['*x1p*_ASAP7*', '*xp*_ASAP7*', 'SDF*', 'ICG*']
sys.path.insert(0, str(TOOLS))


def configure(*, output_base=None, bin_dir=None, out=None, lhd=None, openroad=None):
    """Select explicit campaign paths instead of borrowing an earlier checkout's artifacts."""
    global OB, EXEC, SWEEP, LHD, OPENROAD, PLATFORM, DESIGNS
    selected_base = output_base_for_bin(bin_dir) if bin_dir else None
    if output_base:
        requested_base = Path(output_base).resolve()
        if selected_base is not None and selected_base != requested_base:
            raise ValueError('--bin-dir and --output-base refer to different Bazel builds')
        OB = requested_base
    elif bin_dir:
        OB = selected_base
    if OB is None:
        raise ValueError('no Bazel output base found; build the pre-CTS targets or provide --bin-dir and --output-base')
    EXEC = OB / 'execroot/_main'
    PLATFORM = OB / 'external/orfs+/flow/platforms/asap7'
    if bin_dir:
        DESIGNS = Path(bin_dir).resolve() / 'designs/asap7'
    if out:
        SWEEP = Path(out).resolve()
        if not lhd:
            if os.environ.get('LHD'):
                LHD = Path(os.environ['LHD']).resolve()
            else:
                canonical = SWEEP / 'bin/lhd/lhd'
                legacy = SWEEP / 'bin/lhd_e/lhd'
                LHD = legacy if legacy.is_file() and not canonical.is_file() else canonical
        if not openroad:
            legacy = SWEEP / 'bin/openroad'
            OPENROAD = legacy if legacy.is_file() else legacy / 'openroad'
    if lhd:
        LHD = Path(lhd).resolve()
    if openroad:
        OPENROAD = Path(openroad).resolve()


def check_warm(result):
    """Require actual mapper reuse, not simply a successful second invocation."""
    if result.get('status') != 'pass':
        raise RuntimeError('warm synthesis did not pass')
    inc = result.get('incremental', {})
    compile_cache = inc.get('compile', {})
    if compile_cache.get('misses', 0):
        raise RuntimeError('warm synthesis recompiled source units')
    qor = result.get('qor', {})
    abc = inc.get('abc') or qor.get('abc', {}).get('incremental')
    usyn = qor.get('usyn', {}).get('cache')
    if abc and abc.get('enabled'):
        if (abc.get('misses') != 0 or abc.get('store_failed') != 0
                or abc.get('hits', 0) < 1 or abc.get('hits') != abc.get('regions')):
            raise RuntimeError('warm synthesis did not reuse every mapped color: ' + str(abc))
    elif usyn and usyn.get('enabled'):
        if usyn.get('misses', 0) or usyn.get('invalid', 0) or usyn.get('reused', 0) < 1:
            raise RuntimeError('warm synthesis did not reuse every mapped region: ' + str(usyn))
    else:
        raise RuntimeError('warm synthesis supplied no enabled mapper reuse evidence')
    return dict(compile=compile_cache, abc=abc, usyn=usyn, recipe=result.get('recipe', []))


# ------------------------------------------------------------------ discovery
def resolve(path):
    """Paths in the bazel-orfs variables are relative to the execroot (or the HighTide repo)."""
    p = Path(path)
    if p.is_absolute():
        return p
    # The execroot links only the externals of its last build; the output base keeps them all.
    for root in (EXEC, HT, OB):
        if root is not None and (root / p).exists():
            return (root / p).resolve()
    raise FileNotFoundError(path)


def parse_mk(path):
    out = {}
    for line in Path(path).read_text().splitlines():
        m = re.match(r'^export\s+(\w+)\s*\??=\s*(.*)$', line)
        if m:
            out[m.group(1)] = m.group(2).strip()
    return out


class Design:
    def __init__(self, key, base):
        self.key = key
        self.base = Path(base)
        v = {}
        for f in sorted(self.base.glob('*.args.json')):
            v.update(json.loads(f.read_text()))
        for f in sorted(self.base.glob('*.args.mk')) + sorted(self.base.glob('[1-3]_*.mk')):
            if not f.name.endswith('.short.mk'):
                v.update(parse_mk(f))
        self.vars = v
        self.name = v.get('DESIGN_NAME') or self.base.parent.name
        self.safe = key.replace('/', '__')
        self.ref_dir = SWEEP / 'ref' / self.safe

    def lib_files(self):
        text = (self.base / '1_synth.vars').read_text()
        files = re.findall(r'(\S+\.lib(?:\.gz)?)(?=\s|$)', text)
        return [resolve(f) for f in files]

    def split(self, name):
        return [resolve(t) for t in self.vars.get(name, '').split()]

    def verilog_files(self):
        out = []
        for p in self.split('VERILOG_FILES'):
            if p.is_dir():  # a generated source tree (e.g. a Chisel/sv2v output directory)
                out += sorted(q for q in p.rglob('*') if q.suffix in ('.v', '.sv') and q.is_file())
            else:
                out.append(p)
        return out

    def include_dirs(self):
        raw = self.vars.get('VERILOG_INCLUDE_DIRS', '')
        if '$(' in raw:
            # `$(sort $(dir f1 f2 ...))`: the unique parent directories of the listed files.
            if not re.fullmatch(r'\$\(sort \$\(dir ([^()]*)\)\)', raw.strip()):
                raise ValueError('unsupported make expression in VERILOG_INCLUDE_DIRS: ' + raw[:80])
            files = re.fullmatch(r'\$\(sort \$\(dir ([^()]*)\)\)', raw.strip()).group(1).split()
            return sorted({resolve(f).parent for f in files})
        return self.split('VERILOG_INCLUDE_DIRS')

    def defines(self):
        return shlex.split(self.vars.get('VERILOG_DEFINES', ''))

    def extra_slang(self):
        """-I/-D from SYNTH_SLANG_ARGS (resolved); other yosys-slang flags are reported, not guessed."""
        keep, skipped = [], []
        toks = shlex.split(self.vars.get('SYNTH_SLANG_ARGS', ''))
        i = 0
        while i < len(toks):
            t = toks[i]
            if t in ('-I', '-D') and i + 1 < len(toks):
                val = toks[i + 1]; i += 1
                keep += [t, str(resolve(val)) if t == '-I' else val]
            elif t.startswith('-I') and len(t) > 2:
                keep += ['-I', str(resolve(t[2:]))]
            elif t.startswith('-D') and len(t) > 2:
                keep.append(t)
            else:
                skipped.append(t)
            i += 1
        tp = self.vars.get('VERILOG_TOP_PARAMS', '').split()  # ORFS: `name value ...` top-level parameter overrides
        for n, v in zip(tp[::2], tp[1::2]):
            keep += ['-G', '%s=%s' % (n, v)]
        return keep, skipped

    def utilization(self):
        return float(self.vars['CORE_UTILIZATION']) / 100.0 if 'CORE_UTILIZATION' in self.vars else None

    def density(self):
        return float(self.vars.get('PLACE_DENSITY', 0.60))

    def macro_lefs(self):
        return self.split('ADDITIONAL_LEFS')

    def lef_list(self):
        return [PLATFORM / 'lef/asap7_tech_1x_201209.lef', PLATFORM / 'lef/asap7sc7p5t_28_R_1x_220121a.lef'] + self.macro_lefs()


def discover():
    designs = []
    for odb in sorted(DESIGNS.glob('**/results/asap7/*/base/3_place.mk')):
        if '.runfiles' in str(odb):
            continue
        rel = odb.relative_to(DESIGNS)
        key = str(rel).split('/results/')[0]
        designs.append(Design(key, odb.parent))
    return designs


def get(key):
    for d in discover():
        if d.key == key:
            return d
    raise SystemExit('unknown design %s' % key)


# ----------------------------------------------------------------- reference
def sha(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def clock_period(sdc):
    text = Path(sdc).read_text()
    m = re.findall(r'-period\s+([0-9.eE+-]+)', text) or re.findall(r'set\s+clk_period\s+([0-9.eE+-]+)', text)
    return float(m[0]) if m else None


def score_env(d, sdc, extra_lefs=(), extra_libs=()):
    env = dict(os.environ)
    env.update(LIB_FILES=' '.join(map(str, list(d.lib_files()) + list(extra_libs))), TECH_LEF=str(PLATFORM / 'lef/asap7_tech_1x_201209.lef'),
               SC_LEF=str(PLATFORM / 'lef/asap7sc7p5t_28_R_1x_220121a.lef'),
               ADDITIONAL_LEFS=' '.join(map(str, list(d.macro_lefs()) + list(extra_lefs))), SET_RC_TCL=str(PLATFORM / 'setRC.tcl'),
               SDC_FILE=str(sdc))
    return env


def def_extra_lefs(d, def_dir):
    """LEFs LiveHD placed with beyond the design's own (the domino bundle's domino_cells.lef),
    from the DEF export's lefs.json (paths relative to the DEF directory)."""
    listing = Path(def_dir) / 'lefs.json'
    if not listing.exists():
        return []
    known = {p.resolve() for p in d.lef_list()}
    known_names = {p.name for p in d.lef_list()}
    out = []
    for name in json.loads(listing.read_text()):
        p = (Path(def_dir) / name).resolve()
        # LiveHD copies every LEF it read next to the DEF as <index>_<name>; skip copies of the design's own.
        if p not in known and re.sub(r'^\d+_', '', p.name) not in known_names:
            out.append(p)
    return out


def export_generated_macros(d, rundir):
    """LiveHD-generated SRAM macros (synth.memory=sram): copy their Liberty views next to the DEF and record
    every LEF/Liberty a downstream tool needs beyond the design's own in def/extra_views.json (absolute paths),
    so the scorer and the post-route flow see the macros even after the workdir is pruned."""
    def_dir = Path(rundir) / 'def'
    libs = []
    src = Path(rundir) / 'w/synth/sram'
    if src.is_dir():
        (def_dir / 'lib').mkdir(parents=True, exist_ok=True)
        for p in sorted(src.glob('*.lib')):
            dst = def_dir / 'lib' / p.name
            shutil.copy2(p, dst)
            libs.append(str(dst.resolve()))
    lefs = [str(p) for p in def_extra_lefs(d, def_dir)]
    (def_dir / 'extra_views.json').write_text(json.dumps(dict(lefs=lefs, libs=libs), indent=1) + '\n')
    return lefs, libs


def adapt_sdc(src, dst):
    """Copy an SDC for scoring a LiveHD DEF: LiveHD may add hierarchy containers to instance names,
    in front (`sub_16.pcie_us/user_clk`) and, with nested regions (pass.usyn), between the levels
    (`BUFG_GT_1.__flat___sub_20.clk_buf/Y`), so a literal `get_pins {a.b/c}` becomes
    `get_pins {*a.*b/c}`."""
    text = Path(src).read_text()
    def fix(m):
        name = m.group(2)
        if '*' in name or '[' in name or '/' not in name:
            return m.group(0)
        inst, pin = name.rsplit('/', 1)
        return m.group(1) + '*' + inst.replace('.', '.*') + '/' + pin + m.group(3)
    text = re.sub(r'(get_pins\s+\{?\s*)([^\s\]\}]+)(\s*\}?)', fix, text)
    Path(dst).write_text(text)
    return dst


def run_score(d, source, out, sdc, timeout=7200, extra_lefs=(), check_placement='error', extra_libs=()):
    out = Path(out)
    out.mkdir(parents=True, exist_ok=True)
    env = score_env(d, sdc, extra_lefs, extra_libs)
    if check_placement == 'report':  # record OpenROAD's check_placement verdict instead of failing the score
        env['SCORE_CHECK_PLACEMENT'] = 'report'
    env.update(SCORE_INPUT=str(source), SCORE_OUT=str(out))
    with open(out / 'score.log', 'w') as log:
        rc = subprocess.run([str(OPENROAD), '-no_init', '-exit', '-threads', '4', str(TOOLS / 'score_flow.tcl')],
                            env=env, stdout=log, stderr=subprocess.STDOUT, timeout=timeout).returncode
    sj = out / 'score.json'
    if rc or not sj.exists():
        raise RuntimeError('scoring failed rc=%s (%s)' % (rc, out / 'score.log'))
    return json.loads(sj.read_text())


def snapshot(d):
    ref = d.ref_dir
    ref.mkdir(parents=True, exist_ok=True)
    for name in ('3_place.odb', '3_place.sdc', '1_2_yosys.v', '2_floorplan.sdc'):
        src = d.base / name
        if src.exists() and not (ref / name).exists():
            shutil.copy2(src, ref / name)
    inputs = {}
    sdc = resolve(d.vars['SDC_FILE'])
    shutil.copy2(sdc, ref / 'constraint.sdc')
    info = dict(key=d.key, name=d.name, utilization=d.utilization(), density=d.density(),
                clock_period_ps=clock_period(sdc), vars=d.vars,
                verilog_files=[str(p) for p in d.verilog_files()],
                include_dirs=[str(p) for p in d.include_dirs()], defines=d.defines(),
                lib_files=[str(p) for p in d.lib_files()], macro_lefs=[str(p) for p in d.macro_lefs()],
                snapshot_sha256={n: sha(ref / n) for n in ('3_place.odb', '3_place.sdc') if (ref / n).exists()})
    info['macros'] = bool(d.macro_lefs())
    (ref / 'info.json').write_text(json.dumps(info, indent=1))
    if not (ref / 'score/score.json').exists():
        run_score(d, ref / '3_place.odb', ref / 'score', ref / '3_place.sdc')
    return json.loads((ref / 'score/score.json').read_text())


# ------------------------------------------------------------------ objective
def penalty(score, ref, period):
    wns, tns = score['setup_wns_ps'], score['setup_tns_ps']
    if abs(wns) > 1e30:
        return None  # unknown timing (no constrained paths) is never a pass
    floor = 0.05 * (period or 1000.0)
    nw, nt = max(0.0, -wns), max(0.0, -tns)
    sw = max(max(0.0, -ref['setup_wns_ps']), floor)
    st = max(max(0.0, -ref['setup_tns_ps']), floor)
    return nw / sw + nt / st


def objective(score, ref, period):
    p = penalty(score, ref, period)
    return (p if p is not None else float('inf'), score['logical_cells'])


# ------------------------------------------------------------------ liberty
def merged_liberty(d):
    """One merged asap7 (+macro) Liberty with dont_use applied, cached per design.

    Generated under a lock into a temporary file and renamed, so parallel variants of
    one design never read or write a half-written library.
    """
    import fcntl
    out = SWEEP / 'lib' / ('%s.v2.lib' % d.safe)
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(str(out) + '.lock', 'w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if out.exists():
            return out
        tmp = Path(str(out) + '.tmp.%d' % os.getpid())
        cmd = [sys.executable, str(TOOLS / 'merge_liberty.py')]
        for p in DONT_USE:
            cmd += ['--dont-use', p]
        cmd.append(str(tmp))
        cmd += map(str, [p for p in d.lib_files() if 'asap7sc7p5t' in p.name])
        subprocess.run(cmd, check=True)
        # SRAM macro libraries use other units (ns/pF), so they are appended as their own
        # library groups after the merged standard-cell library, never merged into it.
        with open(tmp, 'a') as f:
            for p in macro_libs(d):
                f.write('\n')
                f.write(Path(p).read_text())
        os.replace(tmp, out)
    return out


def macro_halo(d):
    """ORFS MACRO_PLACE_HALO as (x, y) micron strings: the design's value, else the platform config.mk default."""
    v = d.vars.get('MACRO_PLACE_HALO')
    if not v and PLATFORM is not None and (PLATFORM / 'config.mk').exists():
        v = parse_mk(PLATFORM / 'config.mk').get('MACRO_PLACE_HALO')
    parts = (v or '10 10').split()
    return (parts + parts)[:2]


def macro_libs(d):
    return [p for p in d.lib_files() if 'asap7sc7p5t' not in p.name]


# ------------------------------------------------------------------------ run
def orfs_netlist(d):
    """The ORFS synthesized netlist (ref/<design>/1_2_yosys.v) flattened by OpenROAD, cached
    under netlists/ and generated under a lock (parallel variants of one design share it)."""
    import fcntl
    src = d.ref_dir / '1_2_yosys.v'
    out = SWEEP / 'netlists' / ('%s.flat.v' % d.safe)
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(str(out) + '.lock', 'w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if out.exists():
            return out
        tmp = Path(str(out) + '.tmp.%d' % os.getpid())
        tcl = Path(str(out) + '.tcl')
        tcl.write_text(''.join('read_lef {%s}\n' % p for p in d.lef_list()) +
                       'read_verilog {%s}\nlink_design %s\nwrite_verilog {%s}\n' % (src, d.name, tmp))
        with open(str(out) + '.log', 'w') as log:
            subprocess.run([str(OPENROAD), '-no_init', '-exit', str(tcl)], stdout=log, stderr=subprocess.STDOUT, check=True)
        os.replace(tmp, out)
    return out


def run_variant(d, tag, sets, threads=1, timeout=7200, mem_gib=64, files=None, rundir=None, log=None,
                timing_unmeasured=None, check_placement='error', warm_runs=0):
    """One lhd synth+place run, then OpenSTA scoring. A `sets` value of None removes that key
    (e.g. the ORFS utilization for a fixed-core run). rundir/log default to the sweep's
    runs/<design>/<tag> and results.jsonl. timing_unmeasured (a reason string) keeps the score's
    cell counts and HPWL but withholds its setup WNS/TNS and penalty: the netlist has cells the
    Liberty does not time (the provisional domino profile). check_placement='report' scores a DEF
    that fails OpenROAD's check_placement and records the verdict (score.placement_check)."""
    if not isinstance(warm_runs, int) or warm_runs < 0:
        raise ValueError('warm_runs must be a nonnegative integer')
    import guard
    ref = json.loads((d.ref_dir / 'score/score.json').read_text())
    info = json.loads((d.ref_dir / 'info.json').read_text())
    rundir = Path(rundir) if rundir else SWEEP / 'runs' / d.safe / tag
    log = Path(log) if log else SWEEP / 'results.jsonl'
    if rundir.exists():
        raise SystemExit('run directory exists: %s (use a new tag)' % rundir)
    rundir.mkdir(parents=True)
    guard.root = rundir
    lib = merged_liberty(d)
    util = d.utilization()
    base_sets = {
        'lhd.jobs': str(threads),
        'synth.liberty': str(lib),
        'synth.sdc': str(d.ref_dir / 'constraint.sdc'),
        'synth.lef': ','.join(map(str, d.lef_list())),
        'synth.place': 'true',
        'synth.place.density': '%g' % d.density(),
        'synth.wire_rc': str(PLATFORM / 'setRC.tcl'),
        # No synth.memory here: one option cannot fit every memory of a large design, so LiveHD's default
        # (synth.memory=auto) decides per memory; explicit fakeram instances stay macros. Experiments may
        # pass --set synth.memory=... under their own tag.
        # Yosys drops power-on `initial` values for an ASIC; LiveHD would otherwise keep a native flop.
        'synth.drop_init': 'true',
        # Registers on a gated/derived clock must map to cells (ASAP7 ICGs are dont_use), and Yosys's
        # `setundef -zero` ties x constants low; both keep designs placeable and are inert elsewhere.
        'synth.place.unknown_const': 'zero',
    }
    # Same area as the OpenROAD reference: its die/core (the fixed ORFS DIE_AREA/CORE_AREA, or the die its
    # utilization derived), not a die LiveHD derives from its own utilization.
    base_sets['synth.place.die'] = ','.join('%g' % x for x in ref['die_um'])
    base_sets['synth.place.core'] = ','.join('%g' % x for x in ref['core_um'])
    # Macro halo: the design's ORFS MACRO_PLACE_HALO (asap7 platform default 10 10 um), same clearance as the reference.
    base_sets['synth.place.halo'] = ','.join(macro_halo(d))
    merged = dict(base_sets)
    cfg_file = TOOLS / 'design_config.json'
    if cfg_file.exists():  # per-design defaults found during bring-up (reader, frontend flags, ...)
        merged.update(json.loads(cfg_file.read_text()).get(d.key, {}).get('sets', {}))
    merged.update(sets)
    if 'synth.place.floorplan' in merged:  # the imported floorplan carries die, core, rows and fixed macros
        merged.pop('synth.place.die', None); merged.pop('synth.place.core', None)
    merged = {k: v for k, v in merged.items() if v is not None}
    slang_args = ['-D', 'SYNTHESIS', '--compat=vcs', '--timescale=1ns/1ps']
    reader = merged.pop('reader', 'native')  # a harness-level choice, not an lhd option
    if reader == 'orfs':  # start from the ORFS netlist: RTL front-end sets do not apply
        merged = {k: v for k, v in merged.items() if not k.startswith('compile.') or k in sets}
        merged['compile.slang.liberty_cells'] = 'true'
        files = [orfs_netlist(d)]
    if reader in ('native', 'orfs'):
        # ORFS runs yosys-slang with --ignore-assertions; LiveHD's own reader has the same opt-in.
        slang_args.insert(2, '--ignore-assertions')
    skipped = []
    if reader != 'orfs':
        for inc in d.include_dirs():
            slang_args += ['-I', str(inc)]
        slang_args += d.defines()
        extra, skipped = d.extra_slang()
        slang_args += extra
    sources = [str(p) for p in (files or d.verilog_files())]
    if reader in ('native', 'orfs'):
        cmd = [LHD, 'synth'] + sources
        cmd += ['--top', d.name, '--workdir', rundir / 'w', '--emit-dir', 'def:%s/' % (rundir / 'def'),
                '--emit-dir', 'report:%s/' % (rundir / 'rep'), '--stats', '--result-json', rundir / 'result.json']
        for k, v in merged.items():
            cmd += ['--set', '%s=%s' % (k, v)]
        cmd += ['--'] + slang_args
        pre = None
    else:
        # Same front end as the OpenROAD flow: yosys-slang elaborates to lg:, then lhd synth reads it.
        lg = rundir / 'lg'
        pre = [LHD, 'compile'] + sources + ['--reader', 'yosys-slang', '--top', d.name, '--workdir', rundir / 'w_compile',
                                              '--emit-dir', 'lg:%s/' % lg]
        mlibs = macro_libs(d)
        if mlibs:
            pre += ['--set', 'compile.yosys.macrolib=%s' % ','.join(map(str, mlibs))]
        pre += ['--'] + slang_args
        cmd = [LHD, 'synth', 'lg:%s' % lg, '--top', d.name, '--workdir', rundir / 'w', '--emit-dir', 'def:%s/' % (rundir / 'def'),
               '--emit-dir', 'report:%s/' % (rundir / 'rep'), '--stats', '--result-json', rundir / 'result.json']
        for k, v in merged.items():
            cmd += ['--set', '%s=%s' % (k, v)]
    meta = dict(design=d.key, tag=tag, sets=sets, effective_sets=merged, skipped_slang_args=skipped, lhd=str(LHD), lhd_sha256=sha(LHD),
                started=time.strftime('%Y-%m-%dT%H:%M:%S'))
    t0 = time.monotonic()
    status = 'ok'
    validation_start = None
    try:
        genv = {'GUARD_MEMORY_LIMIT_GIB': str(mem_gib), 'OMP_NUM_THREADS': str(threads)}
        if pre is not None:
            guard.run('lhd_compile', pre, cwd=rundir, timeout=timeout, extra_env=genv)
        guard.run('lhd', cmd, cwd=rundir, timeout=timeout, extra_env=genv)
        if warm_runs:
            validation_start = time.monotonic()
            cold = rundir / 'result.cold.json'
            shutil.copy2(rundir / 'result.json', cold)
            before = {p.name: sha(p) for p in (rundir / 'def').glob('*.def')}
            warm_checks = []
            for number in range(1, warm_runs + 1):
                guard.run('lhd_warm%d' % number, cmd, cwd=rundir, timeout=timeout, extra_env=genv)
                warm = rundir / ('result.warm%d.json' % number)
                shutil.copy2(rundir / 'result.json', warm)
                proof = check_warm(json.loads(warm.read_text()))
                after = {p.name: sha(p) for p in (rundir / 'def').glob('*.def')}
                if after != before:
                    raise RuntimeError('warm synthesis changed the exported placement')
                proof['placement_sha256'] = after
                warm_checks.append(proof)
                (rundir / 'incremental.json').write_text(json.dumps(warm_checks, indent=2) + '\n')
            replay = rundir / 'result.replay.json'
            guard.run('lhd_replay', [LHD, 'synth', '--result-json', replay],
                      cwd=rundir / 'w/synth', timeout=timeout, extra_env=genv)
            recipe = json.loads(replay.read_text()).get('recipe', [])
            replay_result = json.loads(replay.read_text())
            if not recipe or not recipe[0].startswith('synth: up to date'):
                # Filelists and external emits require dependency inspection;
                # replay must still reuse every mapped color.
                check_warm(replay_result)
            after = {p.name: sha(p) for p in (rundir / 'def').glob('*.def')}
            if after != before:
                raise RuntimeError('saved synthesis replay changed the exported placement')
    except Exception as exc:  # guard stop, nonzero exit or timeout: keep as an incomplete run
        status = 'failed: %s' % exc
        error_file = rundir / 'result.json'
        if error_file.exists():
            failure = json.loads(error_file.read_text()).get('error')
            if failure:
                print(json.dumps(failure, indent=2), flush=True)
    ended = time.monotonic()
    meta['native_workflow_seconds'] = ended - t0
    cold_time = rundir / 'lhd.run.json'
    meta['lhd_seconds'] = json.loads(cold_time.read_text())['wall_s'] if cold_time.exists() else 0.0
    compile_time = rundir / 'lhd_compile.run.json'
    if pre is not None:
        meta['lhd_compile_seconds'] = json.loads(compile_time.read_text())['wall_s'] if compile_time.exists() else 0.0
    if warm_runs:
        meta['incremental_validation_seconds'] = ended - validation_start if validation_start is not None else 0.0
    meta['status'] = status
    defs = sorted((rundir / 'def').glob('*.def')) if status == 'ok' else []
    result = dict(meta=meta, ref=ref)
    if defs:
        t1 = time.monotonic()
        try:
            sdc = adapt_sdc(d.ref_dir / '3_place.sdc', rundir / 'score_pins.sdc')
            extra_lefs, extra_libs = export_generated_macros(d, rundir)
            score = run_score(d, defs[0], rundir / 'score', sdc, extra_lefs=extra_lefs,
                              check_placement=check_placement, extra_libs=extra_libs)
            if timing_unmeasured:
                score['opensta_setup_unmeasured'] = {k: score[k] for k in ('setup_wns_ps', 'setup_tns_ps', 'hold_wns_ps', 'hold_tns_ps')}
                score.update(setup_wns_ps=None, setup_tns_ps=None, hold_wns_ps=None, hold_tns_ps=None)
                result['timing'] = 'timing-unmeasured: %s' % timing_unmeasured
            result['score'] = score
            if not timing_unmeasured:
                result['penalty'] = penalty(score, ref, info['clock_period_ps'])
                result['objective'] = objective(score, ref, info['clock_period_ps'])
        except Exception as exc:
            meta['status'] = 'score failed: %s' % exc
        meta['score_seconds'] = time.monotonic() - t1
    elif status == 'ok':
        meta['status'] = 'no DEF produced'
    result['lhd_report'] = lhd_report(rundir)
    (rundir / 'result_full.json').write_text(json.dumps(result, indent=1))
    with open(log, 'a') as f:
        f.write(json.dumps(dict(design=d.key, tag=tag, sets=sets, status=meta['status'], lhd_seconds=meta['lhd_seconds'],
                                score=result.get('score'), penalty=result.get('penalty'), timing=result.get('timing'),
                                ref=ref)) + '\n')
    return result


def lhd_report(rundir):
    """LiveHD's own report: the placement summary, and USYN's physical (domino) block when present."""
    out = {}
    for name in ('qor.json', 'placement.json'):
        p = Path(rundir) / 'rep' / name
        if p.exists():
            try:
                q = json.loads(p.read_text())
            except ValueError:
                continue
            out.update({k: q.get(k) for k in ('kind', 'mode', 'legal', 'gp_converged', 'gp_overflow', 'hpwl_um', 'cells',
                                               'multirow', 'multirow_eco') if k in q})
    usyn = Path(rundir) / 'w/synth/qor.json.usyn.json'
    if usyn.exists():
        try:
            u = json.loads(usyn.read_text())
            out['usyn'] = {k: u.get(k) for k in ('output', 'physical_profile')}
            physical = u.get('physical')
            if physical:
                out['usyn']['physical'] = {k: physical.get(k) for k in ('settings', 'totals', 'bundle')}
        except ValueError:
            pass
    return out


# ------------------------------------------------------------------------ cli
def fmt(x, w=9, p=1):
    return ('%*.*f' % (w, p, x)) if isinstance(x, (int, float)) else '%*s' % (w, '-')


def report(keys):
    rows = {}
    for line in (SWEEP / 'results.jsonl').read_text().splitlines() if (SWEEP / 'results.jsonl').exists() else []:
        r = json.loads(line)
        rows.setdefault(r['design'], []).append(r)
    print('%-22s %9s %9s %7s | %9s %9s %7s %8s  %s' % ('design', 'ref_wns', 'ref_tns', 'ref_c', 'wns', 'tns', 'cells', 'penalty', 'tag'))
    for d in discover():
        if keys and d.key not in keys:
            continue
        ref = json.loads((d.ref_dir / 'score/score.json').read_text()) if (d.ref_dir / 'score/score.json').exists() else None
        best = None
        for r in rows.get(d.key, []):
            if r.get('score'):
                k = (r['penalty'] if r['penalty'] is not None else 1e9, r['score']['logical_cells'])
                if best is None or k < best[0]:
                    best = (k, r)
        if not ref:
            continue
        if best:
            s = best[1]['score']
            print('%-22s %s %s %7d | %s %s %7d %8.3f  %s' % (d.key, fmt(ref['setup_wns_ps']), fmt(ref['setup_tns_ps'], 9, 0), ref['logical_cells'],
                  fmt(s['setup_wns_ps']), fmt(s['setup_tns_ps'], 9, 0), s['logical_cells'], best[0][0], best[1]['tag']))
        else:
            print('%-22s %s %s %7d | (no run)' % (d.key, fmt(ref['setup_wns_ps']), fmt(ref['setup_tns_ps'], 9, 0), ref['logical_cells']))


def nonnegative_count(value):
    count = int(value)
    if count < 0:
        raise argparse.ArgumentTypeError('expected a nonnegative count')
    return count


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--output-base', type=Path, help='Bazel output base for the selected HighTide build')
    ap.add_argument('--bin-dir', type=Path, help='exact bazel-bin output directory for this invocation/configuration')
    ap.add_argument('--out', type=Path, help='fresh campaign root for references, workdirs, logs and results')
    ap.add_argument('--lhd', type=Path, help='frozen source-built LiveHD executable')
    ap.add_argument('--openroad', type=Path, help='source-built OpenROAD used by the reference and scorer')
    sub = ap.add_subparsers(dest='cmd', required=True)
    sub.add_parser('list')
    p = sub.add_parser('snapshot'); p.add_argument('keys', nargs='*')
    p = sub.add_parser('run'); p.add_argument('key'); p.add_argument('tag')
    p.add_argument('--set', action='append', default=[]); p.add_argument('--threads', type=int, default=1)
    p.add_argument('--warm-runs', type=nonnegative_count, default=0, help='repeat the exact command in the same workdir and require every mapped color to be reused')
    p.add_argument('--timeout', type=int, default=7200); p.add_argument('--mem-gib', type=float, default=64)
    p = sub.add_parser('report'); p.add_argument('keys', nargs='*')
    a = ap.parse_args()
    try:
        configure(output_base=a.output_base, bin_dir=a.bin_dir, out=a.out, lhd=a.lhd, openroad=a.openroad)
    except ValueError as error:
        ap.error(str(error))
    if a.cmd == 'list':
        for d in discover():
            print(d.key, d.name, 'macros' if d.macro_lefs() else '', 'util=%s dens=%s' % (d.utilization(), d.density()))
    elif a.cmd == 'snapshot':
        for d in discover():
            if a.keys and d.key not in a.keys:
                continue
            s = snapshot(d)
            print('%-22s wns=%9.2f tns=%11.1f logic_cells=%d macros=%d' % (d.key, s['setup_wns_ps'], s['setup_tns_ps'], s['logical_cells'], s['macros']), flush=True)
    elif a.cmd == 'run':
        sets = dict(x.split('=', 1) for x in a.set)
        r = run_variant(get(a.key), a.tag, sets, a.threads, a.timeout, a.mem_gib, warm_runs=a.warm_runs)
        print(json.dumps({k: r.get(k) for k in ('penalty', 'objective', 'score')}, indent=1)[:1500]); print(r['meta']['status'])
        if r['meta']['status'] != 'ok':
            raise SystemExit(1)
    elif a.cmd == 'report':
        report(a.keys)


if __name__ == '__main__':
    main()
