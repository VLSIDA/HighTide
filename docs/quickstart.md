# Quick Start Guide

Get a HighTide design built in under 5 minutes.

## Prerequisites

- Linux (Ubuntu 24.04 recommended)
- Docker
- ~10 GB disk for the ORFS Docker image (pulled automatically)

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
bazel build //designs/asap7/lfsr:lfsr_final
```

(Developing HighTide itself? Clone without `--branch stable` and work on
`main`.)

That's it. Bazel fetches ORFS, extracts OpenROAD tools from Docker, and runs the full RTL-to-GDSII flow. The first build takes longer (~5 min for lfsr) as it downloads dependencies; subsequent builds are cached.

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

This prints a table of all completed builds with key metrics (die area, utilization, timing slack, Fmax, power, DRC count).

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
