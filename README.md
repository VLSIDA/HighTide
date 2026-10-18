# HighTide

A VLSI design benchmark suite that runs open-source hardware designs through the [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) RTL-to-GDSII flow on academic and open-source technology nodes (ASAP7 7nm, NanGate 45nm, SkyWater 130nm).

**New here?** See the **[Quick Start Guide](docs/quickstart.md)** to build your first design in 5 minutes. For the full, up-to-date list of designs and the platforms each one closes on, see the **[Design Catalog](docs/designs.md)**.

## How It Works

Each design's upstream source is pinned in the root `MODULE.bazel` as a hermetic `http_archive` (`@<design>_src`) at a fixed upstream commit — there is no git submodule and no vendored copy of the RTL in the repo. At build time Bazel fetches that archive and compiles the native HDL (SystemVerilog, Chisel, LiteX/migen, etc.) down to plain Verilog using pinned conversion tools (e.g. [sv2v](https://github.com/zachjs/sv2v), Chisel under `rules_scala`, NNgen), applying any design-specific patches declaratively. The per-design build logic lives in `designs/src/<design>/external.BUILD.bazel`, and the rationale behind each design's tuning is recorded in `designs/src/<design>/DECISIONS.md`. Embedded SRAM memories are replaced with black-box macros so the design can be synthesized without an SRAM compiler.

Because sourcing, conversion, and patching all happen inside the Bazel build, a clean checkout builds any design with no submodule initialization and no external conversion tools installed:

```bash
bazel build //designs/asap7/lfsr:lfsr_final
```

To move a design to a newer upstream commit, bump its pinned archive (URL + integrity hash) in `MODULE.bazel`; Bazel re-fetches, re-converts, and re-runs only the flow stages whose inputs changed.

The generated Verilog is run through the [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) RTL-to-GDSII flow: synthesis (Yosys) → floorplan → placement → clock tree synthesis → routing → GDSII output. Each design has per-platform configuration (clock constraints, utilization targets, pin placement) tuned for the target technology node.

## Running a design in upstream ORFS (for OpenROAD researchers)

The Bazel (`bazel-orfs`) flow is HighTide's golden, supported entry
point. But if you want to experiment with **a custom OpenROAD build**,
**modified flow Tcl scripts**, or **added/changed flow steps**, plain
`OpenROAD-flow-scripts` (a single `config.mk` + the standard `Makefile`)
is the easier interface. Two tools bridge the gap.

### One command: `tools/bazel_to_orfs.sh`

```bash
# Prepare a design as a portable, self-contained ORFS bundle (the default —
# does NOT run; prints instructions on how to):
tools/bazel_to_orfs.sh designs/asap7/lfsr

# Prepare every asap7 design as portable bundles:
tools/bazel_to_orfs.sh //designs/asap7/...

# Run a prepared bundle — on this or any machine, no bazel, no HighTide
# checkout (needs an ORFS install with yosys + yosys-slang and an openroad):
FLOW_HOME=~/OpenROAD-flow-scripts OPENROAD_EXE=~/OpenROAD/build/src/openroad \
  .orfs_bundles/asap7/lfsr/run.sh

# Prepare + run locally against your own ORFS install, through placement:
tools/bazel_to_orfs.sh --run --flow-home ~/OpenROAD-flow-scripts \
  designs/asap7/lfsr synth floorplan place
```

For a tool-neutral input export, add `--benchmark-dir`:

```bash
tools/bazel_to_orfs.sh --benchmark-dir .hightide_export all
```

```
.hightide_export/
  platforms/common/
  platforms/<platform>/        shared pinned platform files + manifest.json
  designs/<platform>/<design>/
    inputs/                   RTL, includes, SDC, macro LEF/LIB, design Tcl
    manifest.json             design inputs and selected configuration
    config.mk                 ORFS configuration; no run.sh by default
```

Consumers can read the versioned JSON without Make. Paths are relative to
the manifest containing them. `design.name` is the RTL top module;
`rtl.files` preserves source order, expanding generated directories in place.
The platform manifest describes its default LEF/Liberty/GDS files, placement
site, routing limits, and setup scripts. Design routing fields override the
corresponding platform defaults.

This is a portable input contract, not a complete tool-independent flow:
synthesis arguments and Tcl scripts still use Yosys/Slang/OpenROAD syntax.
Other tools need adapters, including synthesis-mode defines such as
`SYNTHESIS`; absent fields do not encode every ORFS default or workaround.
The retained `config.mk` files provide the ORFS configuration. Set
`HIGHTIDE_BUNDLE_ROOT` to the extracted export directory when resolving them.

Export requires Linux/Bazel and builds only RTL generators and configuration
output groups—not synthesis or physical design. Use a new output directory
after changing the platform pin. Adding `--run --flow-home <ORFS>` explicitly
creates a runner and runs ORFS after export.

**What the default ORFS mode produces.** For each design it materializes the RTL via bazel
(fetching the hermetic `http_archive` sources / running any RTL genrules —
but *not* synthesis), extracts the resolved `config.mk`, and copies every
input into a self-contained, relocatable bundle:

```
<work-dir>/
  inputs/      every input — RTL, includes, SDC, LEF/LIB, tcl. config.mk
               references them via $(PREPARED_INPUTS), so the bundle resolves
               wherever it is copied.
  config.mk    the resolved ORFS design config
  run.sh       runs the full flow from RTL against an ORFS install
```

Copy the whole `<work-dir>` to any machine and run its `run.sh` — no bazel,
no HighTide checkout. The bundle runs the **whole flow from RTL**
(`synth → finish`), so the machine running it needs an OpenROAD-flow-scripts
install whose `tools/install` has **yosys + yosys-slang**, plus an openroad.
(For the pure-bazel full flow with zero setup, just
`bazel build //designs/<plat>/<design>:<design>_final`.)

**Design patterns.** The target can be one design or a bazel-style pattern
that expands to many (each is prepared — or, with `--run`, run — in turn,
continuing past failures and printing a summary):

| Pattern | Matches |
|---|---|
| `designs/asap7/lfsr` | one design |
| `//designs/asap7/...` | all asap7 designs |
| `//designs/asap7/NVDLA/...` | every NVDLA partition |
| `//designs/...` or `all` | every design, every platform |
| `asap7` \| `nangate45` \| `sky130hd` | all designs on that platform |
| `designs/asap7/NVDLA` | a container → its sub-designs |

**Grouped designs (NVDLA, bp_processor):** these are *containers* — the top
directory holds only shared SRAM filegroups, and each runnable design is a
sub-package. Pass the sub-design path, not the container:
`designs/asap7/NVDLA/partition_a`, `designs/asap7/bp_processor/bp_uno`, etc.
(Pass the container and the script lists the available sub-designs.)

**Prepare vs. run (`--run`):** by default `bazel_to_orfs.sh` **prepares
only** — it stages the portable bundle and prints how to run it, without
running ORFS. Pass `--run` (with `--flow-home <ORFS>`) to also run the
bundle locally after preparing. Either way the bundle runs the whole flow
from RTL in a plain ORFS install, so you can swap in a custom `openroad`
(`--openroad` / `OPENROAD_EXE`), edit `flow/scripts/*.tcl` in your ORFS
checkout, or change the make targets.

**QoR comparability:** HighTide's published numbers come from the bazel-orfs
build, which pins specific tool commits (bazel-orfs, OpenROAD, and the ORFS
commit `bazel_to_orfs.sh` prints on `--run`). Running a bundle against a
*different* ORFS / yosys shifts the baseline, and some extracted `config.mk`
workaround variables (e.g. `SKIP_CTS_REPAIR_TIMING`, `SETUP_MOVE_SEQUENCE`,
`write_sdc` async-reset edits) may be unnecessary or stale — review them
against your ORFS.

### Just the config.mk: `tools/bazel_to_config_mk.sh`

To drive ORFS yourself, extract an ORFS-compatible `config.mk` (with
`--abs`, absolute paths that run from any directory):

```bash
tools/bazel_to_config_mk.sh --abs designs/asap7/lfsr /tmp/lfsr.config.mk
make -C OpenROAD-flow-scripts/flow DESIGN_CONFIG=/tmp/lfsr.config.mk
```

This costs no synthesis or place-and-route: it builds only each stage's
`<stage>.mk` config output group (cheap bazel *analysis*, seconds), unions
the `export VAR?=VALUE` lines, strips Bazel-internal vars, and adds the
cquery-resolved `VERILOG_FILES`. (`bazel_to_orfs.sh` builds on this: it also
materializes the RTL and copies every input into a self-contained bundle so
the design runs off-machine.)

### Alternative: a custom OpenROAD inside bazel-orfs (binary swap only)

If you only need a different OpenROAD binary and want to keep bazel's
caching, override the `openroad` label instead of leaving bazel — per
design via `openroad = "//path/to:my_openroad"` on the
`hightide_design()`/`orfs_flow()` call, or globally in `MODULE.bazel`:

```starlark
orfs = use_extension("@bazel-orfs//:extension.bzl", "orfs_repositories")
orfs.default(openroad = "@my_openroad//:openroad")
```

This cannot modify flow Tcl scripts (`FLOW_HOME` is pinned) — use the
`config.mk` path above for flow-script or flow-step changes.

## Documentation

- **[Quick Start Guide](docs/quickstart.md)** — install, build, and view results
- **[Design Catalog](docs/designs.md)** — all designs, platforms, variants, and complexity
- **[Architecture](docs/architecture.md)** — build system, flow stages, RTL management, caching
- **[Adding Designs](docs/adding-designs.md)** — how to add a new design to the suite
- **[Kubernetes Builds](k8s/README.md)** — building at scale on NRP Nautilus
