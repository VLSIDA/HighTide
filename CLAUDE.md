# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HighTide is a VLSI design benchmark suite built on OpenROAD-flow-scripts (ORFS). It ports open-source hardware designs to asap7/sky130hd/nangate45 technologies using the OpenROAD RTL-to-GDSII flow, serving as a benchmark suite for ML projects.

## Setup

Requires an Ubuntu machine with [Bazelisk](https://github.com/bazelbuild/bazelisk) (or Bazel 7.6.1+). No additional setup needed — Bazel fetches everything via `MODULE.bazel` and the pinned `bazel-orfs` submodule.

## Build Commands

```bash
# Build the full RTL-to-GDS flow for one design (through the gallery
# render — caches the layout PNG too, so update-results is a pure fetch)
bazel build //designs/asap7/lfsr:lfsr_gallery

# Build a design across all available platforms
bazel build //designs/asap7/minimax:minimax_final \
            //designs/nangate45/minimax:minimax_final \
            //designs/sky130hd/minimax:minimax_final

# Build all designs for a platform
bazel build //designs/asap7/...

# Build all designs across all platforms
bazel build //designs/...

# Build individual stages (target suffixes: _synth, _floorplan, _place, _cts, _grt, _route, _final)
bazel build //designs/asap7/lfsr:lfsr_synth
bazel build //designs/asap7/lfsr:lfsr_place
```

Note: `hightide_design()` exposes the per-stage `orfs_flow` targets (`_synth` … `_final`), `_generate_abstract` / `_generate_metadata`, and `_<design>_gallery` (renders the layout PNG; `src = :<design>_final`). There is no aggregate `:<design>` target. **Build `:<design>_gallery` for sweeps** — it runs the whole flow *and* renders+caches the gallery image, so `update-results` (and k8s/run.sh, which now targets `_gallery`) becomes a pure cache fetch with no per-design local re-render. Use `:<design>_final` only when you explicitly don't want the image.

## Architecture

### Key Relationships

- **`MODULE.bazel`** — Mirrors `bazel-orfs`'s root-only overrides (it pins ORFS/OpenROAD via `archive_override` tarballs, builds OpenROAD from source, yosys `0.64`, sv-lang/scip/sed/boost.unordered `single_version_override`s) and adds HighTide's yosys-slang plugin. Keep in sync with `bazel-orfs/MODULE.bazel` at the pinned submodule commit when bumping (see the `upgrade-tools` skill). `.bazelrc` carries `--@openroad//:platform=gui` (needed by the `_gallery` render)
- **`defs.bzl`** — `hightide_design()` macro wrapping `orfs_flow()` with common defaults (`GDS_ALLOW_EMPTY`, platform-to-PDK mapping)
- **`BUILD.bazel`** (root) — Defines the `merge_yosys_share` target that bundles the yosys-slang plugin
- Each design has a `BUILD.bazel` calling `hightide_design()` with its parameters (utilization, density, SRAMs, etc.)
- RTL sources are fetched hermetically: `designs/src/<design>/BUILD.bazel` aliases `:rtl` to the pinned `@<design>_src` archive (or to a local converter target)

### Design Configuration

Each design lives at `designs/<platform>/<design>/` and contains:
- **`BUILD.bazel`** — Calls `hightide_design()` with verilog_files, sources (SDC, LEFs, LIBs), arguments (utilization, density, etc.)
- **`constraint.sdc`** — Clock definitions and timing constraints
- **`pdn.tcl`** (optional) — Power delivery network configuration (layer stripes, pitches)
- **`io.tcl`** (optional) — Pin placement constraints

### RTL Source Management (`designs/src/`)

Design RTL sources are pinned as hermetic `http_archive`s in the root `MODULE.bazel` (`@<design>_src`) — no git submodules, no vendored RTL.

Each `designs/src/<design>/` has:
- `external.BUILD.bazel` — injected BUILD for the fetched archive; exposes an `:rtl` filegroup (or the source files a converter consumes)
- `BUILD.bazel` — a stable `:rtl` alias pointing at `@<design>_src//:rtl`, or at a local converter target (sv2v genrule, Chisel `scala_binary` under `rules_scala`, or a Python `py_binary` generator that emits `:gen_<design>`)

Source fixes are declarative `patches = [...]` on the `http_archive`. To move a design to a newer upstream, bump its archive `urls`/`sha256`/`strip_prefix` in `MODULE.bazel`.

### Platforms

| Platform | Node | Designs |
|----------|------|---------|
| asap7 | 7nm academic | coralnpu, gemmini, lfsr, litedram, minimax, sha3, vortex, liteeth, NVDLA (partitions a/c/m/o/p), bp_processor (bp_uno, bp_quad), cnn, floonoc, NyuziProcessor, snitch_cluster |
| nangate45 | 45nm | coralnpu, gemmini, lfsr, litedram, minimax, NyuziProcessor, sha3, liteeth, bp_processor (bp_uno, bp_quad), cnn |
| sky130hd | 130nm open | gemmini, lfsr, litedram, minimax, sha3, liteeth, cnn, bp_processor (bp_uno) |

#### Build status

Per-design close history, knobs, QoR, and known issues live in **`designs/src/<design>/DECISIONS.md`**, with one `## <platform>` section per technology. Update there, not here — this index just tracks which (design, platform) pairs are reaching `_final`.

**The authoritative "which pairs finish" list is the `webpage` worktree's `results.html`** (one QoR row per finishing pair), not this index — the lists below had drifted stale (they understated coverage; e.g. eyeriss/floonoc/litepci/snitch_cluster/ternip/partition_p all finish). As of the 2026-06 toolchain upgrade the suite has **59 finishing (platform, design) pairs**.

Reaching `_final` on the **2026-06 upgraded tools** (bazel-orfs `553c1c3`), validated clean (QoR within ~5 % of the pre-upgrade `results.html` baseline):
- lfsr, minimax, sha3, ternip (all 3 platforms); coralnpu, liteeth, gemmini, litedram (all 3); NyuziProcessor (asap7/nangate45); floonoc (all 3 platforms); eyeriss (all 3); litepci (asap7/nangate45); **all NVDLA partitions a/m/o/p (asap7/sky130hd), a/c/m/o/p (nangate45), partition_c (asap7)**; vortex-asap7.

Reaching `_final` but with a **flagged QoR regression** the upgrade introduced (not flow-knob recoverable without RTL/SDC — see each DECISIONS.md): vortex-nangate45/sky130hd (yosys-0.64 FF-fallback cell growth +25–28 %), cnn-nangate45 (new-RTLMP macro placement, Fmax −49 %), coralnpu-sky130hd / vortex-sky130hd (marginal setup), litepci-nangate45 (pre-existing unconstrained forwarded clock).

In progress / not yet re-validated on the upgraded tools at last checkpoint: cnn-asap7/sky130hd, bp_uno (all 3), snitch_cluster (asap7/nangate45), litepci-sky130hd (GRT-congestion retune). sky130hd NVDLA partition_c still does not finish (GP plateau).

**2026-07 re-validation on the newer pin (bazel-orfs `6c1bbca` / OpenROAD `b65c274c` / OpenSTA `8572175a`):** the above "in progress" designs were re-validated and closed on the newer OpenROAD (this pin also **resolves the snitch_cluster-nangate45 global-placement hang** that 553c1c3 had):
- **PASS** (QoR within tolerance): snitch_cluster (asap7 +253 ps / nangate45 +5801 ps), bp_uno (asap7 −510 ps, nangate45 +576 ps, sky130hd +3489 ps), litepci-asap7 (+927 ps) and litepci-nangate45 (+4266 ps at a relaxed 10 ns probe clock — tighten via `period_min` follow-up).
- **Finishes but flagged**: cnn-asap7 (macro-placement Fmax −49 %, now *finishes* via `SKIP_INCREMENTAL_REPAIR` instead of spinning in the non-converging new-resizer repair).
- **Fixes required** (see workaround table): `SKIP_INCREMENTAL_REPAIR` for cnn-asap7 + litepci-asap7/nangate45 (new-resizer repair non-convergence); litepci-nangate45 SDC clock-period sed-poisoning; and a `MODULE.bazel` yosys-slang tarball-checksum bump to unblock fresh/k8s fetches.
- **Still non-finishing** on this pin: litepci-sky130hd (GRT congestion), NVDLA partition_c-sky130hd (GP plateau). **partition_o-sky130hd _does_ finish** on b65c274c (verified 2026-07-15 on k8s): its detail route is extremely slow (~10 h) but converges cleanly to `_final` — the earlier "detail-route congestion" non-finishing claim was wrong (it was slow, not blocked; antenna repair converged 5391→23). The new resizer's `place_gp` runs two timing-driven `repair_design` passes, making 1.3M+ cell designs ~2–3× slower (snitch-nangate45 ~14 h end-to-end).

Use `tools/fetch_cache.sh` to pull cached `_final` results from the remote cache; designs in the local-only / not-finishing lists above aren't on it.

### Output Directories

Build artifacts go to `bazel-bin/designs/<platform>/<design>/`. Key outputs:
- `results/<platform>/<design>/base/6_final.{odb,v,sdc,spef}` — Final ODB and netlist (and `6_final.gds` when `GDS_ALLOW_EMPTY` is not suppressing GDS write)
- `results/<platform>/<design>/base/<N>_<stage>.{odb,sdc,...}` — Per-stage outputs (1_synth, 2_floorplan, 3_place, 4_cts, 5_1_grt, 5_2_route, 6_final)
- `reports/<platform>/<design>/base/` — QoR and OpenROAD-generated `.webp.png` heatmaps/placement images written by ORFS's own report stage
- `logs/<platform>/<design>/base/` — Per-stage logs

### FakeRAM

Designs with embedded memories use FakeRAM (LEF-only, no GDS). Controlled by `GDS_ALLOW_EMPTY = fakeram.*` set as a default in `defs.bzl`.

Every design's LEF/LIB is generated by `tools/bsg_fakeram` (VLSIDA fork — `https://github.com/VLSIDA/bsg_fakeram`, branch `asap7-area-calib-v2`). The fork carries local patches on top of upstream BSG: per-bit `write_granularity` end-to-end, calibrated asap7 area (`2.5×` periphery overhead + dynamic column mux for ~1.5:1 aspect, bitcell from Clark et al. 2016), the same analytical path for sky130hd (1.07×1.74 µm bitcell from OpenRAM), and the **`wd_in` LEF pin-direction fix (`c83ecb4`)**. nangate45 still uses CACTI directly. The fork README acknowledges both BSG and ABKGroup's FakeRAM2.0 as upstream sources.

> **`wd_in` LEF bug (fixed `c83ecb4`, submodule bumped in HighTide `044c02b9`):** before `c83ecb4`, `generate_lef.py` set the pin `DIRECTION` by physical die side, not pin function, so the upper half of every write-data bus (`*_wd_in[ceil(W/2)..W-1]`) was emitted as `DIRECTION OUTPUT` while Liberty correctly said `input`. yosys (uses Liberty) synthesized correctly, but OpenROAD PnR (uses LEF) shorted half of every write-data bus into one giant net → unroutable GRT-0116 congestion (first caught on cnn-sky130hd, net with 1964 iterms / 512 bogus drivers). Pre-existing since fork commit `0e1b3c00` (Oct 2025). **Any LEF generated before `c83ecb4` is electrically invalid** — regenerate via `tools/regenerate_sram.sh` and verify `grep 'DIRECTION OUTPUT' -B1` shows no `*_wd_in` pins.

Generation flow:
1. **One JSON cfg per (design, platform)** lives at `designs/src/<design>/dev/generated/fakeram_<platform>.cfg`. Lists the macro `srams` array with width / depth / banks / `no_wmask` / port spec.
2. **`tools/regenerate_sram.sh <design> <platform>`** runs `bsg_fakeram/scripts/run.py` on that cfg, then copies the resulting `.lef`/`.lib` into `designs/<platform>/<design>/sram/{lef,lib}/`. The intermediate `dev/generated/sram/<platform>/` tree is gitignored.
3. **`tools/diff_sram_size.sh <design> <platform>`** emits a markdown diff of new vs `git HEAD` sizes (area %, aspect ratios, flag on >25% area or >2× aspect change) for pre-commit review.
4. **`tools/reconstruct_cfg_from_lef.py <design> <platform>`** — for designs whose cfg was lost or drifted (Section B: `coralnpu`, `vortex`, `NyuziProcessor` had no usable cfg / stale names). Derives a standard-path cfg from the *committed* LEF macro set (the ground truth for what the RTL instantiates): width from `wd_in` pin count, depth from the macro-name dims disambiguated by width (handles both `WIDTHxDEPTH` and `DEPTHxWIDTH` naming and non-power-of-2 depths like `16x52`), ports from the name suffix, `write_granularity` from wmask/width.

Committed LEF/LIB lives at `designs/<platform>/<design>/sram/{lef,lib}/` for every design.

Sub-CACTI-sized memories: a few designs need sizes below CACTI's reach (very narrow words, depth ≤ 16, or under ~1 Kb). Those don't get LEF/LIB; instead a small behavioural Verilog stub is added to the RTL filegroup and yosys synthesises the array as flip-flops. Two scripts emit these stubs:
- `designs/src/NVDLA/dev/gen_ff_rams.py` → `dev/generated/sram_ff/fakeram_*_1r1w.v` for `(6,128)`, `(9,80)`, `(66,8)`, `(64,16)`, `(256,16)`, `(272,16)`. Included in the NVDLA `:rtl` filegroup.
- `designs/src/bp_processor/dev/gen_macros_v.py` → `designs/{asap7,nangate45}/bp_processor/macros.v`. Wraps `bsg_mem_1rw_sync_synth` / `bsg_mem_1rw_sync_mask_write_bit_synth`; sizes not in `LARGE_CONFIGS` (currently 32x66 and 8x174) fall through to a register-array branch.
- `designs/src/vortex/dev/VX_dp_ram_REPLACE.sv` — the 6 vortex macros bsg_fakeram cannot size on **all** target platforms (`192x16`/`193x16`/`85x16`/`87x16` depth 16 below nangate45 CACTI range; `560x4`/`654x4` depth 4 exceed asap7 analytical pin-routing) have their `g_fakeram` branches removed so those `(DATAW,SIZE)` configs fall through to the stub's existing behavioral reg-array path (FF on all 3 platforms — the stub is shared RTL). Hard macros kept: `128x64`/`21x256`/`21x64` (dp), `32x1024`/`512x64`/`128x256` (sp).

## Reporting cell counts

When reporting or comparing cell counts across designs or platforms, **exclude fill cells, tap cells, and antenna cells**. They are physical-only / manufacturing-rule cells, not part of the design's logic. Their counts vary wildly across platforms (sky130hd uses ~17× more tap cells than nangate45 due to a stricter max-tap-distance rule, and lower `CORE_UTILIZATION` inflates filler counts proportionally), so including them obscures real differences.

Use the per-class fields in `6_report.json` (e.g. `class:sequential_cell`, `class:multi_input_combinational_cell`, `class:inverter`, `class:clock_buffer`, `class:timing_repair_buffer`) — not the top-level `instance__count` — when comparing designs.

## Pushing clock frequency (and the io-feedthrough WNS trap)

When tightening a design's clock period to raise Fmax, **do not use `finish__timing__setup__ws` (reported WNS) as the limiter.** For LiteX/protocol/NVDLA designs (litedram, liteeth, litepci, floonoc, NVDLA, bp_uno) the worst setup path is often a pure input→output *combinational feedthrough* constrained only by `set_input_delay + set_output_delay = clk_io_pct*period`, so its slack is `~0.6*period` and shows a permanent huge "margin" no matter how tight the clock — it tracks the constraint, not silicon, and masks the real register-to-register path (some designs were reg2reg-*violated* at baseline while reported WNS stayed positive). `6_finish.rpt`'s setup section only prints the worst path per group (= this io path), so it can't reveal reg2reg slack either.

**Use `report_clock_min_period` instead** — the `period_min` field in `6_finish.rpt` is the achievable minimum period from the routed netlist and is reg2reg-dominated. ORFS synthesis optimizes *to the target clock*, so `period_min` keeps dropping as you tighten (litedram-asap7 floor fell 2373→1217→902 ps as the target tightened); iterate `clk_period = period_min * 1.10`, rebuild, re-read, until `set/period_min ≈ 1.10` (converged). Some designs hit a **routability** floor first (P&R fails before timing runs out — back off to the tightest that routes). Retrieve `period_min` for large designs via `k8s/run.sh --upload-artifacts` (PVC); their stage ODBs bust the Cloudflare cache cap.

## Known OpenROAD / yosys-slang bug workarounds

Designs in this repo carry workarounds for upstream tool bugs. Update this table whenever a new workaround lands, and remove rows once the upstream bug is fixed and the workaround can be reverted.

> **2026-06 toolchain upgrade (bazel-orfs `553c1c3` / OpenROAD `299f3015` / OpenSTA `8575070` / yosys `0.64`).** The following bugs are **fixed upstream** and their workarounds were removed where QoR allowed (see per-design DECISIONS.md): **CTS-0122** (in the pin — local patch dropped), **CTS-0105** ([#10177], removed on NyuziProcessor), **ODB-1200 / RSZ-0074** (resizer rewrite — removed on liteeth n45/sky, gemmini, litedram-asap7, NyuziProcessor, eyeriss, litepci a7/n45), **ODB-0445** (removed on NyuziProcessor). A few designs **keep** an ODB-1200-family skip not for the (fixed) crash but because the new resizer's `repair_timing` **does not converge** on them (litepci-sky: ~23 h GRT spin → `SKIP_INCREMENTAL_REPAIR`; asap7 liteeth/eyeriss kept for QoR). New issues introduced by the upgrade: the **OpenSTA `write_sdc` UTF-8 corruption** row below (NVDLA partition_m/c), and **MPL-0040 recurs** under the new RTLMP (eyeriss-asap7, fixed via util 40→30). Genuine, non-workaround QoR regressions from the new synth/place: vortex-n45/sky cell growth (+25–28 %), cnn macro-placement (Fmax −49 %) — flagged in their DECISIONS.md.

| Bug | Affected designs | Workaround | First commit | Issue |
|-----|------------------|------------|--------------|-------|
| **GRT-0183 heap underflow in `repair_antennas`** — `updateRouteGridsLayer` in `FastRoute.cpp` modified the routing grids vector in-place; when two jumpers were inserted on the same net at adjacent positions, their promoted endpoints merged into a single same-layer chain. `releaseNetResources` then decremented a `uint16_t` usage counter for an edge that was never incremented, wrapping to 65535. Triggered by sky130hd's high post-DRT antenna violation count (→ many diodes + jumpers, high probability of adjacent jumpers on the same net). | sky130hd NVDLA `partition_c` (baseline floorplan) | Local patch `patches/openroad-grt-0183-fix.patch` (upstream PR #10743, merged 2026-06-24). Remove once OR pin advances past 2026-06-24. | (this PR) | [OpenROAD#10156](https://github.com/The-OpenROAD-Project/OpenROAD/issues/10156), [#10273](https://github.com/The-OpenROAD-Project/OpenROAD/issues/10273) |
| **OpenSTA `write_sdc` instance-name corruption** (new in OpenROAD 299f3015) — expanding a wildcard `set_false_path -to [get_pin */SETN]` / `*/RESETN` writes corrupted (invalid-UTF-8) instance names into `1_synth.sdc`; Tcl 9's strict UTF-8 then hard-fails floorplan reading it (`error reading "fileN": invalid or incomplete multibyte`) | NVDLA `partition_m` (asap7/sky130hd), `partition_c` (asap7/nangate45) | Remove the two redundant `-to [get_pin */SETN\|/RESETN]` async-reset false-paths from `constraint.sdc` (reset sources are already `-from` false-pathed and the reset nets are `set_ideal_network`, so no real timed path is lost) | (this PR) | None filed yet |
| **bsg_fakeram `wd_in` LEF direction** — `generate_lef.py` set pin `DIRECTION` by physical die side, not function, so the upper half of every write-data bus was `OUTPUT` in LEF while Liberty said `input`; OpenROAD PnR shorted half of each `wd_in` bus → unroutable GRT-0116 (cnn-sky130hd net: 1964 iterms / 512 bogus drivers) | every fakeram design's pre-`c83ecb4` LEF (Section A + B); all prior `_final` passes invalid | Fork fix `c83ecb4` (submodule bumped `044c02b9`); regenerate all macros via `tools/regenerate_sram.sh` / `tools/reconstruct_cfg_from_lef.py`; vortex's 6 unsizable macros → FF-fallback | `c83ecb4` / `044c02b9` | Pre-existing in fork since `0e1b3c00` (Oct 2025); fixed in VLSIDA/bsg_fakeram |
| **bsg_fakeram snap-grid key mismatch** — cfg files set `snap_width_nm`/`snap_height_nm` (snake_case), but `class_process.py` only reads `snapWidth_nm`/`snapHeight_nm` (camelCase) and silently falls back to a 1 nm grid on a miss, so the intended platform site-grid snap never applies. Confirmed on committed asap7 LEF (`fakeram_64x256_1r1w`: `SIZE 107.137 BY 66.961` — divides evenly by 0.001 µm, not by the intended 0.190/1.400 µm grid) | **Every asap7 fakeram cfg in the repo** (NVDLA, cnn, coralnpu, NyuziProcessor, vortex, ternip, bp_processor, liteeth, litepci, eyeriss, snitch_cluster) — all use the wrong snake_case keys. nangate45/sky130hd cfgs are unaffected (correctly use camelCase). Suspected contributor to asap7 macro designs with unresolved timing/congestion (not yet confirmed) | Fixed so far only for gt2n `NVDLA` cfgs (this PR) — renamed keys, regenerated via `tools/regenerate_sram.sh`, confirmed macros now land on-grid. **asap7 cfgs across the suite not yet fixed or regenerated** — flagged for follow-up, no designs rebuilt against this yet | (this PR, gt2n only) | None filed yet |
| **CTS-0105** false skip — yosys hierarchical synthesis output port buffers arrive in ODB with `dbSourceType::TIMING` instead of `NETLIST`; CTS skips them as pre-existing clock buffers and leaves the clock net unbuffered | asap7 NyuziProcessor; asap7/nangate45/sky130hd `bp_quad`, `bp_uno` | `PRE_CTS_TCL` script resets affected buffers' `dbSourceType` from `TIMING` → `NETLIST` before CTS runs | `81b0ed4b` | [OpenROAD#10177](https://github.com/The-OpenROAD-Project/OpenROAD/issues/10177) |
| **MPL-0040** — `rtl_macro_placer` annealing failure on certain macro clusters | asap7 `bp_quad` (pipe_fma cluster), asap7 `cnn` | Hand-place fakeram macros in left-edge columns at FIRM status via `macros.tcl` so RTLMP only sees pre-placed macros; for cnn also drop `CORE_UTILIZATION` 65→60 | `09542e19` | [OpenROAD#9985](https://github.com/The-OpenROAD-Project/OpenROAD/issues/9985) |
| **ODB-1200** in `repair_timing` — `InsertBufferBeforeLoads` iterates a stale load list and aborts the flow with `Load pin '...' is not connected to net '...'`. Triggered by the resizer's `SplitLoadMove` step in CTS-time repair_timing | asap7 `liteeth`; sky130hd `NyuziProcessor`; asap7 `NyuziProcessor` (surfaced post-wd_in-fix); asap7 `bp_quad`; asap7 `gemmini` | Most designs: `SKIP_CTS_REPAIR_TIMING = 1` (skips the whole repair pass; route still does its own hold-repair). Gemmini: drop `split_load` from `SETUP_MOVE_SEQUENCE` (`"unbuffer,sizeup,swap,buffer,clone"`) — keeps the rest of repair_timing working (try this first). asap7 `NyuziProcessor`: split_load-drop did **not** clear it (ODB-1200 recurred via another move) → escalated to the full `SKIP_CTS_REPAIR_TIMING = 1` | `87829fdb` | [HighTide#75](https://github.com/VLSIDA/HighTide/issues/75) |
| **DPL-0036** in CTS-internal `detailed_placement` — `cts.tcl` builds its own `dpl_args` ignoring `DETAIL_PLACEMENT_ARGS`, so CTS-inserted leaf clock buffers can land too far from a legal stdcell row | asap7 `snitch_cluster` | `PRE_CTS_TCL` wraps `detailed_placement` to inject `-max_displacement {2000 400}` for the CTS call | `0af20020` | None (ORFS layering issue; no upstream issue filed yet) |
| **yosys-slang** phantom 1'x drivers on interface-array modport ports — extra driver wins at `opt_clean`, real driver silently dropped | asap7 `vortex` | Bumped `yosys-slang` 4e53d77 → eabdfd1 (vendored via `MODULE.bazel`) | `cb488bea` | [yosys-slang#304](https://github.com/povik/yosys-slang/issues/304) |
| **`repair_timing` non-convergence** — repair loop spends iterations on the same RTL-bounded endpoint without making progress. Not a bug per se, but a flow pathology when the clock target is too tight for the design | asap7 `snitch_cluster`, asap7 `litedram` | `SKIP_INCREMENTAL_REPAIR = 1` to skip post-GRT `repair_timing` | `39ca8670` | None |
| **ODB-0445** in post-GRT `repair_timing` — `[CRITICAL ODB-0445] No undo_updateField support for type dbTechNonDefaultRule`. The resizer's `Journal::undo` can't unroll changes to `dbTechNonDefaultRule` made during repair; crash trips during the slack-spiral retry on a single endpoint. Surfaces in dense placements that need NDR-using moves | asap7 `NyuziProcessor` (post util 55→65 PPA push) | `SKIP_INCREMENTAL_REPAIR = 1` — same workaround family as `repair_timing` non-convergence; detailed-route hold-repair still runs | (this PR) | None (no upstream issue filed yet) |
| **LiteX GENSDRPHY `input sdram_dq`** — `litedram/gen.py` declares the bidirectional SDR DQ bus as a plain `input` port (Lattice-platform convention; the tristate buffer lives at the IOB), but the same module instantiates 16 `TRELLIS_IO` cells that internally drive the port via OE-gated logic. yosys' `check -assert -mapped` sees the conflict and aborts synth on all 3 platforms | asap7/nangate45/sky130hd `litedram` | Patch `litedram_core.v` to make `sdram_dq` an `inout` port (`patch/litedram_core.patch`). Combined with `SYNTH_HIERARCHICAL = 1` so abc keeps each `TRELLIS_IO` as a hierarchy boundary | (this PR) | None (LiteX `gen.py:870` carries a `# FIXME: Allow other Vendors.` note) |
| **PSM-0069 power/ground net not reaching boundary row** — `Grid::makeVias` silently drops via candidates connecting a power/ground stripe to the boundary cell row when signal IO pins on an intermediate layer have their spacing-expanded obstruction overlapping that row's via area; the stripe terminates short of the boundary row, leaving all its cells with disconnected power/ground. No PDN-0110 fires for obstruction removal (PDN-0110 is for via geometry failures only); manifests as a PSM-0039 flood on boundary-row instances and PSM-0069 at `_final`. | sky130hd `floonoc` | Reduce `edge_margin` in `io.tcl` until the IO-pin obstruction clears the boundary-row via area; threshold: `edge_margin < core_yMin − row_height/2 − met_spacing`. See DECISIONS.md for platform-specific values. | `bbc7fd0` | None filed upstream |
| ~~**CTS-0122** false skip~~ **RESOLVED 2026-06** — `dbNet::getFirstOutput()` skipped the driver of clock nets sourced by a `clock: true` macro output. Fixed upstream ([#10549], `cd4f5041`); the OpenROAD `299f3015` pin is past it, so the local `patches/openroad-cts-0122-fix.patch` was **dropped**. litepci-asap7 went from WNS −883 ps (broken clock tree) to +944 ps. | sky130hd/nangate45/asap7 `litepci` | (removed — fix in pin) | (this PR) | [OpenROAD#10549](https://github.com/The-OpenROAD-Project/OpenROAD/pull/10549) (merged `cd4f5041`) |
| **New-resizer post-GRT `repair_timing` non-convergence on structurally-unfixable reg2reg** (OpenROAD b65c274c) — when the worst reg2reg path is structural and unrepairable (a macro-placement-bound path, or a LiteX forwarded-clock io-feedthrough), the post-GRT `repair_timing` never terminates: it keeps buffering while TNS decays asymptotically, and per-iteration incremental STA time grows past an hour, so the stage runs for many hours with no closure. Distinct from the older RTL-bounded `repair_timing` non-convergence row above — this one is the *new resizer* chewing on a path it cannot fix. | asap7 `cnn` (macro-bound, Fmax−49 %); asap7/nangate45 `litepci` (forwarded-clock WNS≈−898 ps) | `SKIP_INCREMENTAL_REPAIR = 1` — GRT then finishes in minutes and the design reaches `_final`. (litepci-asap7's BUILD.bazel had *described* this skip in a comment but never actually set the arg — now set.) The unfixable path remains (documented per-design), but the design finishes instead of spinning. | (this PR) | None filed yet |
| **SDC clock-period sed poisoning** — ORFS derives the ABC target clock period from the SDC with a naive sed (`variables.mk`: `s/^set\s+clk_period\s+(\S+)\|.*-period\s+(\S+)/…/`) that takes the **first** `-period <n>` or `set clk_period <n>` token in the file. A quoted example in a *comment* above the real clock line (e.g. a backtick-wrapped `` `-period 10000` ``) is captured verbatim — the trailing backtick then makes `echo <val> > clock_period.txt` an unterminated shell command-substitution → **make Error 2**, killing synth before floorplan. | nangate45 `litepci` (comment quoted a backtick `-period` example) | Keep any hyphen-period token and any backtick out of SDC comments that precede the real `set clk_period` line; put the real assignment first. Reworded `constraint.sdc`. | (this PR) | None (ORFS parsing fragility) |
| **Stale yosys-slang `slang-elab` tarball checksum** — GitHub regenerated the archive tarball for the OpenROAD-vendored yosys-slang submodule (commit `82effc8d`), changing its gzip and thus its sha256 (`d319a1f…` → `ea31b4a…`; same source content, verified byte-identical after extraction). The stale pin in the `openroad` `archive_override` `patch_cmds` breaks **every fresh bazel fetch** (k8s pods, fresh output_bases) at repo-mapping time; only output_bases that cached the old tarball keep building. | any fresh build (all designs, on k8s / new output_base) | Update the sha256 in `MODULE.bazel` (the mirrored `patch_cmds` for `openroad`) to the current value. If GitHub flips it again, re-fetch and re-pin. | (this PR) | GitHub archive-tarball checksum instability |

### Useful ORFS env vars for these workarounds

- **`PRE_CTS_TCL`** / **`PRE_GRT_TCL`** / etc — point at a Tcl script that runs before the named stage. Used for the CTS-0105 reset and DPL-0036 displacement injection.
- **`SETUP_MOVE_SEQUENCE`** — comma-separated list of moves passed to `repair_timing -sequence`. Default sequence is `unbuffer,sizeup,swap,buffer,clone,split_load`. Drop `split_load` to dodge ODB-1200 while keeping the rest of repair_timing active.
- **`SKIP_CTS_REPAIR_TIMING = 1`** — skip the entire `repair_timing_helper` call inside `cts.tcl`. Heavier hammer than dropping a single move; route's own hold-repair still runs.
- **`SKIP_INCREMENTAL_REPAIR = 1`** — skip post-GRT `repair_timing`. Use when the loop never converges (RTL-bounded critical paths).
- **`SKIP_LAST_GASP = 1`** — skip the final repair_timing pass.

These go into `arguments = { ... }` of `hightide_design()`.

## Shared Machine

- This is a shared multi-user machine. When checking process status (e.g., `ps aux | grep openroad`), always filter to the current user's processes or check for bazel sandbox paths (`external/bazel-orfs`) to avoid confusing other users' builds with ours.

## Bazel Cache

- **NEVER** run `bazel clean --expunge` or delete the entire disk cache (`~/.cache/bazel-disk-cache`). Synthesis takes hours and clearing the cache forces a full rebuild of all designs.
- To invalidate a single design's cached results, use targeted approaches:
  - Change an argument in the design's BUILD.bazel (forces re-run of affected stages)
  - Use `bazel build --strategy=<target>=local` to bypass cache for one target
- The remote cache (`--remote_cache` in `.bazelrc`) is shared and read-only by default. Never delete or corrupt it.
- If you suspect a stale cache, verify by checking the process count in bazel output: `N processwrapper-sandbox` means N actions actually ran; `N internal` means cached.

### Cloudflare 100 MB upload limit — build the biggest designs locally

The remote cache is self-hosted `bazel-remote` fronted by a **Cloudflare Tunnel** whose free tier caps request bodies at **100 MB**. ORFS emits multi-100-MB stage ODBs (`2_floorplan.odb`, `3_place.odb`) for the largest designs; even with `--remote_cache_compression` (zstd) the very biggest still exceed the ceiling, so their `_final` results **fail to upload and never get cached remotely** — every k8s run rebuilds them from scratch and re-fails the upload. Build these locally instead so they at least populate the local `~/.cache/bazel-disk-cache`:

- **`bp_quad`** (asap7, nangate45) — biggest design (560 macros, 64–160 Gi RAM, 14 h+); k8s-hostile.
- **`bp_uno`** (sky130hd) — 140 macros + 7.6 M cells; `6_final.odb` 2.9 GB. asap7/nangate45 `bp_uno` upload OK; sky130hd's coarser pitches inflate the routed netlist past the ceiling.
- **`NVDLA/partition_c`** (asap7, nangate45, sky130hd) — the named offender in `.bazelrc`. The other NVDLA partitions (a/m/o/p) stay under the ceiling with zstd and run fine on k8s.
- **`cnn`** (nangate45, sky130hd) — 65 macros each.

Everything else — including NVDLA partitions a/m/o/p and the smaller recovery designs (ternip, bp_uno, liteeth, litepci, coralnpu, vortex, NyuziProcessor, cnn-asap7) — stays on k8s via `./k8s/run.sh --branch fakeram <platform> <design>`.

**Keep this list current:** *remove* a design once all its cache objects are confirmed < 100 MB (it can go back to k8s); *add* a design the moment it fails to upload on k8s (the bazel log shows a cache-upload error / `413` / size-limit on a stage ODB). The list is a live record of which designs currently bust the Cloudflare ceiling, not a fixed set.
