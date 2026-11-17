# Architecture

HighTide is a VLSI design benchmark suite built on [OpenROAD-flow-scripts (ORFS)](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts). It takes open-source hardware designs through the complete RTL-to-GDSII flow using [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) on academic and open-source technology nodes.

## Build System

HighTide uses [Bazel](https://bazel.build/) with the [bazel-orfs](https://github.com/The-OpenROAD-Project/bazel-orfs) ruleset. Bazel manages dependencies, caching, and build orchestration.

```
MODULE.bazel          # Declares bazel-orfs dependency and ORFS Docker image
defs.bzl              # hightide_design() macro wrapping orfs_flow()
BUILD.bazel           # Root config (yosys-slang share merge, nangate45 PDK)
designs/
├── src/<design>/     # RTL sources (shared across platforms)
├── asap7/<design>/   # Platform-specific config (BUILD.bazel, constraint.sdc)
├── nangate45/<design>/
└── sky130hd/<design>/
```

### Key Relationships

- **`MODULE.bazel`** declares the `bazel-orfs` dependency (pinned to a specific commit) and the ORFS Docker image (pinned to a specific tag + SHA256). bazel-orfs extracts OpenROAD and Yosys tools from the Docker image at build time.

- **`defs.bzl`** defines `hightide_design()`, a thin wrapper around `orfs_flow()` that sets common defaults like `GDS_ALLOW_EMPTY = fakeram.*` and maps platform names to PDK labels.

- **Each design's `BUILD.bazel`** calls `hightide_design()` with the design-specific parameters (utilization, density, SRAM files, etc.).

### Flow Stages

The ORFS flow runs in 6 stages, each producing an ODB (OpenROAD Database) file:

| Stage | Tool | Output | Description |
|-------|------|--------|-------------|
| 1 | Yosys | `1_synth.odb` | RTL synthesis to gate-level netlist |
| 2 | OpenROAD | `2_floorplan.odb` | Die sizing, IO placement, power grid |
| 3 | OpenROAD | `3_place.odb` | Global and detailed cell placement |
| 4 | OpenROAD | `4_cts.odb` | Clock tree synthesis + timing repair |
| 5 | OpenROAD | `5_route.odb` | Global and detailed routing |
| 6 | OpenROAD | `6_final.odb/.gds` | Metal fill, GDSII output, final reports |

## RTL Source Management

Design RTL is fetched hermetically by Bazel — no vendored copies, no submodules. Each design's `designs/src/<design>/` has:

- **Pinned upstream** — an `http_archive` (`@<design>_src`) in the root `MODULE.bazel` fetches the upstream source at a fixed commit; source fixes are declarative `patches`
- **Hermetic conversion** — native HDL (SystemVerilog, Chisel, Python generators) is lowered to Verilog inside the Bazel build

Each design's `BUILD.bazel` exposes a stable `:rtl` alias pointing at the fetched archive (or at a local converter target). To move to newer upstream, bump the archive pin in `MODULE.bazel`.

### HDL Conversion Pipeline

| Source Language | Conversion Tool | Examples |
|----------------|----------------|----------|
| Verilog | None (direct) | lfsr, sha3 |
| SystemVerilog | sv2v or yosys-slang | minimax (sv2v), nyuzi (sv2v), bp_processor (yosys-slang) |
| Chisel/Scala | JDK + sbt | gemmini |
| LiteX/Python | Python venv + LiteX | liteeth |
| Veriloggen/Python | Python venv + NNgen | cnn |

## Design Configuration

Each platform-specific design directory contains:

| File | Required | Purpose |
|------|----------|---------|
| `BUILD.bazel` | Yes | Bazel target definition calling `hightide_design()` |
| `constraint.sdc` | Yes | Clock definitions and timing constraints |
| `pdn.tcl` | No | Custom power delivery network (when default causes IR drop) |
| `io.tcl` | No | Manual pin placement (when auto-placement causes congestion) |
| `sram/lef/*.lef` | If memories | FakeRAM LEF files for memory macros |
| `sram/lib/*.lib` | If memories | FakeRAM Liberty files for memory macros |
| `macros.v` | If memories | Verilog wrapper remapping memory instantiations |

### Key Parameters

| Parameter | Description | Typical Range |
|-----------|-------------|---------------|
| `CORE_UTILIZATION` | Target cell density (%) | 35-80% |
| `PLACE_DENSITY` | Placement density | 0.5-0.85 |
| `TNS_END_PERCENT` | Timing closure aggressiveness | 100 |
| `MACRO_PLACE_HALO` | Spacing around macros (um) | 5-8 |
| `ABC_AREA` | Optimize synthesis for area | 0 or 1 |
| `SYNTH_HIERARCHICAL` | Hierarchical synthesis | 0 or 1 |

### Clock Period by Platform

| Platform | Typical Range | Units |
|----------|--------------|-------|
| asap7 | 100-1000 | picoseconds |
| nangate45 | 2-10 | nanoseconds |
| sky130hd | 10-50 | nanoseconds |

## FakeRAM

Designs with embedded memories (register files, SRAMs, caches) use FakeRAM — LEF/LIB placeholder macros that provide physical pin models without internal logic. This allows the physical design flow to place and route around memories without needing actual SRAM compilers.

FakeRAM files are platform-specific (different metal stacks and design rules) and live at `designs/<platform>/<design>/sram/`. The naming convention is `fakeram_<depth>x<width>_<ports>.{lef,lib}` where ports describes the memory type (e.g., `1rw`, `1r1w`, `2r1w`).

The `GDS_ALLOW_EMPTY = fakeram.*` setting in `defs.bzl` tells the GDSII writer to accept empty GDS for FakeRAM macros.

## Remote Cache and Artifacts

- **Remote Bazel cache** — GCS bucket (`gs://hightide-bazel-cache`) stores build outputs for all designs. Local users can fetch baseline results with `./tools/fetch_cache.sh`.
- **Artifact storage** — The `hightide-artifacts` PVC on Nautilus NRP stores full build outputs (results, reports, logs) from K8s jobs submitted with `--upload-artifacts`. Fetch locally with `./tools/fetch_artifacts.sh`.

See [k8s/README.md](../k8s/README.md) for details on K8s builds and artifact management.
