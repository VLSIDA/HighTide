# Quick Start Guide

Build a HighTide design with the pinned toolchain. The first build compiles the
tools; large designs can take hours to place and route.

## Prerequisites

- Linux with Git, curl, Perl, and standard development tools
- Bazelisk (the repository pins Bazel 8.5.0)
- Network access and disk space for the pinned toolchains and build artifacts

On a minimal Debian/Ubuntu amd64 host, the GUI-enabled OpenROAD binary also
needs the X11/XCB runtime libraries. If it fails to launch with a missing shared
library, `bash tools/setup_linux_runtime.sh` downloads those packages into
`scratch/qt-runtime/` and adds a local runtime search path in `.bazelrc.user`.
It does not install system packages. Retain the saved package versions,
checksums, and local link settings with any baseline produced this way.

## Install Bazel

```bash
sudo apt install perl
sudo wget -O /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64
sudo chmod +x /usr/local/bin/bazel
```

## Clone and Build

```bash
# `stable` always points at the latest validated release; the default
# branch `main` is active development and may be mid-campaign.
git clone --branch stable git@github.com:VLSIDA/HighTide.git
cd HighTide
git submodule update --init --recursive
bazel build //designs/asap7/lfsr:lfsr_final
```

(Developing HighTide itself? Clone without `--branch stable` and work on
`main`.)

That's it. Bazel fetches the pinned ORFS sources and builds OpenROAD, Qt, Yosys,
and their dependencies from source. The first build includes toolchain downloads
and compilation; subsequent builds reuse available cached outputs.


## What Just Happened

The LFSR design was synthesized, placed, routed, and finished through the complete ORFS flow on the ASAP7 7nm technology node. Outputs are at:

```
bazel-bin/designs/asap7/lfsr/
├── results/asap7/lfsr_prbs_gen/base/
│   ├── 1_synth.odb          # Synthesized netlist
│   ├── 2_floorplan.odb      # Floorplanned design
│   ├── 3_place.odb          # Placed design
│   ├── 4_cts.odb            # Clock tree synthesized
│   ├── 5_route.odb          # Routed design
│   └── 6_final.odb/.gds     # Final layout
├── reports/                  # Timing, area, DRC reports
└── logs/                     # Per-stage logs and metrics
```

## View Build Summary

```bash
./tools/summary.sh
```

This prints locally available results with area, utilization, setup slack,
fastest-clock Fmax, and power. It can include outputs from earlier invocations;
use an invocation snapshot for comparison baselines.

For a comparison baseline, retain the results from a specific invocation:

```bash
mkdir -p artifacts/asap7-baseline
bazel query 'filter("_final$", //designs/asap7/...) except attr(tags, "manual", //designs/asap7/...)' \
  > artifacts/asap7-baseline/final-targets.txt
: > artifacts/asap7-baseline/input-events.json
python3 tools/snapshot_qor.py \
  --events artifacts/asap7-baseline/input-events.json \
  --output artifacts/asap7-baseline/input-snapshot
bazel build //designs/asap7/... --keep_going \
  --output_groups=+logs,+jsons,+reports,+drcs \
  --build_event_json_file=artifacts/asap7-baseline/build-events.json \
  --profile=artifacts/asap7-baseline/build-profile.gz
python3 tools/snapshot_qor.py \
  --events artifacts/asap7-baseline/build-events.json \
  --output artifacts/asap7-baseline/qor
```

Run the snapshot command even if the build fails. It records each expected final
target as built, failed, or incomplete, and only uses reports for targets that
succeeded in that invocation. Use a new output directory for each snapshot.
The `input-snapshot` freezes provenance before the build and is reused by the
final snapshot, so later edits cannot be attributed to an earlier result.
The CSV/JSON preserves negative slack and missing checks, with raw stage metrics,
timing reports, effective SDCs, configuration files, input hashes, revision,
submodule pins, generated netlist/SDC/SPEF hashes, and the local patch for
reproducibility. Keep the complete run
directory; `artifacts/` is gitignored.

Review setup and hold timing, electrical-limit violation counts, and route DRCs
before accepting a baseline. The snapshot records these checks separately;
successful compilation does not imply timing or electrical closure.
For multiple clocks, compare `clock_fmax_ghz` / `clock_min_period_ps` per clock:
the flow's aggregate Fmax is the **fastest** clock, so it can hide a slower clock.
The pinned per-clock calculation also excludes opposite-edge and multicycle
paths; its inverse period does not guarantee all-path closure. Keep setup and
hold results at the recorded clock targets in the comparison.
These are predictive PDK/FakeRAM results under the recorded interface assumptions;
matching constraints and tool pins are necessary for a meaningful comparison.

## Build Other Designs

```bash
# Individual stages
bazel build //designs/asap7/lfsr:lfsr_synth       # synthesis only
bazel build //designs/asap7/lfsr:lfsr_place        # through placement

# Different designs
bazel build //designs/asap7/minimax:minimax_final  # RISC-V core
bazel build //designs/asap7/sha3:sha3_final        # SHA3 hash

# Different platforms
bazel build //designs/nangate45/lfsr:lfsr_final    # 45nm
bazel build //designs/sky130hd/lfsr:lfsr_final     # 130nm open-source

# All designs for a platform
bazel build //designs/asap7/...

# Everything
bazel build //designs/...
```

## Fetch Pre-built Results

Instead of building locally, you can fetch baseline results from the remote cache:

```bash
./tools/fetch_cache.sh              # all designs
./tools/fetch_cache.sh asap7        # all asap7 designs
./tools/fetch_cache.sh asap7 lfsr   # specific design
```

## Next Steps

- **[Design catalog](designs.md)** — all designs and their platform coverage
- **[Architecture](architecture.md)** — how the build system works
- **[Adding a design](adding-designs.md)** — how to add a new design to the suite
- **[Kubernetes builds](../k8s/README.md)** — building at scale on NRP Nautilus
