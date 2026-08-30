# gemmini Design Decisions

Per-platform notes on tuning, workarounds, and platform-specific quirks for `gemmini` (Berkeley ML systolic array accelerator, Chisel/Scala).  See `CLAUDE.md` (root) for the canonical upstream-bug index.

## Hermetic RTL generation (2026-07, gallery-style)

`gemmini.v` is generated hermetically by Bazel from **Chisel 3.6.1** run under
`rules_scala` (the same toolchain as sha3 — see `designs/src/sha3/DECISIONS.md`
for the Maven/Scala-2.13.12 override details), replacing `dev/setup.sh`'s
sbt-from-curl. The upstream ucb-bar/gemmini Chisel sources (`@gemmini_src`) plus
the checked-in `GemminiMeshTop.scala` / `Arithmetic.scala` / emitter are compiled
by `:gemmini_emitter` and run by the `:gen_gemmini` genrule; no `dev/repo`
submodule. These designs are chisel3-only (no rocket-chip/chipyard), so a plain
`scala_binary` suffices — no rules_chisel / CIRCT / firtool.

- **Reproducibility**: same `@[...]` source-path normalization as sha3.
- **Equivalence**: the generated `gemmini.v` is **byte-identical to the
  previously-committed RTL modulo the `@[...]` source-locator comments** (the
  logic is unchanged), so QoR tracks the results.html baseline.

Large macro-heavy ML accelerator with FakeRAM black-boxes for the accumulator and scratchpad SRAMs.

## Active workarounds (all platforms)

- ~~**ODB-1200** in CTS-time `repair_timing` — `SETUP_MOVE_SEQUENCE = "unbuffer,sizeup,swap,buffer,clone"` (drop `split_load`).~~ **Removed 2026-06-04** on the bazel-orfs 553c1c3 / OpenROAD 299f3015 upgrade — the resizer bug is fixed, so the default move sequence (with `split_load`) is restored and all three platforms close cleanly with no ODB-1200. See [HighTide#75](https://github.com/VLSIDA/HighTide/issues/75).

## asap7

**Status**: finishing
**Last updated**: 2026-05-03 (commit `45b54bd1`)

### Configuration
- `CORE_UTILIZATION = 35` — macro-heavy; lower std-cell density helps router around macro pin clusters
- `SETUP_MOVE_SEQUENCE` removed 2026-06-04 (ODB-1200 fixed upstream) — default sequence restored
- `io.tcl`, `pdn.tcl` present (manual IO placement + power grid)
- Clock: `1.5 ns` (Fmax ~667 MHz)

### Decisions
- **2026-05-03 `45b54bd1`**: closed timing in PR #114 by combining the SETUP_MOVE_SEQUENCE workaround for ODB-1200 with appropriate clock period.
- **2026-06-04 toolchain upgrade**: removed the SETUP_MOVE_SEQUENCE workaround (ODB-1200 fixed in OpenROAD 299f3015). Closes clean on the 1.5 ns clock: WNS +70.5 ps (Fmax 0.70 GHz), util 44.8%, 675388 logic cells. No SDC/RTL change.

### Known issues / open questions
- None.

## nangate45

**Status**: finishing
**Last updated**: 2026-05-03 (commit `45b54bd1`)

### Configuration
- `CORE_UTILIZATION = 35`
- `SETUP_MOVE_SEQUENCE` removed 2026-06-04 (ODB-1200 fixed upstream)
- Clock: `3.0 ns` (Fmax ~333 MHz)

### Decisions
- **2026-05-03 `45b54bd1`**: closed timing in PR #114, same workaround as asap7.
- **2026-06-04 toolchain upgrade**: removed SETUP_MOVE_SEQUENCE (ODB-1200 fixed). Closes clean: WNS +115.7 ps on the 3.0 ns clock, util 43.7%, 376009 cells.

### Known issues / open questions
- None.

## gt2n

**Status**: finishing
**Last updated**: 2026-08-30 (commit `369d583`)

### Configuration
- `CORE_UTILIZATION = 87` (`PLACE_DENSITY = 0.94`) — much higher than the other platforms' 30-35%; unlike asap7/nangate45/sky130hd, gt2n handles this design's macro pin density well at high utilization. 40% was tried and performed far worse (timing-repair non-convergence, 3.3x cell-count blowup); 90% failed outright (GPL-0301, real GP utilization hit 103% against the 90% nominal target).
- `MAX_ROUTING_LAYER = M11`, `MIN_CLK_ROUTING_LAYER = M4`
- Clock: `1450 ps` (Fmax 689.7 MHz)
- Input delay set to standard `clk_io_pct * period` + 67 ps (357 ps vs 290 ps) to relieve hold at the IO boundary — the worst hold violations are on input port feedthrough paths, not reg to reg (which closes clean).

### Decisions
- **2026-08-30 `369d583`**: initial gt2n port. Setup closes cleanly (WNS +2.38 ps, 0 violations). Hold has 15 residual violations (worst -9.83 ps, TNS -31.85 ps). `HOLD_SLACK_MARGIN` was evaluated as an alternative to the input-delay bump but any value large enough to help (e.g. 67) caused CTS-time repair to insert tens of thousands of hold buffers, congesting detailed placement to a hard failure (DPL-0036); smaller values (5, 10) avoided the crash but didn't reliably improve on the input-delay-only result.

### Known issues / open questions
- Hold not fully closed (15 violations, worst -9.83 ps). Further input-delay tuning showed diminishing/non-monotonic returns; not yet resolved.

**Status**: finishing
**Last updated**: 2026-05-03 (commit `45b54bd1`)

### Configuration
- `CORE_UTILIZATION = 30` — lowest util across the three platforms; sky130hd macro-pin congestion is worst here
- `SETUP_MOVE_SEQUENCE` removed 2026-06-04 (ODB-1200 fixed upstream)
- Clock: `13 ns` (Fmax ~77 MHz)

### Decisions
- **2026-05-03 `45b54bd1`**: closed timing in PR #114.  Util had to drop further than asap7/nangate45 to keep GP overflow under control on the macro-heavy floorplan.
- **2026-06-04 toolchain upgrade**: removed SETUP_MOVE_SEQUENCE (ODB-1200 fixed). Closes clean: WNS +338.5 ps on the 13 ns clock, util 33.8%, 323582 cells.

### Known issues / open questions
- None.
