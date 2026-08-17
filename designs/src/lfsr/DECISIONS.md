# lfsr Design Decisions

Per-platform notes on tuning, workarounds, and platform-specific quirks for `lfsr` (LFSR / PRBS generator, top-level module `lfsr_prbs_gen`).  See `CLAUDE.md` (root) for the canonical upstream-bug index.

This is a small std-cell-only design (~200 cells, no macros) used as a smoke test for the flow on every platform.

## Hermetic RTL sourcing (2026-07, gallery-style)

The three RTL files are no longer a git submodule + checked-in vendored copy. They are fetched by Bazel from a pinned `http_archive` (`@lfsr_src`, `alexforencich/verilog-lfsr` in the root `MODULE.bazel`), exposed as a `filegroup` via `external.BUILD.bazel`. `designs/src/lfsr/BUILD.bazel` is a thin `alias(name = "rtl", actual = "@lfsr_src//:rtl")`, so the consumer label `//designs/src/lfsr:rtl` is unchanged. No `dev/repo` submodule, no `dev/setup.sh`, no `//:update_rtl` select. Upstream RTL is byte-identical to the previously-vendored files.

## asap7

**Status**: finishing
**Last updated**: 2026-05-01 (commit `6511fb56`)

### Configuration
- `CORE_UTILIZATION = 55` — std-cell-only, fits comfortably tight
- `TNS_END_PERCENT = 100` — repair every violator (small design, cheap to fix all)
- Clock: `700 ps` (Fmax ~1.43 GHz)

### Decisions
- **2026-05-01 `6511fb56`**: clock relaxed from 200 ps → 700 ps in PR #109 to match achievable Fmax — at the prior aggressive target the resizer inserted dozens of buffers chasing an unreachable bound.
- **2026-06-04**: validated on the bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64 upgrade. QoR essentially unchanged (WNS 12.38 → 13.22 ps, Fmax 1.45 → 1.46 GHz, 154 cells). No workarounds; no changes needed.

### Known issues / open questions
- None.

## nangate45

**Status**: finishing
**Last updated**: 2026-03-21 (commit `fb6ec1d4`)

### Configuration
- `CORE_UTILIZATION = 20` — design is so small (~200 cells) that lower util just gives breathing room for IO placement
- `PLACE_DENSITY_LB_ADDON = 0.20`
- `TNS_END_PERCENT = 100`
- Clock: `0.46 ns` (Fmax ~2.17 GHz)

### Decisions
- None recorded — initial port closed cleanly with these values.
- **2026-06-04**: validated on the bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64 upgrade. QoR within tolerance (WNS 127.61 → 125.49 ps, Fmax 3.01 → 2.99 GHz, 121 → 126 cells). No changes needed.

### Known issues / open questions
- None.

## sky130hd

**Status**: finishing
**Last updated**: 2026-05-01 (commit `6511fb56`)

### Configuration
- `CORE_UTILIZATION = 40`
- `TNS_END_PERCENT = 100`
- Clock: `1.4 ns` (Fmax ~715 MHz)

### Decisions
- **2026-05-01 `6511fb56`**: clock relaxed in PR #109 (same shape as asap7) to match achievable Fmax on sky130hd's coarser cells.
- **2026-06-04**: validated on the bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64 upgrade. QoR within tolerance (WNS 10.95 → 22.01 ps, Fmax 0.72 → 0.73 GHz, 139 → 135 cells). No changes needed.

### Known issues / open questions
- None.

## gt2n

**Status**: finishing
**Last updated**: 2026-08-13

### Configuration
- `CORE_UTILIZATION = 80`, `PLACE_DENSITY = 0.85`
- `MAX_ROUTING_LAYER = M11`, `MIN_CLK_ROUTING_LAYER = M4`
- `TNS_END_PERCENT = 100`
- Clock: `160 ps` (period_min 139.38 ps; ratio 1.15)

### Decisions
- **Platform bringup**: lfsr was the first gt2n design ported; two ORFS-side patches and a bsg_fakeram bump were required before any gt2n build could complete, and apply to every subsequent gt2n design (see the infra commit):
  - **`orfs-gt2n-flow-build.patch`**: ORFS `flow/BUILD` hardcodes a per-platform allowlist for its Bazel glob/file-type rules; omitted gt2n.
  - **`orfs-no-rcx-spef-stub.patch`**: gt2n has no OpenRCX rules file, so ORFS never writes a SPEF; Bazel's declared-output contract requires `6_final.spef` to exist. Patch writes an empty SPEF when RCX isn't enabled.
  - **bsg_fakeram bump**: gt2n analytical bitcell/timing/pin-layer support.
- Reaches `_final` with WNS = 0, 0 DRC violations. Congestion never exceeded ~25% usage on any layer.
- **No antenna cells**: gt2n PDK ships no antenna filler cells. GRT-0246 ("no antenna cell found in the design library") fires on every gt2n build — benign; the router uses wire-jumping to resolve antenna violations, reaching 0 antenna DRC violations in the final report.
- **Backside PDN**: gt2n uses BSPDN (BPR followpins → BM1 → BM2 stripes, entirely on the backside stack). Signal layers M1–M13 carry no power. No `pdn.tcl` override is needed for std-cell-only designs — `platforms/gt2n/pdn.cfg` handles BSPDN correctly out of the box.

### Known issues / open questions
- None.
