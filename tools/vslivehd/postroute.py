#!/usr/bin/env python3
"""Post-route comparison: OpenROAD/ORFS reference vs LiveHD placements.

Every variant runs the SAME ORFS stages from a deployed `<design>_cts_deps`
environment (bazel-orfs pkg_tar), so CTS, global route, detailed route, fill
and the final report (RCX SPEF timing) use identical variables and tools:

  ref     the reference's own 3_place.odb (identical to the campaign snapshot)
  <tag>   a LiveHD placement DEF (runs/<design>/<tag>/def/out.def):
            postroute_import.tcl   DEF -> 2_2_floorplan_macro.odb (macros FIRM)
            ORFS 2_3 tapcell, 2_4 pdn on LiveHD's placement
            postroute_prelegal.tcl record LiveHD positions -> 3_4_place_resized
            ORFS 3_5 detailed placement (legalize around taps/PDN)
            postroute_displacement.tcl  displacement + check_placement
then:     ORFS 4 cts, 5_1 grt, 5_2 detailed route, 5_3 fill, 6 final report.

Usage:
  postroute.py run DESIGN VARIANT [--campaign DIR] [--out DIR] [--cores N]
  postroute.py report [--out DIR]
Bazel uses a dedicated output base (--output-base) so it never contends with
other HighTide builds.
"""
import argparse
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

HT = Path(__file__).resolve().parents[2]
TOOLS = Path(__file__).resolve().parent
DEFAULT_OB = '/lscratch/renau/bazel_disk_cache/_bazel_renau/hightide-route'
DEFAULT_CAMPAIGN = HT / 'artifacts/prects-20261117'
DEFAULT_OUT = HT / 'artifacts/postroute-20261117'

STAGES_LHD_FLOOR = ['do-2_3_floorplan_tapcell', 'do-2_4_floorplan_pdn', 'do-2_floorplan', 'do-2_floorplan.sdc']
STAGES_DP = ['do-3_5_place_dp', 'do-3_place', 'do-3_place.sdc']
STAGES_ROUTE = ['do-4_1_cts', 'do-4_cts', 'do-5_1_grt', 'do-5_2_route', 'do-5_3_fillcell', 'do-5_route',
                'do-5_route.sdc', 'do-6_1_fill', 'do-6_1_fill.sdc', 'do-6_final.sdc', 'do-6_report']


def design_pkg(key):
    """designs/asap7/<key> package and ORFS DESIGN_NAME-independent target base name."""
    pkg = 'designs/asap7/' + key
    base = key.split('/')[-1]
    m = re.search(r'hightide_design\(\s*name\s*=\s*"([^"]+)"', (HT / pkg / 'BUILD.bazel').read_text())
    if m:  # the flow name, e.g. bp_uno's package declares name = "bp_processor"
        base = m.group(1)
    return pkg, base


def bazel(ob, *args, **kw):
    return subprocess.run(['bazel', '--output_base=' + ob, *args], cwd=HT, **kw)


def deploy(ob, key, dst):
    """Build <base>_cts_deps and extract it as a runnable ORFS directory (bazel-orfs deps_wrapper layout)."""
    pkg, base = design_pkg(key)
    target = '//%s:%s_cts_deps' % (pkg, base)
    for attempt in range(60):  # concurrent deploys share one output base: wait out its lock
        r = bazel(ob, 'build', target, capture_output=True, text=True)
        if r.returncode == 0 or 'Another command' not in r.stderr:
            break
        time.sleep(60)
    if r.returncode:
        raise RuntimeError('bazel build %s failed:\n%s' % (target, r.stderr[-3000:]))
    tar = Path(ob) / 'execroot/_main/bazel-out/k8-fastbuild/bin' / pkg / ('%s_cts_deps.tar.gz' % base)
    if dst.exists():
        subprocess.run(['chmod', '-R', 'u+w', str(dst)])
        shutil.rmtree(dst)
    dst.mkdir(parents=True)
    subprocess.run(['tar', '-xzf', str(tar), '-C', str(dst)], check=True)
    rf = glob.glob(str(dst / '*.runfiles'))
    if rf:
        for p in Path(rf[0]).iterdir():
            shutil.move(str(p), str(dst / p.name))
        os.rmdir(rf[0])
    make_bin = glob.glob(str(dst / 'make_*'))[0]
    short = glob.glob(str(dst / '*.short.mk'))
    if short:
        shutil.copy(short[0], dst / '_main/config.mk')
    (dst / 'make').write_text(
        '#!/usr/bin/env bash\nset -euo pipefail\ncd "$(dirname "$0")/_main"\n'
        'find . -not -perm -u+w -exec chmod u+w {} + 2>/dev/null || true\n'
        'export RUNFILES_DIR="$(pwd)/.."\nexec ../%s "$@"\n' % os.path.basename(make_bin))
    os.chmod(dst / 'make', 0o755)
    subprocess.run(['chmod', '-R', 'u+w', str(dst)])
    # Floorplan-stage inputs (design pdn.tcl, io.tcl, macro placement tcl, ...)
    # are not part of a cts-stage deploy; LiveHD runs tapcell/PDN, so copy them.
    src_dir = HT / pkg
    dst_dir = dst / '_main' / pkg
    dst_dir.mkdir(parents=True, exist_ok=True)
    for p in src_dir.iterdir():
        if p.is_file() and p.suffix in ('.tcl', '.cfg', '.txt') and not (dst_dir / p.name).exists():
            shutil.copy(p, dst_dir / p.name)
    ext = dst / '_main/external'
    ext.mkdir(exist_ok=True)
    for p in dst.iterdir():
        if p.is_dir() and p.name not in ('_main', '_repo_mapping'):
            link = ext / p.name
            if not link.exists():
                link.symlink_to('../../' + p.name)
    return dst


def make(dst, targets, log, cores, extra=()):
    env = dict(os.environ, NUM_CORES=str(cores))
    t0 = time.time()
    with open(log, 'a') as f:
        for t in targets:
            f.write('\n### make %s\n' % t)
            f.flush()
            rc = subprocess.run([str(dst / 'make'), t, *extra], env=env, stdout=f, stderr=subprocess.STDOUT).returncode
            if rc:
                return t, time.time() - t0
    return None, time.time() - t0


def deployed_vars(dst):
    """ADDITIONAL_LEFS/LIBS as the deployed ORFS stage config sets them (paths relative to _main)."""
    out = {}
    for mk in sorted(glob.glob(str(dst / '*.short.mk'))):
        for line in Path(mk).read_text().splitlines():
            m = re.match(r'^export\s+(ADDITIONAL_LEFS|ADDITIONAL_LIBS)\s*\??=\s*(.*)$', line)
            if m:
                out[m.group(1)] = m.group(2).strip()
    return out


def results_dir(dst, key):
    d = glob.glob(str(dst / '_main/designs/asap7' / key / 'results/asap7/*/base'))
    return Path(d[0])


def logs_dir(dst, key):
    d = glob.glob(str(dst / '_main/designs/asap7' / key / 'logs/asap7/*/base'))
    return Path(d[0]) if d else None


def reports_dir(dst, key):
    d = glob.glob(str(dst / '_main/designs/asap7' / key / 'reports/asap7/*/base'))
    return Path(d[0]) if d else None


def metrics(dst, key):
    L = logs_dir(dst, key)
    out = {}
    if L is None:
        return out

    def j(name):
        p = L / (name + '.json')
        return json.loads(p.read_text()) if p.exists() else {}
    g, r, f, c = j('5_1_grt'), j('5_2_route'), j('6_report'), j('4_1_cts')
    out['cts_ws_ps'] = c.get('cts__timing__setup__ws')
    out['cts_tns_ps'] = c.get('cts__timing__setup__tns')
    out['grt_wirelength'] = g.get('globalroute__global_route__wirelength')
    out['grt_vias'] = g.get('globalroute__global_route__vias')
    out['grt_ws_ps'] = g.get('globalroute__timing__setup__ws')
    out['grt_tns_ps'] = g.get('globalroute__timing__setup__tns')
    out['utilization'] = g.get('globalroute__design__instance__utilization') or f.get('finish__design__instance__utilization')
    out['drc_errors'] = r.get('detailedroute__route__drc_errors')
    its = sorted((int(k.split(':')[1]), v) for k, v in r.items() if k.startswith('detailedroute__route__drc_errors__iter:'))
    out['drc_iters'] = [v for _, v in its]
    out['drt_wirelength'] = r.get('detailedroute__route__wirelength')
    out['drt_vias'] = r.get('detailedroute__route__vias')
    out['final_ws_ps'] = f.get('finish__timing__setup__ws')
    out['final_tns_ps'] = f.get('finish__timing__setup__tns')
    out['final_instance_area'] = f.get('finish__design__instance__area')
    out['final_core_area'] = f.get('finish__design__core__area')
    for k, v in f.items():
        if k.startswith('finish__design__instance__area__class:'):
            out.setdefault('area_class', {})[k.split(':', 1)[1]] = v
    # GRT overflow / congestion from the log (FastRoute prints the final overflow table)
    gl = L / '5_1_grt.log'
    if gl.exists():
        txt = gl.read_text(errors='replace')
        for line in txt.splitlines():
            if 'Total' in line and line.split()[0] == 'Total' and len(line.split()) >= 5:
                out['grt_total_line'] = ' '.join(line.split())
            if '[INFO GRT-0' in line and 'overflow' in line.lower():
                out.setdefault('grt_overflow_msgs', []).append(line.strip()[:200])
        if 'GRT-0116' in txt:
            out['grt_congestion_error'] = True
    for name in ('4_1_cts', '5_1_grt', '5_2_route', '6_report', '3_5_place_dp'):
        p = L / (name + '.log')
        if p.exists():
            out.setdefault('stage_seconds', {})
            for line in p.read_text(errors='replace').splitlines()[-30:]:
                if line.startswith('Elapsed time:'):
                    try:
                        mm, ss = line.split()[2].split(':')[-2:]
                        hh = line.split()[2].split(':')[0] if line.split()[2].count(':') == 2 else 0
                        out['stage_seconds'][name] = int(hh) * 3600 + int(mm) * 60 + float(ss.rstrip('[h:]min'))
                    except Exception:
                        pass
    return out


def legroute_plan(run_dir):
    """legroute's own plan overflow estimate (qor.place.legroute* / legroute_plan_selection.json)."""
    out = {}
    for p in glob.glob(str(Path(run_dir) / 'w/**/legroute_plan_selection.json'), recursive=True):
        try:
            out['plan_selection'] = json.loads(Path(p).read_text())
        except Exception:
            pass
    rc = Path(run_dir) / 'result.cold.json'
    if rc.exists():
        try:
            pl = json.loads(rc.read_text()).get('qor', {}).get('place', {})
            for k, v in pl.items():
                if 'legroute' in k.lower() or k in ('route_model',):
                    s = json.dumps(v)
                    out[k] = v if len(s) < 4000 else ('<%d bytes>' % len(s))
        except Exception:
            pass
    return out


def run(args):
    key, variant = args.design, args.variant
    out = Path(args.out)
    safe = key.replace('/', '__')
    dst = out / 'work' / ('%s__%s' % (safe, variant))
    log = out / 'logs' / ('%s__%s.log' % (safe, variant))
    log.parent.mkdir(parents=True, exist_ok=True)
    log.write_text('')
    rec = dict(design=key, variant=variant, started=time.strftime('%Y-%m-%dT%H:%M:%S'))
    t0 = time.time()
    try:
        deploy(args.output_base, key, dst)
        R = results_dir(dst, key)
        if variant == 'ref':
            snap = Path(args.campaign) / 'ref' / safe / '3_place.odb'
            if snap.exists() and (R / '3_place.odb').exists():
                same = subprocess.run(['cmp', '-s', str(snap), str(R / '3_place.odb')]).returncode == 0
                rec['ref_place_matches_campaign'] = same
        if variant != 'ref':
            run_dir = Path(args.campaign) / 'runs' / safe / variant
            ldef = run_dir / 'def/out.def'
            sdc = run_dir / 'score_pins.sdc'
            if not ldef.exists():
                raise RuntimeError('no LiveHD DEF ' + str(ldef))
            if not sdc.exists():
                raise RuntimeError('no LiveHD scoring SDC ' + str(sdc))
            rec['lhd_def'] = str(ldef)
            try:
                rec['lhd_prects_score'] = json.loads((run_dir / 'score/score.json').read_text())
            except Exception:
                pass
            rec['legroute_plan'] = legroute_plan(run_dir)
            for stale in ('2_floorplan.odb', '2_floorplan.sdc', '3_place.odb', '3_place.sdc'):
                if (R / stale).exists():
                    (R / stale).unlink()
            pos = dst / 'lhd_positions.tsv'
            disp = dst / 'lhd_displacement.json'
            steps = [(['run', 'RUN_SCRIPT=%s' % (TOOLS / 'postroute_import.tcl'), 'RUN_LOG_NAME_STEM=lhd_import'],
                      dict(LHD_DEF=str(ldef), LHD_SDC=str(sdc)))]
            # LiveHD-generated macros (synth.memory=sram): every ORFS stage must read their LEF and Liberty.
            # The deployed config sets ADDITIONAL_LEFS/LIBS with ?=, so the environment extends it.
            extra = run_dir / 'def/extra_views.json'
            for var in ('ADDITIONAL_LEFS', 'ADDITIONAL_LIBS'):
                os.environ.pop(var, None)
            if extra.exists():
                views = json.loads(extra.read_text())
                base = deployed_vars(dst)
                for var, key in (('ADDITIONAL_LEFS', 'lefs'), ('ADDITIONAL_LIBS', 'libs')):
                    if views.get(key):
                        os.environ[var] = ' '.join([base.get(var, '')] + views[key]).strip()
                rec['generated_macro_views'] = views
            os.environ['LHD_DEF'] = str(ldef)
            os.environ['LHD_SDC'] = str(sdc)
            os.environ['LHD_POS'] = str(pos)
            os.environ['LHD_DISP'] = str(disp)
            bad, _ = make(dst, ['run'], log, args.cores,
                          extra=('RUN_SCRIPT=%s' % (TOOLS / 'postroute_import.tcl'), 'RUN_LOG_NAME_STEM=lhd_import'))
            if bad:
                raise RuntimeError('LiveHD import failed')
            bad, _ = make(dst, STAGES_LHD_FLOOR, log, args.cores)
            if bad:
                raise RuntimeError('floorplan step failed: ' + bad)
            bad, _ = make(dst, ['run'], log, args.cores,
                          extra=('RUN_SCRIPT=%s' % (TOOLS / 'postroute_prelegal.tcl'), 'RUN_LOG_NAME_STEM=lhd_prelegal'))
            if bad:
                raise RuntimeError('prelegal failed')
            bad, _ = make(dst, STAGES_DP, log, args.cores)
            if bad:
                raise RuntimeError('detailed placement failed: ' + bad)
            make(dst, ['run'], log, args.cores,
                 extra=('RUN_SCRIPT=%s' % (TOOLS / 'postroute_displacement.tcl'), 'RUN_LOG_NAME_STEM=lhd_disp'))
            if disp.exists():
                rec['legalization'] = json.loads(disp.read_text())
        bad, secs = make(dst, STAGES_ROUTE, log, args.cores)
        rec['route_flow_seconds'] = round(secs, 1)
        rec['failed_stage'] = bad
        rec['status'] = 'ok' if bad is None else 'failed'
    except Exception as e:  # noqa: BLE001 -- record and continue
        rec['status'] = 'error'
        rec['error'] = str(e)[:2000]
    rec['wall_seconds'] = round(time.time() - t0, 1)
    try:
        rec['metrics'] = metrics(dst, key)
    except Exception as e:  # noqa: BLE001
        rec['metrics_error'] = str(e)
    rec['route_success'] = rec.get('status') == 'ok' and rec.get('metrics', {}).get('drc_errors') == 0
    with open(out / 'results.jsonl', 'a') as f:
        f.write(json.dumps(rec) + '\n')
    print(json.dumps({k: rec.get(k) for k in ('design', 'variant', 'status', 'failed_stage', 'error', 'route_success')}))
    if not args.keep:
        # keep logs/reports/json; drop large stage odbs except the final one
        try:
            for p in results_dir(dst, key).glob('*.odb'):
                if p.name not in ('6_final.odb',) and 'error' not in p.name and 'failed' not in p.name:
                    p.unlink()
        except Exception:
            pass
    return 0 if rec['status'] == 'ok' else 1


def fmt(v, nd=0):
    if v is None:
        return '—'
    if isinstance(v, float):
        return ('%.' + str(nd) + 'f') % v
    return str(v)


def report(args):
    out = Path(args.out)
    rows = {}
    for line in open(out / 'results.jsonl'):
        r = json.loads(line)
        rows[(r['design'], r['variant'])] = r  # last record wins
    lines = ['| design | variant | routed | DRC | DRC by iter | GRT ovfl | GRT WL | DRT WL | vias | util | final WNS ps | '
             'final TNS ps | pre-CTS WNS | legroute plan (outcome/ovfl trk/rounds) | legalize mean/max um | route s |',
             '|---|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---:|']
    order = {'ref': 0, 'h20lr': 1, 'h20': 2}
    for (d, v) in sorted(rows, key=lambda k: (k[0], order.get(k[1], 9), k[1])):
        r = rows[(d, v)]
        m = r.get('metrics', {})
        lg = r.get('legalization') or {}
        pre = (r.get('lhd_prects_score') or {}).get('setup_wns_ps')
        ps = (r.get('legroute_plan') or {}).get('plan_selection') or {}
        plan = ('%s/%s/%s' % (ps.get('outcome'), ps.get('overflow_tracks'), ps.get('rounds_run'))) if ps else '—'
        tl = (m.get('grt_total_line') or '').split()
        govf = tl[-1] if tl else None
        status = r.get('status') + (('@' + r['failed_stage']) if r.get('failed_stage') else '')
        lines.append('| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |' % (
            d, v, ('yes' if r.get('route_success') else 'NO (%s)' % status),
            fmt(m.get('drc_errors')), ','.join(map(str, m.get('drc_iters') or []))[:48], fmt(govf),
            fmt(m.get('grt_wirelength')), fmt(m.get('drt_wirelength')), fmt(m.get('drt_vias')),
            fmt(m.get('utilization'), 3), fmt(m.get('final_ws_ps'), 1), fmt(m.get('final_tns_ps'), 0), fmt(pre, 1), plan,
            ('%s/%s' % (fmt(lg.get('mean_um'), 3), fmt(lg.get('max_um'), 2))) if lg else '—',
            fmt(r.get('route_flow_seconds'), 0)))
    md = '\n'.join(lines) + '\n'
    (out / 'results.md').write_text(md)
    print(md)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--output-base', default=DEFAULT_OB)
    ap.add_argument('--campaign', default=str(DEFAULT_CAMPAIGN))
    ap.add_argument('--out', default=str(DEFAULT_OUT))
    sub = ap.add_subparsers(dest='cmd', required=True)
    p = sub.add_parser('run')
    p.add_argument('design')
    p.add_argument('variant', help="'ref' or a LiveHD run tag (h20, h20lr, ...)")
    p.add_argument('--cores', type=int, default=16)
    p.add_argument('--keep', action='store_true', help='keep intermediate stage odbs')
    sub.add_parser('report')
    a = ap.parse_args()
    if a.cmd == 'run':
        sys.exit(run(a))
    report(a)


if __name__ == '__main__':
    main()
