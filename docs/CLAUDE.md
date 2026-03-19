# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HighTide2 is a VLSI design benchmark suite built on OpenROAD-flow-scripts (ORFS). It ports open-source hardware designs to asap7/sky130hd/nangate45 technologies using the OpenROAD RTL-to-GDSII flow, serving as a benchmark suite for ML projects.

## Setup

```bash
./setup.sh            # Init ORFS submodule, create symlinks (scripts/, util/, platforms/)
./runorfs.sh           # Launch Docker container with OpenROAD tools
```

## Build Commands

```bash
# Run full flow for a design (default: nangate45/lfsr_prbs_gen)
make DESIGN_CONFIG=./designs/<platform>/<design>/config.mk

# Run via Docker non-interactively (use this instead of runorfs.sh which has -it)
./runorfs_ni.sh make DESIGN_CONFIG=./designs/<platform>/<design>/config.mk

# Run with dev RTL generation from source repos
make DESIGN_CONFIG=./designs/<platform>/<design>/config.mk dev

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

### Key Relationships

- `Makefile` includes ORFS flow via `-include OpenROAD-flow-scripts/flow/Makefile`
- `settings.mk` overrides ORFS output paths to organize results by `<platform>/<design>/<variant>/`
- Symlinks (`scripts/`, `util/`, `platforms/`) point into the ORFS submodule
- `runorfs.sh` wraps Docker execution with proper mounts and OpenROAD image tags

### Design Configuration

Each design lives at `designs/<platform>/<design>/` and contains:
- **`config.mk`** — Sets DESIGN_NAME, PLATFORM, VERILOG_FILES, SDC_FILE, utilization/density params. Includes `verilog.mk` from the source directory for RTL file selection.
- **`constraint.sdc`** — Clock definitions and timing constraints
- **`pdn.tcl`** (optional) — Power delivery network configuration (layer stripes, pitches)
- **`io.tcl`** (optional) — Pin placement constraints

### RTL Source Management (`designs/src/`)

Design sources are git submodules under `designs/src/<design>/dev/repo/`. The `dev` make target:
1. Initializes the submodule
2. Runs `designs/src/<design>/dev/setup.sh` to generate Verilog
3. Resumes the ORFS flow from the last completed stage

Each design's `verilog.mk` selects between dev-generated RTL (when `.dev-run-*` flag exists) and pre-generated release RTL.

### Platforms

| Platform | Node | Designs |
|----------|------|---------|
| asap7 | 7nm academic | gemmini, minimax, cnn, lfsr_prbs_gen, NyuziProcessor, liteeth (6 variants) |
| nangate45 | 45nm | minimax, lfsr_prbs_gen, NyuziProcessor, liteeth (6 variants) |
| sky130hd | 130nm open | minimax, lfsr_prbs_gen, liteeth (6 variants) |

### Output Directories

Build artifacts go to `{logs,objects,reports,results}/<platform>/<design>/<variant>/`. Key outputs:
- `results/.../6_final.gds` — Final GDSII layout
- `reports/.../` — QoR reports per stage

### FakeRAM

Designs with embedded memories use FakeRAM (LEF-only, no GDS). Controlled by `GDS_ALLOW_EMPTY := fakeram.*` in settings.mk.
