# coralnpu Design Decisions

Per-platform notes on tuning, workarounds, and platform-specific quirks for `coralnpu` (Google CoreMiniAxi NPU).  See `CLAUDE.md` (root) for the canonical upstream-bug index.

Mid-large NPU with several FakeRAM macros.  Hierarchical synthesis required for tractable build times.

## Hermetic RTL generation (2026-07, gallery-style Chisel 7)

coralnpu is the one design that could not preserve its exact prior RTL while
becoming hermetic (its old flow was a *nested* Bazel 7.4.1 Chisel-7 build +
sv2v + heavy perl, none of which is hermetic in the parent Bazel).  It was
therefore **ported to the bazel-orfs gallery's Chisel-7 flow**, which *does*
change the RTL/QoR (accepted trade-off) — see the flagged delta below.

- **Toolchain**: `rules_chisel` 0.3.1 elaborates the Chisel 7 sources to FIRRTL;
  `fir_library` + `verilog_directory` (bazel-orfs-verilog) run **firtool** to
  SystemVerilog.  Runs on **Scala 2.13.17** (the cross-build version), coexisting
  with the 2.13.12 used by the Chisel-3.6.1 designs (sha3/gemmini) via
  `scala_config.settings(scala_versions=[...])` + the `scala_version` attribute.
- **Source**: `@coralnpu` (google-coral) at the gallery's SHA `04c48f55` (the old
  submodule was `7731fd6e`), plus its Chisel-7 dep tree (`@rocket_chip`,
  `@diplomacy`, `@common_cells`, `@cvfpu`, `@fpu_div_sqrt_mvp`).  Patched with
  the gallery's `chisel7-compat.patch` + the two `cvfpu-*` patches.
- **Memory refactor as a declarative patch**: `patches/fakeram-memories.patch`
  replaces `hdl/verilog/Sram_512x128.v` / `Sram_2048x128.v` with FakeRAM-backed
  blackboxes (`module Sram_512x128 -> fakeram_512x128`, from `macros.v` →
  `fakeram_512x128_1rw` in `sram/` LEF+LIB).  Was a manual `cp` in the old
  `setup.sh`; now applied on `@coralnpu`.
- **Frontend**: the generated SystemVerilog is fed to **yosys-slang**
  (`SYNTH_HDL_FRONTEND=slang` + `SYNTH_SLANG_ARGS` with the common_cells include
  dir), matching the gallery — not the old sv2v/perl Verilog-2005 path.
- `:rtl` = `//designs/src/coralnpu/chisel:coralnpu_all_sv` + `macros.v`.  The
  submodule, `setup.sh`, `install/`, and `Sram_*_REPLACE.v` are removed;
  `macros.v`, `sram/` LEF+LIB, and `dev/generated/fakeram_*.cfg` are kept.

**QoR change (flagged regression)**: the new Chisel-7 RTL differs structurally
from the old sv2v/perl output, so QoR shifts from the results.html baseline
(die 112967 / core 111567 / util 40.5 / cells 156942 / Fmax 0.35 / power 71.4).
See the per-platform QoR captured after this port lands.

## Common to all platforms

- `SYNTH_HIERARCHICAL = 1` — flat synthesis runs out of memory / time on this design's hierarchy.
- `TNS_END_PERCENT = 100` — repair every violator (target Fmax is loose enough that this converges).

## asap7

- **2026-10 baseline audit (current Chisel-7 RTL)**: builds to final with
  route DRC 0. At the unchanged 3000 ps target, setup WNS is -207.310 ps
  (296 violations), hold +14.9612 ps (0 violations), reported Fmax
  0.311788 GHz, 168700 logic cells, stdcell area 21027.8 um², power
  73.6218 mW. There are 691 slew violations; cap/fanout counts are zero.
  This is a setup-negative reference for the ported RTL, not the earlier
  sv2v/Chisel baseline. Clock and interface constraints were not relaxed.

**Status**: finishing
**Last updated**: 2026-04-26 (commit `643ba623`)

### Configuration
- `CORE_UTILIZATION = 40`
- `PLACE_DENSITY_LB_ADDON = 0.20`
- `MACRO_PLACE_HALO = "6 6"` — small halo since asap7 cells are physically tiny
- Clock: `3000 ps` (Fmax ~333 MHz)

### Decisions
- **2026-04-26 `643ba623`**: initial close.  Halo 6×6 chosen to keep std cells out of macro shadow but avoid wasting die area.
- **2026-06-04**: validated on the bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64 upgrade. Closes clean: WNS +123 ps on the 3000 ps clock, util 40.5%, 156858 logic cells, 2 macros. No change needed.

### Known issues / open questions
- None.

## nangate45

**Status**: finishing
**Last updated**: 2026-04-26 (commit `643ba623`)

### Configuration
- `CORE_UTILIZATION = 40`
- `PLACE_DENSITY_LB_ADDON = 0.20`
- `MACRO_PLACE_HALO = "40 40"` — much larger than asap7 because nangate45's cells are ~10× wider, so the equivalent stdcell-rows-of-clearance value scales up
- Clock: `9 ns` (Fmax ~111 MHz)

### Decisions
- **2026-04-26 `643ba623`**: halo bumped to 40×40 (vs asap7's 6×6) — same number of stdcell tracks of macro clearance, just expressed in micrometers at nangate45's pitch.
- **2026-06-04**: validated on the bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64 upgrade. Closes clean: WNS +998 ps on the 9 ns clock, util 40.3%, 140663 logic cells, 2 macros. No change needed.

### Known issues / open questions
- None.

## sky130hd

**Status**: finishing
**Last updated**: 2026-04-26 (commit `6d6f2dc2`)

### Configuration
- `CORE_UTILIZATION = 20` — much lower than asap7/nangate45; sky130hd's coarse pitches plus this design's macro count create heavy local-density hot spots
- `PLACE_DENSITY = 0.15` — explicit (not addon)
- `MACRO_PLACE_HALO = "30 30"`
- Clock: `30 ns` (Fmax ~33 MHz)

### Decisions
- **2026-04-26 `6d6f2dc2`**: util dropped to 20%, density set explicitly to 0.15 to relieve sky130hd routing congestion on this macro-heavy NPU.
- **2026-06-04 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)**: reaches `_final`; 148 566 logic cells (−1.2 % vs baseline 150 363), util 23.1 %. Reported WNS +507 → −269 ps on the 30 ns clock — that is −0.9 % of the clock period (achievable Fmax change ~2.3 %, within tolerance) and the worst path is a **reset-removal check** (`csr/resetReg → mcycle[59]`), not a functional setup path. Accepted as-is; no SDC/RTL change (recovering it would require a reset-removal false-path = constraint change).

### Known issues / open questions
- Reported WNS marginally negative (−269 ps, a reset-removal check ≈ −0.9 % of period) after the 2026-06 upgrade; design routes and reaches 6_final with area unchanged.
