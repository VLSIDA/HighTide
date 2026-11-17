#!/usr/bin/env python3
"""Optional self-contained OpenROAD checks for explicit IO handoff helpers.

Run with --openroad /path/to/openroad; no benchmark files, platform checkout,
Liberty files, placement, routing, or default flow integration are required.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

TECH = '''VERSION 5.8 ;
BUSBITCHARS "[]" ;
DIVIDERCHAR "/" ;
UNITS
  DATABASE MICRONS 1000 ;
END UNITS
MANUFACTURINGGRID 0.001 ;
LAYER M2
  TYPE ROUTING ; DIRECTION VERTICAL ;
  PITCH 0.048 ; WIDTH 0.018 ; AREA 0.000324 ; SPACING 0.018 ;
END M2
LAYER M4
  TYPE ROUTING ; DIRECTION HORIZONTAL ;
  PITCH 0.048 ; WIDTH 0.024 ; AREA 0.002016 ; SPACING 0.024 ;
END M4
LAYER M5
  TYPE ROUTING ; DIRECTION VERTICAL ;
  PITCH 0.048 ; WIDTH 0.024 ; AREA 0.002016 ; SPACING 0.024 ;
END M5
END LIBRARY
'''

PROBE = r'''
proc snapshot {} {
 set rows {}
 foreach bt [[ord::get_db_block] getBTerms] {
  set net [$bt getNet]
  lappend rows [list [$bt getName] $bt [$net getName] [$bt getIoType] [$bt getSigType]]
  foreach bp [$bt getBPins] {
   set boxes {}
   foreach box [$bp getBoxes] {lappend boxes [list [[$box getTechLayer] getName] [$box xMin] [$box yMin] [$box xMax] [$box yMax]]}
   lappend rows [list [$bt getName] [$bp getPlacementStatus] [lsort $boxes]]
  }
 }
 return [lsort $rows]
}
read_lef $::env(CHECK_TECH)
read_def $::env(CHECK_DEF)
make_tracks M4 -x_offset 0.012 -x_pitch 0.048 -y_offset 0.012 -y_pitch 0.048
make_tracks M5 -x_offset 0.012 -x_pitch 0.048 -y_offset 0.012 -y_pitch 0.048
set before [snapshot]
source $::env(CHECK_HELPER)
if {[snapshot] ne $before} {error "Sourcing helper edited IOs"}
set scenario $::env(CHECK_CASE)
set injected {}
if {$scenario in {rollback_create rollback_destroy}} {
 set injected [expr {$scenario eq "rollback_create" ? "dbBox_create" : "dbBPin_destroy"}]
 rename odb::$injected odb::review_original
 set ::review_calls 0
 proc odb::review_injected {args} {
  incr ::review_calls
  if {$::review_calls==2} {error "injected IO commit failure"}
  return [uplevel 1 [list odb::review_original {*}$args]]
 }
 rename odb::review_injected odb::$injected
}
set bound [expr {$scenario eq "movement_guard" ? 0.0 : 1.0}]
set code [catch {vslivehd::snap_io_pins $::env(CHECK_AUDIT) M4 M5 $bound} result options]
if {$injected ne {}} {rename odb::$injected {};rename odb::review_original odb::$injected}
if {$scenario in {collision stationary_collision pg_stationary_collision edge_touch corner_touch movement_guard rollback_create rollback_destroy}} {
 if {!$code} {error "Expected normalization rejection in $scenario"}
 if {$scenario in {collision stationary_collision pg_stationary_collision edge_touch corner_touch} && ![string match {*IO pin overlap*} $result]} {error "Unexpected collision error: $result"}
 if {$scenario in {rollback_create rollback_destroy} && ![string match {*injected IO commit failure*} $result]} {error "Unexpected rollback error: $result"}
 if {[snapshot] ne $before} {error "Failed normalization changed original IO geometry, identity or status"}
} else {
 if {$code} {return -options $options $result}
 set expected [expr {$scenario eq "valid_stationary" ? 0 : 2}]
 if {$result!=$expected} {error "Unexpected changed count $result for $scenario"}
 set after [snapshot]
 if {[vslivehd::snap_io_pins ${::env(CHECK_AUDIT)}.repeat M4 M5 1.0]!=0 || [snapshot] ne $after} {error "Normalization is not idempotent"}
 if {$scenario eq "valid_stationary" && $after ne $before} {error "Valid adjacent stationary pins changed"}
}
puts "HANDOFF_CHECK_PASS $scenario"
'''


def fixture(case):
    same_net = case == 'same_net'
    pins = [('a', 'shared' if same_net else 'a', 'SIGNAL', 'M2', 20, 1000, 9, 9),
            ('b', 'shared' if same_net else 'b', 'SIGNAL', 'M2', 20, 1200, 9, 9)]
    if case in ('collision', 'same_net'):
        pins[1] = (*pins[1][:5], 1001, *pins[1][6:])
    if case == 'stationary_collision':
        pins[1] = ('b', 'b', 'SIGNAL', 'M4', 42, 1020, 42, 12)
    if case == 'pg_stationary_collision':
        pins.append(('VDD', 'VDD', 'POWER', 'M4', 42, 1020, 42, 12))
    if case == 'valid_stationary':
        pins = [('a', 'a', 'SIGNAL', 'M4', 42, 1020, 42, 12),
                ('b', 'b', 'SIGNAL', 'M4', 42, 1212, 42, 12)]
    if case == 'edge_touch':
        pins = [('a', 'a', 'SIGNAL', 'M4', 42, 1020, 42, 12),
                ('b', 'b', 'SIGNAL', 'M4', 126, 1020, 42, 12)]
    if case == 'corner_touch':
        pins = [('a', 'a', 'SIGNAL', 'M4', 42, 1020, 42, 24),
                ('b', 'b', 'SIGNAL', 'M4', 126, 1068, 42, 24)]
    out = ['VERSION 5.8 ;', 'DIVIDERCHAR "/" ;', 'BUSBITCHARS "[]" ;',
           'DESIGN io_handoff_check ;', 'UNITS DISTANCE MICRONS 1000 ;',
           'DIEAREA ( 0 0 ) ( 10000 10000 ) ;', f'PINS {len(pins)} ;']
    nets = {}
    for name, net, kind, layer, x, y, hw, hh in pins:
        out += [f'- {name} + NET {net} + DIRECTION INPUT + USE {kind}',
                f'  + PORT + LAYER {layer} ( {-hw} {-hh} ) ( {hw} {hh} ) + FIXED ( {x} {y} ) N ;']
        nets.setdefault((net, kind), []).append(name)
    out += ['END PINS', f'NETS {len(nets)} ;']
    for (net, kind), names in nets.items():
        out.append(f'- {net} ' + ' '.join(f'( PIN {name} )' for name in names) + f' + USE {kind} ;')
    out += ['END NETS', 'END DESIGN']
    return '\n'.join(out) + '\n'


def run(binary, work):
    helper = Path(__file__).with_name('prects_handoff.tcl').resolve()
    (work / 'tech.lef').write_text(TECH)
    (work / 'probe.tcl').write_text(PROBE)
    results = []
    for case in ('collision', 'stationary_collision', 'pg_stationary_collision',
                 'edge_touch', 'corner_touch', 'adjacent', 'valid_stationary', 'same_net', 'movement_guard',
                 'rollback_create', 'rollback_destroy'):
        source = work / f'{case}.def'
        source.write_text(fixture(case))
        env = dict(os.environ, CHECK_TECH=str(work / 'tech.lef'),
                   CHECK_DEF=str(source), CHECK_HELPER=str(helper),
                   CHECK_CASE=case, CHECK_AUDIT=str(work / f'{case}.tsv'),
                   DEBUGINFOD_URLS='', OMP_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1')
        result = subprocess.run([str(binary), '-no_init', '-exit', '-threads', '1',
                                 str(work / 'probe.tcl')], env=env,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                text=True, timeout=20)
        (work / f'{case}.log').write_text(result.stdout)
        passed = result.returncode == 0 and f'HANDOFF_CHECK_PASS {case}' in result.stdout
        results.append({'case': case, 'passed': passed, 'exitcode': result.returncode})
        if not passed:
            raise RuntimeError(f'{case} failed; see {work / (case + ".log")}\n{result.stdout[-2000:]}')
    metadata = {'helper_sha256': hashlib.sha256(helper.read_bytes()).hexdigest(),
                'openroad': str(binary), 'cases': results,
                'scope': 'Self-contained optional IO checks; no benchmark or default flow invocation.'}
    (work / 'results.json').write_text(json.dumps(metadata, indent=2) + '\n')
    print(f'PASS: {len(results)} IO handoff cases')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--openroad', default=shutil.which('openroad'))
    parser.add_argument('--workdir', type=Path, help='Keep logs and fixtures in this directory')
    args = parser.parse_args()
    if not args.openroad:
        print('SKIP: optional IO checks require OpenROAD (--openroad PATH)')
        return
    binary = Path(args.openroad).resolve()
    if args.workdir:
        args.workdir.mkdir(parents=True, exist_ok=True)
        run(binary, args.workdir.resolve())
    else:
        with tempfile.TemporaryDirectory(prefix='prects-handoff-check-') as work:
            run(binary, Path(work))


if __name__ == '__main__':
    main()
