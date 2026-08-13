# eyeriss Design Decisions

Per-platform notes for the `eyeriss` design (Eyeriss-v2 CNN accelerator, top `TOP`).
See `CLAUDE.md` (root) for the canonical upstream-bug index.

Macro-heavy (GLB iact/Psum SRAM spads). Uses RTLMP for macro placement.

## Active workarounds (all platforms)

- **`SKIP_INCREMENTAL_REPAIR` + `SKIP_LAST_GASP`** — post-GRT `repair_timing` makes only
  ~5 ps/iteration progress on the Psum spad/SRAM write paths and never converges in
  reasonable time. These are **convergence pragmatics, not a fixed-bug workaround**, so they
  are kept after the 2026-06 upgrade.
- ~~`SETUP_MOVE_SEQUENCE` (split_load-drop, ODB-1200)~~ **removed 2026-06-04** — ODB-1200 is
  fixed in OpenROAD 299f3015; the default move sequence is restored and CTS repair runs clean.

## 2026-06 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)

- **nangate45**: builds unchanged (minus the removed SETUP_MOVE_SEQUENCE) — WNS +340.8 →
  +133.4 ps (still positive), util 38.5 %, 307 701 logic cells (≈ baseline 307 085), Fmax
  0.24 → 0.23 GHz. Pass.
- **sky130hd**: WNS ≈ +1.9 ns (positive), 221 703 logic cells (≈ baseline 222 731). Pass.
- **asap7**: the new RTLMP fails **MPL-0040** annealing on `ClusterGroup_array.ClusterGroup_0_1`
  at util 40 (where the old RTLMP succeeded). Lowered `CORE_UTILIZATION` 40 → 30 to enlarge
  each cluster's macro sub-region so annealing converges (flow knob; costs die area). See the
  asap7 section for the result.

## 2026-08 FakeRAM regeneration (HighTide#234)

eyeriss was the **only** design whose FakeRAM cfgs lived at
`designs/<platform>/eyeriss/sram/fakeram_<platform>.cfg` instead of the standard
`designs/src/<design>/dev/generated/` path that `tools/regenerate_sram.sh` reads. The mass
regeneration in `94296798` — the bump to bsg_fakeram `c83ecb4` that fixed the **`wd_in` LEF
pin-direction bug** — therefore skipped eyeriss silently, and its committed LEFs kept
declaring the upper half of every `rw*/w*_wd_in` bus as `DIRECTION OUTPUT` while Liberty said
`input`. Reported from a downstream gate-level sim where those bits read as floating.

Cfgs moved to the standard path and LEF/LIB regenerated on all three platforms. Beyond the
direction fix the macros were stale on a second axis — they predate the asap7 area calibration
and the sky130hd analytical path:

| platform | Δ macro area | cause |
|---|---|---|
| nangate45 | **0.0 %, byte-identical** | CACTI path unchanged; direction fix only |
| asap7 | **+80 % … +389 %** | 2.5× periphery overhead + dynamic column mux calibration |
| sky130hd | **−16 % … −55 %** | analytical bitcell (1.07×1.74 µm, OpenRAM) replaces scaled CACTI |

Re-validated on bazel-orfs `6c1bbca` / OpenROAD `b65c274c`. **All three still reach `6_final`
with 0 DRC and 0 setup violations.** Baseline column is `fde02b5d` (results.html, toolchain
`553c1c3`), so it carries toolchain drift as well as the macro change — nangate45 is the clean
control for separating the two, since its geometry did not move.

| | asap7 base → new | nangate45 base → new | sky130hd base → new |
|---|---|---|---|
| die area µm² | 226 900 → **421 713** (+86 %) | 8 406 380 → 8 407 450 (+0.0 %) | 53 040 900 → **37 526 200** (−29 %) |
| util % | 30.8 → 30.7 | 38.5 → 38.5 | 31.9 → 32.3 |
| logic cells | 301 728 → 307 541 (+1.9 %) | 307 758 → 307 635 (−0.0 %) | 222 577 → 224 313 (+0.8 %) |
| setup WNS | +138.4 → **+141.3 ps** | +102.8 → **+247.5 ps** | +1348.4 → **+147.2 ps** |
| Fmax GHz | 0.42 → 0.42 | 0.23 → 0.24 | 0.04 → 0.04 |

- **nangate45** reproduces the baseline to within 0.05 % on every area/cell figure, confirming
  the CACTI geometry is untouched. Its +145 ps setup gain is therefore **pure toolchain drift**
  (`553c1c3` → `6c1bbca`), not a consequence of this change — useful as the scale of drift to
  discount elsewhere.
- **asap7** trades die area for correctness exactly as expected: the calibrated macros are
  ~2–4× larger, so at an unchanged util target the die nearly doubles. Timing, util and cell
  count are all flat. The `CORE_UTILIZATION` 40→30 MPL-0040 workaround is still in place and
  still needed.
- **sky130hd** shrinks 29 % (smaller macros), but setup margin falls from +1348 ps to +147 ps
  against an unchanged 25 ns clock. `report_clock_min_period` now gives `period_min` 24.85 ns,
  i.e. **set/period_min ≈ 1.006** versus the 1.10 guardband the repo's freq-push method targets.
  The nangate45 control (+145 ps of *favourable* drift) does not explain a −1201 ps swing, so
  this is attributable to the new macro geometry — the aspect ratios moved enough (e.g.
  `fakeram_7x512_1r1w` 2.11 → 1.07) that RTLMP produces a materially different floorplan.
  It closes cleanly, but with almost no headroom: relaxing the sky130hd clock toward
  `period_min × 1.10` ≈ 27.5 ns would restore the guardband at the cost of reported Fmax.
  **Left at 25 ns for now** — that is a PPA call, not a correctness one.
- **Hold**: asap7 clean (+23.1 ps). nangate45 −16.3 ps / 3 violations and sky130hd −374.2 ps /
  52 violations. These run with `SKIP_INCREMENTAL_REPAIR` + `SKIP_LAST_GASP`, which suppress the
  post-GRT repair passes, and the `fde02b5d` baseline did not record hold, so they are **not
  attributed** — an A/B against a pre-change build on this same toolchain pin would be needed
  to say whether the macro change caused them.

A grep-only guard (`tools/check_sram_lef.sh`, wired to a PR workflow) now fails any commit that
reintroduces a `wd_in` pin declared `DIRECTION OUTPUT`.

## asap7

**Status**: finishing — util 40→30 clears the new-RTLMP MPL-0040. On regenerated FakeRAMs
(`6c1bbca`): WNS +141.3 ps, hold +23.1 ps, util 30.7 %, 307 541 logic cells, Fmax 0.42 GHz,
die 421 713 µm², 0 DRC. Die area is ~1.9× the pre-regeneration figure because the calibrated
asap7 macros are 2–4× larger.

## nangate45

**Status**: finishing — WNS +247.5 ps, hold −16.3 ps (3 violations), util 38.5 %,
307 635 logic cells, Fmax 0.24 GHz, 0 DRC. Geometry byte-identical across the regeneration.

## sky130hd

**Status**: finishing — WNS +147.2 ps, hold −374.2 ps (52 violations), util 32.3 %,
224 313 logic cells, Fmax 0.04 GHz, die 37 526 200 µm², 0 DRC. Setup headroom is now thin
(`period_min` 24.85 ns against a 25 ns clock); see the 2026-08 section above.
