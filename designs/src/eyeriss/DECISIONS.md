# eyeriss Design Decisions

Per-platform notes for the `eyeriss` design (Eyeriss-v2 CNN accelerator, top `TOP`).
See `CLAUDE.md` (root) for the canonical upstream-bug index.

Macro-heavy (GLB iact/Psum SRAM spads). Uses RTLMP for macro placement.

## 2026-10-18 partial-sum router width correction

The upstream `Psum_Router` routes signed 21-bit ports through a scalar
`internal_data` wire, truncating every selected value to bit zero. The declared
archive patch `patches/eyeriss-psum-router-width.patch` makes that wire signed
21-bit. Both router input selections, both destinations, walking bits, negative
values and all handshake inputs pass 5888 simulation cases. The same test fails
on the pinned original source. Run `tools/check_eyeriss_psum_router.py --help`.
Original baseline physical results predate this fix and are diagnostic only;
the reviewed baseline must resynthesize and route the corrected datapath.

The synthesis coverage audit also reports 3195 structural combinational cycles.
Native constant propagation finds constant-valued pins in 3192; the remaining
three traverse AO21 A2-to-Y arcs with A1 tied low by the existing controller.
These are inactive routing paths, not additional timing exceptions. Preserve
the raw warnings and repeat this inspection on the final physical database.

The default static STA loop breaker nevertheless cuts 18 edges that are not
constant-disabled. The ASAP7 flow now enables `sta_dynamic_loop_breaking` in
the source SDC and its design-local physical-stage PRE hooks, retaining the platform's
existing Liberty suppressions. This preserves active path segments across
stages without adding timing exceptions or changing the 2500 ps clock / 500 ps
I/O budgets. On the same original synthesis database, both modes report setup
638.98 ps and hold 5.21 ps; matching worst slack alone does not certify every
path. The early width-only static trial was retired before floorplan completed.
The selected combined trial is `asap7-eyeriss-width-hooks-20261018`; validation
requires the setting in every physical-stage log and uses the frozen policy
for native final-database checks.

## 2026-10 SRAM depth-banking correction

The committed macro names retain aggregate depth, but their LEF/LIB interfaces
represent one physical bank. The old common wrappers instantiated one cell and
connected the full logical address. Yosys silently resized these ports, dropping
bank-select bits and aliasing logical addresses. Old PPA results below predate this
correction and must be regenerated before comparisons of the intended capacity.

`dev/generate_rtl.py` now expands `dev/macros_template.v` using each platform's
existing FakeRAM cfg. Each write/read enable selects its physical bank. The read
bank is registered on the read clock to align with synchronous macro outputs;
1rw writes hold the selected read bank. No extra read cycle, forwarding, reset
implementation or same-address read/write policy is introduced. Reset pins remain
unused as before; macro collision semantics require a functional contract or
avoidance by the caller.

The unused upstream `SCNN_shape_info_compiler` is an unfinished reference helper:
`layer0_flag` through `layer4_flag` and `psum_acc_times` are undeclared. A declared
archive patch fixes its trailing port-list comma and empty `else if()` stub, then
wraps that module in `` `ifndef SYNTHESIS `` so it is removed before
synthesis parsing. No declarations, drivers, or functional behavior are invented.
The LiveHD baseline defines `SYNTHESIS=1` and uses
`--ignore-uninstantiated-modules` explicitly for HighTide.

The three platform BUILD files select `:rtl_asap7`, `:rtl_nangate45` or
`:rtl_sky130hd`; the original `:rtl` / `:gen_eyeriss` names retain ASAP7 compatibility.
RTL assembly is now portable to macOS as well as Linux (no GNU-only `sed -i`).
The unchanged 193 logical memories expand to 1040 physical banks on ASAP7,
308 on Nangate45 and 532 on Sky130HD. No flow knobs were retuned.

Validation: all three RTL assembly targets build. The reproducible check below
passes all 21 wrapper/platform cases: LEF/Liberty address widths and physical macro
counts, no Yosys port resizing, and simulation over every logical address with
independent write/read clocks, cross-bank access, read latency and held read output.
The synchronous CE-controlled behavioral models exclude simultaneous same-address
read/write and do not establish an unspecified physical macro collision policy.

A full LiveHD Slang/ABC synthesis-only check also preserves all 1040 ASAP7
physical SRAM cells. Independent Yosys elaboration of that emitted netlist finds
no native arrays or unmapped cells after assignment/constant-wiring cleanup.
This does not establish full-design equivalence, timing or placement; mixed
SRAM/standard-cell timing units still need validation before that comparison.

```
python3 designs/src/eyeriss/dev/check_wrappers.py \
  --iverilog /path/to/iverilog --vvp /path/to/vvp --yosys /path/to/yosys
bazel build //designs/src/eyeriss:gen_eyeriss \
  //designs/src/eyeriss:gen_eyeriss_nangate45 \
  //designs/src/eyeriss:gen_eyeriss_sky130hd
```

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

The attempted `PLATFORM_TCL` override was ineffective because the ASAP7 platform
Makefile assigns it after design defaults. That early trial was retired; stage
PRE hooks apply after the normal platform setup. Actual stage-log assertions
prevent accepting a configuration that merely declares the desired setting.
