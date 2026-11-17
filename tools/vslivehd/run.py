# Run from HighTide, using the prepared experiment inputs described in vslivehd.md.
from pathlib import Path
import hashlib, json, os, shutil, sys
livehd = Path(os.environ['LIVEHD']).resolve()
prepared = Path(os.environ['PREPARED']).resolve()
out = Path(os.environ['VS_OUT']).resolve()
if out.exists():
    raise SystemExit('Use a new VS_OUT; do not overwrite a measured run')
out.mkdir(parents=True)
import guard
guard.root = out
scripts = Path(__file__).resolve().parent
native = livehd / 'bazel-bin/tools/physical_repair'
openroad = Path(os.environ['OPENROAD_EXE']).resolve()
env = json.loads((prepared / 'flow_env.json').read_text())
config_path = prepared / 'cell_swap_fixed/native.json'
if not config_path.exists():
    config_path = prepared / 'native.json'
config = json.loads(config_path.read_text())
config.update(source_def=True, cell_place=True, timing_driven=True,
              iterations=1500, timing_rounds=3, min_iterations=500,
              density_upper_bound=True, fixed_macro_overlap_weight=5.0,
              halo=0, post_density_factor=4, output=str(out / 'livehd_place'))
orout = out / 'openroad'
orout.mkdir()
shutil.copy2(config['def'], orout / 'input.def')
shutil.copy2(scripts / 'audit.tcl', orout / 'audit.tcl')
env.update(OUTPUT=str(orout), SDC_FILE=config['sdc'], NUM_CORES='1',
           OPENROAD_EXE=str(openroad), GUARD_MEMORY_LIMIT_GIB='28',
           QT_QPA_PLATFORM='offscreen')
# Explicitly reject Tcl logic-resynthesis calls without disabling resize/rebuffer.
guard_tcl = '''
namespace eval ::vslivehd {}
foreach cmd {resynth restructure resynth_annealing resynth_genetic} {
  if {[llength [info commands ::$cmd]]} {
    rename ::$cmd ::vslivehd::disabled_$cmd
    proc ::$cmd {args} {error "logic resynthesis disabled for this comparison"}
  }
}
puts "VSLIVEHD: logic_resynthesis=off; sizing and buffer-tree repair remain enabled"
'''
for name in ['control.tcl', 'control_repair.tcl']:
    (out / name).write_text(guard_tcl + (scripts / name).read_text())
shutil.copy2(scripts / 'score.tcl', out / 'score.tcl')
shutil.copy2(native, out / 'physical_repair')
shutil.copy2(openroad, out / 'openroad_executable')
inputs = [Path(config[k]) for k in ['def', 'liberty', 'sdc', 'tech_rc']]
inputs += [Path(p) for p in config['lefs']]
inputs += [config_path, prepared / 'flow_env.json', scripts / 'run.py', scripts / 'guard.py', scripts / 'audit.tcl']
inputs += [out / p for p in ['physical_repair', 'openroad_executable', 'control.tcl', 'control_repair.tcl', 'score.tcl']]
def sha(path):
    with path.open('rb') as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()
(out / 'manifest.json').write_text(json.dumps(dict(
    protocol='fixed SRAM/IO, shared mapped netlist, cell GP then repair, pre-CTS',
    livehd_logic_resynthesis=False, openroad_logic_resynthesis=False,
    native_bins=[64,64], post_density_factor=4, input_sha256={str(p):sha(p) for p in inputs}), indent=2))
(out / 'flow_env.json').write_text(json.dumps(env, indent=2))
def run(tag, argv, extra, timeout=3600):
    guard.run(tag, argv, cwd=livehd, extra_env=extra, timeout=timeout)
native_env = {'OMP_NUM_THREADS':'1', 'GUARD_MEMORY_LIMIT_GIB':'28',
              'RUNFILES_DIR':str(livehd / 'bazel-bin/tools/physical_repair.runfiles')}
(out / 'place.json').write_text(json.dumps(config, indent=2))
run('livehd_place', [out / 'physical_repair', out / 'place.json'], native_env)
repair = dict(config)
repair.pop('cell_place')
repair.update(def_=str(out / 'livehd_place/out.def'), output=str(out / 'livehd_repair'))
repair['def'] = repair.pop('def_')
(out / 'repair.json').write_text(json.dumps(repair, indent=2))
run('livehd_repair', [out / 'physical_repair', out / 'repair.json'], native_env)
def score(name, source, stage):
    dest = out / 'scores' / name
    dest.mkdir(parents=True)
    run('score_'+name, [out / 'openroad_executable','-no_init','-exit','-threads','1',out / 'score.tcl'],
        dict(env, SCORE_INPUT=str(source), SCORE_STAGE=stage, SCORE_OUT=str(dest)))
# Preserve completed native evidence even if the long reference later times out.
score('input', Path(config['def']), 'synth')
score('livehd_place', out / 'livehd_place/out.def', 'place')
score('livehd_repair', out / 'livehd_repair/out.def', 'place')
run('openroad_place', [out / 'openroad_executable','-no_init','-exit','-threads','1',out / 'control.tcl'], env,
    timeout=int(os.environ.get('VS_REFERENCE_TIMEOUT', '10800')))
score('openroad_place', orout / 'control.def', 'place')
run('openroad_repair', [out / 'openroad_executable','-no_init','-exit','-threads','1',out / 'control_repair.tcl'], env)
score('openroad_repair', orout / 'control_repaired.def', 'place')
print('Completed pre-CTS comparison:', out)
