## 2026-10-18 forwarded-clock timing model

The connected `m_aclk` output forwards `clk` to the external AXI interface.
Its SDC also needs a 1:1 generated clock. Treating it as data sends timing
repair through the clock distribution network. A controlled comparison on
the corrected-mask CTS database changes worst setup from −6508.45 ps on
that clock output to −184.36 ps on real data; worst hold remains −1446.66 ps.
The original archived database, with its missing clock connection restored
only in memory, independently preserves setup +214.13 ps and hold −54.81 ps.

Both comparisons preserve every other serialized constraint, four raw-TDI
paths and eight later synchronizer paths. The CPU period remains 2841 ps and
the functional I/O budget remains 568.2 ps. No new path exception is added.
Evidence is in `artifacts/asap7-nyuzi-forwarded-clock-audit-20261018/proof.json`.
The incomplete clock-model trial is retained; the combined current run is
`artifacts/asap7-nyuzi-clock-model-20261018`. Final acceptance also checks the
actual serialized generated clock and absence of a data check on `m_aclk`.

## 2026-10-18 scoped asynchronous JTAG boundary

The pinned TAP RTL explicitly samples `{tck,tms,tdi,trst_n}` through a
three-stage synchronizer. The old ASAP7 SDC assigned these first-stage D
checks the CPU's I/O phase. Add exactly four source/destination exceptions
from each external JTAG port to its corresponding `sync0` D pin. Strict
selectors fail if the intended first-stage pin cannot be found.

Raw TDI also drives four debug data-register endpoints directly. Those paths
remain timed, together with all eight paths through the second and third
synchronizer stages. Native fanout inspection, actual source-SDC selectors,
and write/read SDC round-trip checks verify this scope. No JTAG frequency,
protocol multicycle constraint, CPU period or functional I/O budget is added
or relaxed. The original 2841 ps / 568.2 ps CPU/data contract stays intact.

The incomplete JTAG-boundary trial was retired. The subsequent
`artifacts/asap7-nyuzi-clock-masks-jtag-20261018` trial was superseded by the
forwarded-clock model above. The current run's final model proof must
validate actual compiled exceptions, four direct TDI paths and eight later
synchronizer paths, all 2533 high SRAM mask pins, both forwarded signals, and
the tested frozen SDC/RTL hashes. Remaining real timing failures stay visible.

## 2026-10-18 ASAP7 memory and forwarded-clock audit (validation pending)

Native final coverage checking found 2535 unconstrained endpoints: 2533 SRAM
write-mask pins and the `m_aclk` / `m_aresetn` outputs. The current ASAP7
FakeRAM models expose active-high per-bit `w0_wmask_in`, but all ten whole-word
wrappers omitted that port. Final netlists place these inputs on undriven
`_NC` nets. A readback test using the pinned FakeRAM Verilog generator fails
with the original wrappers.

The wrappers now tie every mask bit high under `USE_ASAP7_CELLS`, enabled
explicitly in the ASAP7 BUILD. Nangate45's ten macro interfaces are unmasked,
so the guard preserves that interface. The macro files and geometry remain
unchanged. Tests pass for all ten repaired masked wrapper types and for the
legacy unmasked interface: every bit, both read ports, and disabled writes.
See `tools/check_nyuzi_ram_masks.py` and the `asap7-nyuzi-mask-before`,
`asap7-nyuzi-mask-scoped-after`, and `asap7-nyuzi-mask-unmasked-compat`
20261018 artifact directories. A native negative control also rejects all
2533 floating mask inputs in the archived original database.

The original forwarded AXI clock is also physically disconnected. Synthesis
has a buffer from `clk` to `m_aclk`; the final `output7872` buffer has no A
connection. Physical reachability from `clk` visits 3250 nets without reaching
`m_aclk`, and native fan-in stops at `output7872/A`. The targeted PRE_CTS hook
restores that input only if CTS disconnects it. Injecting the hook into the
original database in memory restores reachability (3251 nets) without changing
the saved original. The other output finding, `m_aresetn`, traces only to the
already false-pathed `reset` input. No clock or data I/O constraint is changed.

The hold-only trial and intermediate mask-plus-hold trial were intentionally
canceled (exit 8) once these additional defects were proven; their records
remain. The intermediate trial was
`artifacts/asap7-nyuzi-clock-masks-hold-20261018`, combining the mask correction,
conditional forwarded-clock repair and 80 ps routed hold guard described
below; it was superseded by the JTAG and clock-model corrections above.
The original Nyuzi figures are diagnostic, not a functional reference.
The synthesized netlist intentionally changes; the clock period and I/O
contract stay fixed. Acceptance requires extracted timing/DRC checks, actual
constant-high mask pins and physical forwarded-clock reachability.

## 2026-10-18 ASAP7 baseline hold audit (validation pending)

The original final target completes at the unchanged 2841 ps period with
setup +214.134 ps, but hold −54.8109 ps and 294 hold violations. Worst hold is
a writeback-register-to-vector-register-file SRAM path, not an untimed memory
interface. Global-route worst hold was only −1.46827 ps (four violations),
so final extraction exposes additional violations.

Add `PRE_GLOBAL_ROUTE_TCL=pre_grt.tcl`, setting `HOLD_SLACK_MARGIN=80` only
at global route. Preserve the existing CTS settings and the full normal
setup/hold repair sequence. RTL, clock period, I/O delays, and reset exceptions
are unchanged; no SRAM timing path is waived. The selected margin covers the
observed roughly 53 ps worst-slack degradation with additional repair guard.
It is a candidate until final extraction confirms setup/hold and routing DRC.
The initial isolated hold-only run was superseded by the memory and clock
corrections above. Do not require synthesized-netlist identity across the
intentional write-mask correction; retain all original and repaired hashes.

# NyuziProcessor Design Decisions

Per-platform notes for `NyuziProcessor` (Jeff Bush) — an open-source GPGPU written in SystemVerilog, with a 4-thread × 16-lane vector ISA. The HighTide port uses 8 vector lanes (halved from upstream 16 to reach a tractable cache-line width) and 2 L2 cache ways (halved from upstream 4) to fit asap7/nangate45/sky130hd floorplans.

## Hermetic RTL sourcing (2026-07, gallery-style)

`NyuziProcessor.v` is generated hermetically by Bazel — upstream SystemVerilog
(`jbush001/NyuziProcessor @ ed5c1a50`, via `@nyuzi_src`) lowered to Verilog-2005
by **sv2v pinned to the v0.0.13 prebuilt release** (`@sv2v`), replacing the
`dev/setup.sh` that built sv2v from an unpinned Haskell Stack checkout of
`master`. No `dev/repo` submodule.

- **FakeRAM swap is now a declarative patch**: `patches/fakeram-swap.patch`
  (rewritten from the old `dev/patch-all.patch` to be archive-root-relative) is
  applied on `@nyuzi_src` and rewrites the generic `sram_1r1w` / `sram_2r1w` /
  `cache_lru` instantiations to FakeRAM macros. Those three source modules are
  excluded from the sv2v input (`external.BUILD.bazel` `core_sv` filegroup) and
  provided instead by the checked-in `cache_lru.v` (`cache_lru_4x64`) and
  `macros.v` (the fakerams). `nyuziTop.sv` (HighTide top wrapper, moved out of
  `dev/` to the design root; its include fixed to `defines.svh` resolved via
  sv2v `-I`) and those two `.v` files stay checked in.
- **`patch_tool = "patch"`** is set on the `@nyuzi_src` `http_archive`: Bazel's
  native patcher rejected a couple of hunks (`CONTENT_DOES_NOT_MATCH_TARGET` on
  `tlb.sv`) that GNU `patch` applies fine with fuzz.
- The sv2v v0.0.13 output differs structurally from the previously-committed
  `NyuziProcessor.v` (the old file was made with a different sv2v `master`
  revision — same line count, ~28 % of lines differ in lowering detail) but is
  functionally equivalent: **asap7 synthesis yields 40 908 sequential cells vs
  the results.html post-route baseline's 40 906** (a 2-cell synth-vs-route
  delta — the register structure is identical).
- **Synth-time note**: asap7 yosys synthesis of the v0.0.13 output is slow
  (~21 min, ~2 GB peak) — 41 % of the time is in `extract_fa` (full-adder
  extraction) and 32 % in abc. This is a property of how sv2v v0.0.13 lowers
  the vector-ALU arithmetic (different from the old sv2v-master output); it
  converges to the same design. If synth wall-time becomes a problem, pin a
  newer sv2v release or set `SYNTH_MINIMUM_KEEP_SIZE` / disable `extract_fa`.

FakeRAM macros live at `designs/<platform>/NyuziProcessor/sram/{lef,lib}/` and are wrapped by `designs/src/NyuziProcessor/macros.v`.

## asap7

**Status**: finishing (PR #185, 2026-05-30)

### Configuration

| Knob | Value | Notes |
|---|---|---|
| `CORE_UTILIZATION` | 65 | PPA sweep raised 55 → 65; 55 macros are 52% of core, std cells pack the rest. GRT peak 32% on M2 — wide open. |
| `PLACE_DENSITY_LB_ADDON` | 0.22 | Spread cells slightly given the large macro count. |
| `MACRO_PLACE_HALO` | `6 6` | Aggressive (cells are small on asap7). |
| `clk_period` | 3000 ps | Tighter target pushes synth/repair; Fmax = 273.76 MHz (period_min = 3653 ps). WNS reported negative against target — see "Reported WNS" below. |
| `SKIP_CTS_REPAIR_TIMING` | 1 | ODB-1200 workaround — see [CLAUDE.md](../../../CLAUDE.md) bug table. |
| `SKIP_INCREMENTAL_REPAIR` | 1 | ODB-0445 workaround — see CLAUDE.md bug table. |
| `PDN_TCL` | `pdn.tcl` (copy of gemmini's) | Required; default platform PDN was too sparse — see PSM-0069 note below. |
| `PRE_CTS_TCL` | `pre_cts.tcl` | CTS-0105 workaround — see CLAUDE.md bug table. |

### QoR (cached on remote build cache, 2026-05-27)

| Metric | Value |
|---|---|
| Fmax | 273.76 MHz |
| period_min | 3652.77 ps |
| Core area | 1170 k µm² (1084 × 1084 µm) |
| Route DRC | 0 |
| PSM connectivity | 0 warnings |
| IR-drop violations | 0 |
| Macros / sequential / combinational | 55 / 40 906 / 209 621 |
| Power | 162 mW |

### Decisions

- **2026-05-25 (PR #185)** — initial close after the long-running port effort failed at PSM-0069 with 18 000+ unconnected filler VDD pins. Root cause: default asap7 platform PDN was too sparse for this design's macro density; PDN-gen removed 983 M2→M5 vias near macro pin obstructions, leaving M1 followpin shapes disconnected. Fix: copied `designs/asap7/gemmini/pdn.tcl` as a denser starting grid (M1/M2 followpins + M5/M6/M7 cross-stripes + macro grids).

- **2026-05-27 (PR #185, second commit)** — 3-step disciplined PPA sweep from the post-PDN-fix baseline:

  | iter | util | SDC (ps) | Fmax (MHz) | core (µm²) | DRC/PSM/IR |
  |---|---:|---:|---:|---:|---|
  | baseline | 55 | 3800 | 215.67 | 1383 k | 0 / 0 / 0 |
  | iter 1 | 65 | 3800 | 241.41 | 1170 k | 0 / 0 / 0 |
  | **iter 2 (landed)** | **65** | **3000** | **273.76** | **1170 k** | **0 / 0 / 0** |
  | iter 3 abort | 65 | 2500 | — | — | host died mid-build |

  Net vs baseline: **+27% Fmax, −15% area**, all checks clean.

  - **Util 55 → 65**: at baseline, std-cell utilization in the available (non-macro) space was only 7.9% — massive packing headroom. Die shrunk without hitting routing or congestion limits. Macros are now 52% of core; that's the floor without repacking the macros themselves.
  - **SDC 3800 → 3000 ps**: looser 3800 ps targets left synth/repair_timing under-motivated; tightening pushed both to pick faster cells and to optimize the wire-bound L2-cache critical path (`sram_l2_data → l2_response[307]`) harder.

- **2026-05-27** — at util 65 the denser placement exposed **ODB-0445** in post-GRT `repair_timing` (`[CRITICAL] No undo_updateField support for type dbTechNonDefaultRule`). The resizer's `Journal::undo` can't unroll changes to non-default routing rules made during repair, so the slack-spiral retry on a single endpoint crashes out. Same workaround family as snitch_cluster/litedram: `SKIP_INCREMENTAL_REPAIR = 1`. Detailed-route hold-repair still runs and DRC stays clean. Documented in CLAUDE.md's bug-workaround table.
- **2026-06-04 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)** — removed **all three** workarounds: `PRE_CTS_TCL` (CTS-0105 #10177, fixed), `SKIP_CTS_REPAIR_TIMING` (ODB-1200, fixed), `SKIP_INCREMENTAL_REPAIR` (ODB-0445, fixed). CTS and full post-GRT `repair_timing` now run without skip or crash, and timing actually improves — reported WNS +417 ps (vs the prior −653 ps SDC-tightness artifact), util 65.7 %, 370 761 logic cells, 55 macros. `pre_cts.tcl` deleted.

### Reported WNS vs achievable Fmax

The flow reports WNS = −653 ps at the 3000 ps target. That's not a real timing failure: it's the gap between the SDC target and the design's achievable period (3653 ps). Setting SDC to 3653 ps would zero the WNS but synth would slack off, increasing the period — a known ORFS pitfall (the [[#sdc-tightness-coupling]] note below). The reported `period_min`/`fmax` from `report_clock_min_period` are the truth: 273.76 MHz.

### Known issues / open questions

- **CTS-0105 false skip** — yosys hierarchical synthesis output port buffers arrive in ODB with `dbSourceType::TIMING`; `PRE_CTS_TCL` resets them to `NETLIST` before CTS runs ([OpenROAD #10177](https://github.com/The-OpenROAD-Project/OpenROAD/issues/10177)).
- **ODB-1200** in CTS repair_timing — the gemmini-style targeted fix (drop `split_load` from `SETUP_MOVE_SEQUENCE`) didn't clear it for this design; escalated to `SKIP_CTS_REPAIR_TIMING = 1` ([HighTide #75](https://github.com/VLSIDA/HighTide/issues/75)).
- **ODB-0445** in post-GRT repair_timing — only surfaces at util ≥ 65 here; no upstream issue filed yet.

## nangate45

**Status**: finishing (long-running baseline)

### Configuration

| Knob | Value | Notes |
|---|---|---|
| `CORE_UTILIZATION` | 57 | |
| `PLACE_DENSITY_LB_ADDON` | 0.1 | |
| `MACRO_PLACE_HALO` | `40 40` | Larger metal pitch needs more keep-out. |
| `clk_period` | 4.5 ns (4500 ps) | |
| `ABC_AREA` | 1 | |
| `FASTROUTE_TCL` | `fastroute.tcl` | Per-layer routing adjustments. |
| `PRE_CTS_TCL` | `pre_cts.tcl` | CTS-0105 workaround. |

### Known issues / open questions

- None active. **2026-06-04 toolchain upgrade**: removed the `PRE_CTS_TCL` CTS-0105 workaround (fixed upstream, #10177). Closes clean — WNS +68.8 ps, util 57.6 %, 377 350 logic cells (≈ baseline 386 497). `pre_cts.tcl` deleted.
