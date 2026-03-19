# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HighTide2 is a VLSI design benchmark suite built on OpenROAD-flow-scripts (ORFS). It ports open-source hardware designs to asap7/sky130hd/nangate45 technologies using the OpenROAD RTL-to-GDSII flow, serving as a benchmark suite for ML projects.

## Setup

There are two build flows: the original **Make flow** (Docker-based) and the newer **Bazel flow** (native).

### Make Flow Setup

```bash
./setup.sh            # Init ORFS submodule, create symlinks (scripts/, util/, platforms/)
./runorfs.sh           # Launch Docker container with OpenROAD tools
```

### Bazel Flow Setup

Requires an Ubuntu machine with:
- [Bazelisk](https://github.com/bazelbuild/bazelisk) (or Bazel 7.6.1+)
- Docker (for bazel-orfs tool extraction from ORFS image)

No additional setup needed — Bazel fetches ORFS and bazel-orfs automatically via `MODULE.bazel`.

## Build Commands

### Bazel Flow (recommended)

```bash
# Build a single design
bazel build //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_final

# Build all designs for a platform
bazel build //designs/asap7/...

# Build all designs across all platforms
bazel build //designs/...

# Build with dev RTL generation (requires submodule init + tools)
bazel build --define update_rtl=true //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_final

# Build individual stages (target suffixes: _synth, _floorplan, _place, _cts, _route, _final)
bazel build //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_synth
bazel build //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_place
```

### Make Flow (legacy)

```bash
# Run full flow for a design (default: nangate45/lfsr_prbs_gen)
make DESIGN_CONFIG=./designs/<platform>/<design>/config.mk

# Run via Docker non-interactively (use this instead of runorfs.sh which has -it)
./runorfs_ni.sh make DESIGN_CONFIG=./designs/<platform>/<design>/config.mk

# Run with dev RTL generation from source repos
make DESIGN_CONFIG=./designs/<platform>/<design>/config.mk update-rtl

# Individual ORFS flow stages
make DESIGN_CONFIG=... do-synth       # Yosys synthesis
make DESIGN_CONFIG=... do-floorplan   # Floorplan + IO + PDN
make DESIGN_CONFIG=... do-place       # Global/detailed placement
make DESIGN_CONFIG=... do-cts         # Clock tree synthesis
make DESIGN_CONFIG=... do-route       # Global/detailed routing
make DESIGN_CONFIG=... do-finish      # Metal fill + GDSII

# Cleanup
make DESIGN_CONFIG=... clean_design   # Remove dev-generated sources
make DESIGN_CONFIG=... clean_all      # Full cleanup
```

## Architecture

### Key Relationships (Make Flow)

- `Makefile` includes ORFS flow via `-include OpenROAD-flow-scripts/flow/Makefile`
- `settings.mk` overrides ORFS output paths to organize results by `<platform>/<design>/<variant>/`
- Symlinks (`scripts/`, `util/`, `platforms/`) point into the ORFS submodule
- `runorfs.sh` wraps Docker execution with proper mounts and OpenROAD image tags

### Key Relationships (Bazel Flow)

- **`MODULE.bazel`** — Declares dependencies on `bazel-orfs` (via `git_override`) and configures the ORFS Docker image for tool extraction
- **`defs.bzl`** — `hightide_design()` macro wrapping `orfs_flow()` with common defaults (`GDS_ALLOW_EMPTY`, platform-to-PDK mapping)
- **`BUILD.bazel`** (root) — Defines `//:update_rtl` config setting and nangate45 `orfs_pdk` (not in ORFS's defaults)
- Each design has a `BUILD.bazel` calling `hightide_design()` with parameters mirroring its `config.mk`
- RTL sources at `designs/src/<design>/BUILD.bazel` use `select()` to switch between release and dev RTL

### Design Configuration

Each design lives at `designs/<platform>/<design>/` and contains:
- **`config.mk`** — (Make flow) Sets DESIGN_NAME, PLATFORM, VERILOG_FILES, SDC_FILE, utilization/density params. Includes `verilog.mk` from the source directory for RTL file selection.
- **`BUILD.bazel`** — (Bazel flow) Calls `hightide_design()` with equivalent parameters: verilog_files, sources (SDC, LEFs, LIBs), arguments (utilization, density, etc.)
- **`constraint.sdc`** — Clock definitions and timing constraints (shared by both flows)
- **`pdn.tcl`** (optional) — Power delivery network configuration (layer stripes, pitches)
- **`io.tcl`** (optional) — Pin placement constraints

### RTL Source Management (`designs/src/`)

Design sources are git submodules under `designs/src/<design>/dev/repo/`.

**Make flow:** The `update-rtl` make target:
1. Initializes the submodule
2. Runs `designs/src/<design>/dev/setup.sh` to generate Verilog
3. Resumes the ORFS flow from the last completed stage

Each design's `verilog.mk` selects between dev-generated RTL (when `.dev-run-*` flag exists) and pre-generated release RTL.

**Bazel flow:** Each `designs/src/<design>/BUILD.bazel` defines:
- `rtl_release` filegroup — pre-generated Verilog files
- `rtl_dev_gen` genrule — runs setup.sh/sv2v to generate from source
- `rtl` alias — uses `select({"//:update_rtl": ..., "//conditions:default": ...})` to pick

Dev mode requires: `git submodule update --init designs/src/<design>/dev/repo` before `bazel build --define update_rtl=true`.

### Platforms

| Platform | Node | Designs |
|----------|------|---------|
| asap7 | 7nm academic | gemmini, minimax, cnn, sha3, lfsr_prbs_gen, NyuziProcessor, bp_processor/bp_quad, liteeth (6 variants) |
| nangate45 | 45nm | minimax, lfsr_prbs_gen, NyuziProcessor, liteeth (6 variants) |
| sky130hd | 130nm open | minimax, lfsr_prbs_gen, liteeth (6 variants) |

### Output Directories

**Make flow:** Build artifacts go to `{logs,objects,reports,results}/<platform>/<design>/<variant>/`. Key outputs:
- `results/.../6_final.gds` — Final GDSII layout
- `reports/.../` — QoR reports per stage

**Bazel flow:** Build artifacts go to `bazel-bin/designs/<platform>/<design>/`. Key outputs accessible via `bazel build` target names (e.g., `<design>_final` for GDS).

### FakeRAM

Designs with embedded memories use FakeRAM (LEF-only, no GDS). Controlled by `GDS_ALLOW_EMPTY := fakeram.*` in settings.mk (Make flow) and set as a default in `defs.bzl` (Bazel flow).

SRAM LEF/LIB files are organized per-platform:
- `designs/<platform>/NyuziProcessor/sram/{lef,lib}/` — NyuziProcessor memories
- `designs/<platform>/liteeth/sram/{lef,lib}/` — liteeth variant memories (shared across variants)
- `designs/asap7/bp_processor/sram/{lef,lib}/` — bp_processor memories
- `designs/src/cnn/fakeram_*.{lef,lib}` — CNN memories (in source directory)
