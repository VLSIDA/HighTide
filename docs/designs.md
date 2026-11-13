# Design Catalog

HighTide ports open-source hardware designs across three technology platforms using the OpenROAD RTL-to-GDSII flow.

## Platforms

| Platform | Node | Description |
|----------|------|-------------|
| **asap7** | 7nm | Academic predictive PDK from ASU |
| **nangate45** | 45nm | FreePDK with NanGate cell library |
| **sky130hd** | 130nm | Open-source SkyWater 130nm high-density |

## Designs

The authoritative list of designs and the (platform, design) build matrix lives on the web page:

- [results.html](https://hightide-benchmarks.dev/results.html) — every cached `_final` build with its current QoR (areas, cells, slack, skew, fmax, power)
- [gallery.html](https://hightide-benchmarks.dev/gallery.html) — routed-view layouts per design, with upstream-repo links and a short description of each design
- [Design Portfolio on the landing page](https://hightide-benchmarks.dev/#designs) — design ↔ language ↔ platforms summary

This catalog intentionally does not duplicate that list — the web page is regenerated from cached build state, so referring to it avoids the two-source-of-truth drift this file used to have.

Memory-bearing designs (e.g. CNN, nyuzi, BlackParrot, NVDLA, LiteDRAM, LiteEth, LitePCI) use [bsg_fakeram](https://github.com/bespoke-silicon-group/bsg_fakeram)-generated SRAM macros — pin-accurate LEF / LIB black-boxes with no internal logic.

## Build targets

Each design exposes Bazel targets for the individual flow stages:

```
//designs/<platform>/<design>:<design>_synth       # Yosys synthesis
//designs/<platform>/<design>:<design>_floorplan   # Floorplan + IO + PDN
//designs/<platform>/<design>:<design>_place       # Global + detailed placement
//designs/<platform>/<design>:<design>_cts         # Clock-tree synthesis
//designs/<platform>/<design>:<design>_route       # Global + detailed routing
//designs/<platform>/<design>:<design>_final       # Metal fill + GDSII
//designs/<platform>/<design>:<design>_gallery     # Routed-view PNG render
```

For designs grouped under a family path, the leaf is the last segment:

```
//designs/asap7/bp_processor/bp_quad:bp_quad_final
//designs/asap7/NVDLA/partition_c:partition_c_final
```
