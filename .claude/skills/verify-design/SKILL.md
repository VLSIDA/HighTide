---
name: verify-design
description: Run a design's upstream functional verification testbenches against its RTL to confirm functional correctness before/while doing physical design. Simulator-agnostic — follows whichever simulator the upstream explicitly documents, falls back to an open-source simulator for a plain testbench, and allows a custom/remote backend (e.g. VCS on a server). Use when adding, porting, or updating a design and you want to know the RTL actually works, not just that it synthesizes.
argument-hint: "[design-name]"
---

# Verify a Design with Functional Testbenches

HighTide's flow proves a design *synthesizes and routes*; it does not prove the
RTL *works*. Before you commit hours of PnR to an untested design (or after a
port/update), run the design's upstream functional testbenches against its RTL.
This skill is **simulator-agnostic**: it picks a backend following the
heuristic below, so a given host only needs the simulators it actually has.

## Simulator decision rule

Pick the backend in this order (record the choice in the design's `DECISIONS.md`):

1. **Follow what the upstream explicitly documents.** If the upstream repo
   documents a simulator (a `Makefile` calling `iverilog`, a cocotb test suite,
   a myhdl flow, a `VCS`/`Questa` invocation), use that —
   even if it needs extra setup. This is the authoritative choice.
2. **Fall back to an open-source simulator.** If the archive ships a plain
   Verilog / SystemVerilog self-checking testbench with no documented simulator,
   use an open-source tool (verilator / icarus) for ease of install.
3. **User override.** A user may always set up a custom/remote simulator
   (VCS, Questa) — the harness supports any cocotb backend.

The repo's standard harness (`tools/sim/cocotb_runner.py` → `cocotb.runner`)
can drive **verilator, icarus, vcs, questa, riviera, cxc, nvc, xcelium** from a
single command, so switching backends is usually just changing one word.

## Scope: verify only what the ORFS flow consumes

Verification targets the modules that actually go through ORFS, i.e. the
`hightide_design(top = ...)` of a platform dir (e.g.
`designs/sky130hd/lfsr/BUILD.bazel`) and the hierarchical closure of that top
within `//designs/src/<d>:rtl`. Do **not** try to verify the whole upstream
archive: many archives contain extra modules (parametrizable variants,
alternative configs, unused helpers) that HighTide never synthesizes, and
their testbenches would add noise (or outright fail on stub inputs) without
saying anything about the design we ship.

- Find the ORFS-used top: `grep -r "hightide_design" designs/<platform>/<d>/BUILD.bazel`
  (or check every platform dir if the design is on several — the top is
  normally the same; if platform tops differ, test each distinct top).
- Map that top to its DUT module(s) in the `:rtl` filegroup; the cocotb
  `--toplevel` / verilator `--top-module` should be that top, not some other
  upstream module.
- If an upstream testbench targets a module **outside** that closure, note it
  in `DECISIONS.md` and skip it — it is upstream's problem, not HighTide's.

## Step 1: Discover the design's testbenches

Bring the design's pinned RTL archive down and look for testbenches. The
archive is a `http_archive` in the root `MODULE.bazel` (`@<design>_src`), so
its full upstream tree is available:

```bash
# Materialize the archive (or just `bazel build //designs/src/<d>:sim_sources`
# if the exposure from Step 2 already exists).
bazelisk fetch @<design>_src
tb=$(find "$(bazelisk info execution_root)/external" \
      -maxdepth 2 -type d -name "*<design>_src*" -path "*tb*" | head -1)
echo "$tb"
ls -R "$tb"
```

What you're looking for:

- **cocotb tests** — a `tests/`/`tb/` dir with `*.py` modules annotated
  `@cocotb.test()` (e.g. coralnpu's `tests/cocotb`).
- **plain self-checking Verilog/SV testbenches** — a `tb/*.v` (or `.sv`) that
  instantiates the DUT and asserts (`lfsr`'s `tb/test_lfsr_*.v`).
- **a driver/harness** — how upstream actually invokes it: a `Makefile`, a
  `tox.ini`, a `.py` myhdl driver, a `run.sh`. This tells you the documented
  simulator (rule 1).
- **the DUT top module** — the ORFS-consumed top from the platform
  `hightide_design(top = ...)`, mapped into the modules in `//designs/src/<d>:rtl`.

### What to expect per design (keep this updated)

| Design | Testbench | Strength | Documented sim |
|--------|-----------|----------|----------------|
| `lfsr` | `tb/lfsr_prbs_gen/test_lfsr_prbs_gen.py` (cocotb) | cocotb suite (parametrizable) | cocotb Makefile, `SIM ?= icarus` default (verilator branch exists but needs its `-Wno-*` suppressions replayed). Upstream's other `tb/test_*.v` files are myhdl-coupled harnesses touching `$from_myhdl`/`$to_myhdl` PLI stubs — out of scope; the cocotb segment is the verification surface |
| `coralnpu` | `tests/cocotb/` (OpenTitan/lowRISC rules) | cocotb suite | OpenTitan-style verilator + cocotb |
| most others | none shipped | — | — |

## Step 2: Expose the testbenches from the pinned archive

Testbenches are fetched with the RTL — expose them through the design's
`designs/src/<d>/external.BUILD.bazel` so the labels are stable (mirroring the
existing `:rtl` filegroup). Keep `:rtl` itself minimal: it should list
exactly the files the ORFS flow consumes (the `hightide_design`
`verilog_files` set), so its closure is the verification scope.
Example for `lfsr`:

```python
# designs/src/lfsr/external.BUILD.bazel
filegroup(
    name = "sim_sources",
    srcs = glob(["tb/**/*.v", "tb/**/*.py", "tb/**/Makefile"]),
    visibility = ["//visibility:public"],
)
```

and a thin alias in `designs/src/<d>/BUILD.bazel`:

```python
alias(name = "sim_sources", actual = "@<design>_src//:sim_sources",
      visibility = ["//visibility:public"])
```

Do **not** check testbenches into `designs/src/`; keep them flowing from the
pinned archive so they can't drift from the RTL. The handful of designs whose
archive ships *no* testbench simply have no `:sim_sources` — record that in
`DECISIONS.md` rather than inventing a local TB.

If an upstream TB targets a module that is *inside* the archive but *outside*
the ORFS closure of the design's top, don't wire it into a `cocotb_test` —
skip it and note in `DECISIONS.md` that verification coverage stops at the
modules the flow actually consumes.

## The uniform command rule

Run verification with **one uniform command per design** — a `bazel run`
target that wires the DUT + upstream TB (from the pinned archive) behind
`tools/sim/` wrappers:

- Pattern A (cocotb TBs): `bazel run //designs/src/<d>:<name>_cocotb`
  (generated by `tools/sim/cocotb.bzl:cocotb_test`).
- Pattern B (plain/SVA TBs): `bazel run //designs/src/<d>:<name>_tb`
  (generated by `tools/sim/plain_tb.bzl:plain_tb_test`).

Do **not** hand-roll `iverilog`/`verilator` one-liners against ad-hoc
execroot paths in a design directory: ad-hoc commands drift, are hard to
re-run after a tool bump, and bypass the pinned-archive sourcing rule. A raw
command is acceptable only once, while *discovering* flags/args for a new
design; the immediately-next step is to encode it in a `cocotb_test` /
`plain_tb_test` target. Backend selection and overrides stay uniform:
`... -- --sim=<backend>` (a bare `-- vcs`-style token is NOT a valid
override: appended after the target's own args it gets swallowed by an
earlier `nargs="+"` option, and the runner errors on it before compiling).

## Step 3: Run the testbench

Four runnable patterns, ordered by preference (cocotb first — it's the only
one with harness support in `tools/sim/`). Start with a one-off check; log a
recurring target in the design if it's worth keeping.

### Pattern A — cocotb tests (the harness)

```bash
# Generic, simulator-agnostic runner (default backend verilator).
bazelisk run //tools/sim:cocotb_runner -- verilator \
    --toplevel <dut_top> --test-module <test_pkg> \
    --sources /abs/path/rtl/a.v /abs/path/rtl/b.sv \
    --pythonpath /abs/path/to/test_dir

# Or, if you've set up a venv with cocotb (and a simulator on PATH):
python tools/sim/cocotb_runner.py verilator \
    --toplevel <dut_top> --test-module <test_pkg> \
    --sources rtl/a.v --pythonpath tests
```

The runner handles both cocotb 1.x (`cocotb.runner`) and 2.x
(`cocotb_tools.runner`), so the command doesn't change across cocotb majors.

The harness is validated against the self-test in `tools/sim/example/`
(counter DUT + `test_counter.py`):

```bash
bazelisk run //tools/sim:cocotb_runner -- verilator \
    --toplevel counter --test-module test_counter \
    --sources $PWD/tools/sim/example/dut.v \
    --pythonpath $PWD/tools/sim/example
```

For a design that has been wired up with `cocotb_test` (see
`tools/sim/cocotb.bzl`), run the whole thing with **one line** — the design's
DUT RTL and upstream testbench are pulled from the pinned archive as
runfiles, and the backend can be overridden on the command line:

```bash
bazelisk run //designs/src/lfsr:lfsr_cocotb              # default: icarus
bazelisk run //designs/src/lfsr:lfsr_cocotb -- --sim=vcs # override backend
```

Verified example — the `lfsr` design's upstream `lfsr_prbs_gen` cocotb test.
The one-liner is what you actually run:

```bash
bazelisk run //designs/src/lfsr:lfsr_cocotb              # default: icarus
```

The long form below is the same run spelled out manually via the generic
runner — not something you should need day-to-day. It documents what the
harness does under the hood (which RTL files are pulled from the pinned
archive and where the cocotb test module lives). Keep it for wiring up /
debugging new ones:

```bash
bazelisk run //tools/sim:cocotb_runner -- icarus \
    --toplevel lfsr_prbs_gen --test-module test_lfsr_prbs_gen \
    --sources <execroot>/external/<repo_dir>/rtl/lfsr_prbs_gen.v \
                      <execroot>/external/<repo_dir>/rtl/lfsr.v \
    --pythonpath <execroot>/external/<repo_dir>/tb/lfsr_prbs_gen
```

(The `external/<repo_dir>` contains a Bazel-internal directory name —
e.g. `+_repo_rules+lfsr_src` — that varies with the Bazel version; grab
the exact prefix with `bazelisk cquery --output=files
//designs/src/lfsr:rtl` / `:sim_sources`, or materialize the archive
into a scratch dir and use those paths directly. If you override to
verilator you'll also want `--build-args=-Wno-SELRANGE,-Wno-WIDTH,-Wno-COMBDLY`
to replay the warning suppressions upstream's verilator branch carries.)

### Pattern B — plain Verilog/SV self-checking or SVA testbench

Use the `tools/sim/plain_tb.bzl` macro so the run stays one `bazel run`
command (see the uniform command rule at the top of this step):

```python
# designs/src/<d>/BUILD.bazel
load("//tools/sim:plain_tb.bzl", "plain_tb_test")

plain_tb_test(
    name = "<name>_tb",
    toplevel = "<tb_module>",          # the TB module; it self-drives/self-checks
    sources = [":rtl", ":sim_verilog"],  # filegroup(s) of DUT + TB Verilog
)
```

```bash
bazelisk run //designs/src/<d>:<name>_tb                  # default: verilator
bazelisk run //designs/src/<d>:<name>_tb -- --sim=icarus  # override backend
```

Notes:

- Expose a **Verilog-only** filegroup alias (e.g. `:sim_verilog`) in the
  design's `external.BUILD.bazel` (glob `tb/**/*.v`); don't hand the mixed
  `:sim_sources` filegroup (which carries `.py` drivers / Makefiles) to a
  simulator.
- The runner (`tools/sim/plain_tb_runner.py`) compiles DUT + TB and runs the
  binary; a silent run with exit 0 is green. SVA failures surface as
  assertion-fatal errors naming the property — treat those as RTL failures,
  not setup noise.
- SVA caveats between backends: Icarus supports immediate assertions and a
  subset of concurrent ones; Verilator supports assertion *checking* but not
  the full SVA sequence grammar. Deep SVA (`|=>`, `##[1:3]`, graded matches)
  needs Questa/VCS/Xcelium — Pattern C/D territory.
- **Verify the TB really is a plain TB before wiring it.** A `.v` file in
  the upstream `tb/` dir is not automatically self-contained: `lfsr`'s
  `tb/test_*.v` export `$from_myhdl`/`$to_myhdl` PLI stubs (they are
  myhdl-coupled harnesses on the upstream side) and verilator rejects
  them. Output like `Unsupported or unknown PLI call` means the TB is not
  a plain TB — don't wire it as one; either run it via the upstream driver
  (Pattern D) or, as with `lfsr`, scope verification to the cocotb
  segment and note the coverage decision in `DECISIONS.md`.
- Worked example (harness self-test): `bazelisk run
  //tools/sim:plain_counter_tb` runs the plain TB in `tools/sim/example/`
  over the same counter DUT as the cocotb suite.

### Pattern C — UVM test suites

UVM needs the DUT compiled with UVM + a simulator with its .so/DPI support:
UVM's class library is not fully simulatable by verilator or icarus. On this
harness that's out of reach, so:

- If the upstream TB is UVM, follow the upstream invocation (their Makefile /
  `uvmlauncher` / `irun` script) against a simulator that has UVM —
  documented UVM suites almost always assume Questa/VCS/Xcelium.
- Do **not** port the UVM TB to cocotb as a reflex; if the design matters for
  ORFS verification, a minimal cocotb re-implementation of the **stimulus**
  (not the checker hierarchy) can be justified — record it in `DECISIONS.md`
  as a substitution, noting the coverage delta.
- If no UVM-capable simulator is available, record the design as
  "verification blocked: UVM TB, no UVM sim" rather than shipping
  unverified.

### Pattern D — upstream-documented / custom systems

myhdl, chiseltest, SpinalHDL's `SpinalSim`, apio, or a company's own driver —
the TB is **not** cocotb and not a plain Verilog TB, so the harnesses in
`tools/sim/` do not apply. Follow the upstream invocation instead: their
`Makefile` / driver script / documented setup, with the generator's own
runtime installed (e.g. for a myhdl-driven design, `pip install myhdl` in a
venv — see the PEP 668 gotcha — plus iverilog, then run the upstream
`make`/driver as pinned by the design's archive). Where the upstream driver
is just python + a shell script, keep it hermetic by materializing the
archive into a scratch dir (`bazelisk fetch @<design>_src` + copying the
fresh `external/` dirs) and running the upstream flow there.

Do **not** force these into `cocotb_test` by inventing a `--toplevel` /
`--test-module` from the upstream files' names: if the TB doesn't import
`@cocotb.test()`, that command shape is meaningless and will fail (or worse,
"pass" while simulating nothing). Record the Pattern D choice in
`DECISIONS.md`, same as any other recorded simulator decision.

If the upstream documents a cocotb **runner** with a different backend (e.g.
VCS via `cocotb.runner.get_runner("vcs")`), that is still Pattern A — only
the engine below cocotb changed, the TB and the harness stay the same:

```bash
# Still Pattern A, just driving the cocotb TB with a different engine:
bazelisk run //tools/sim:cocotb_runner -- vcs --toplevel <top> --test-module <pkg> ...
```

Install any backend the design selects onto the host that runs it (e.g.
`apt install iverilog`, or verify `verilator`/`vcs`/`questa` are on
`PATH`). The runner only needs the backend resolvable at run time, so
remote/licensed simulators are fine — but that ability is a **Pattern A**
capability only; Pattern D has no cocotb runner involved.

## Step 4: Interpret results

- A **PASS** means the RTL's logic is functionally correct under the stimulus.
- The cocotb summary table prints `TESTS=… PASS=… FAIL=… SKIP=…`; a zero-exit
  run with `FAIL=0` is green.
- **Distinguish an RTL bug from a harness/setup problem.** Symptoms of a
  harness problem, not a design bug:
  - `No module named '<test_pkg>'` — the test module isn't on the Python path
    (fix `--pythonpath`).
  - simulator version/compile errors (`%Error`, missing library) — the backend
    or its libpython/link flags are off.
  - a DUT never clocks because the testbench doesn't drive `clk`/`rst` — the
    stimulus, not the RTL, is incomplete.
  - `Failed to import module` / `MODULE variable` — wrong test-module name.
- After a port/update, at minimum re-run the design's TB to confirm the
  RTL semantics survived; when the archive ships no TB, re-check the
  `DECISIONS.md` "verified" note instead.

## Gotchas

- **`--build-args` with dash-prefixed flags**: argparse rejects
  `--build-args "-Wno-WIDTH"` (it looks like an option); use the `=` form,
  `--build-args=-Wno-WIDTH -Wno-COMBDLY`-as-one-quoted-string or comma
  separated, e.g. `--build-args="-Wno-WIDTH,-Wno-COMBDLY"`. In
  `cocotb_test()` targets this is handled for you (flags joined as one
  comma-separated arg).

- **cocotb versions**: `from cocotb.runner` is 1.x; 2.x moved it to
  `cocotb_tools.runner`. `tools/sim/requirements_lock.txt` pins 1.9.2; the
  runner imports both, so bumping is safe.
- **The test module path**: cocotb sets the sim's `PYTHONPATH` from the
  *runner's* `sys.path`, so export via `--pythonpath` (the runner insets into
  `sys.path`), not just an env var.
- **Sandbox vs host tools**: `bazel test` runs in a sandbox that has no
  simulator/compiler. Run the harness with `bazel run` (host exec env) and
  ensure the backend is on `PATH`.
- **`$(locations)` in a macro is fragile**: don't over-automate source wiring;
  pass explicit paths via `bazel run … -- …`.
- **myhdl/OpenTitan-style suites** need their own runtimes (myhdl + iverilog,
  or the OpenTitan build rules). The harness handles cocotb; for those, follow
  the upstream driver (Pattern C).
- **PEP 668**: on Python ≥ 3.12 the system `pip install cocotb` is blocked;
  use a venv (`python3 -m venv .venv && .venv/bin/pip install cocotb`).

## Keeping this converged

- When a design's upstream testbench set or documented simulator changes,
  update the table in Step 1 and the design's `DECISIONS.md`.
- Prefer the shared harness over per-design ad hoc sim invocations so backend
  selection stays one decision.
- If a new failure mode recurs (e.g. a particular backend needs a flag), add a
  bullet here rather than in the per-design file.
