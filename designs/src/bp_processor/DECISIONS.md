# bp_processor Design Decisions

Per-platform notes for Black-Parrot, an open-source RISC-V multicore from the BSG group at UW.

| Variant | Description |
|---|---|
| `bp_uno` | Single-core BP (`e_bp_unicore_cfg`) — minimal config for first-bring-up. |
| `bp_quad` | Four-core multicore (`e_bp_multicore_4_cfg`) — exercises the on-chip mesh + LLC + coherency. |

FakeRAM macros live at `designs/<platform>/bp_processor/sram/{lef,lib}/`. The wrapper `designs/<platform>/bp_processor/macros.v` swaps `bsg_mem_*_synth` instances for hard macros above a 1024-bit threshold and lets the rest synthesize as FF arrays.

## Hermetic RTL sourcing (2026-07)

The RTL is sourced hermetically by Bazel — no `dev/repo` submodule, no committed `release/repo` vendored tree, no `dev/setup.sh` flist parse:

- **Three pinned `http_archive`s** replace the ~500K-line vendored `release/repo` copy: `@bp_processor_src` (BlackParrot `05ef10db`) + its two vendored submodules `@bp_basejump_stl_src` (`b7788905`) and `@bp_hardfloat_src` (`5b7d5fe2`). `bedrock` is **not** fetched — its only `flist.vcs` hits are BP-own `bp_*bedrock*.sv` files (in `@bp_processor_src`), not the `external/bedrock` submodule. The three share one injected build file (`bp_dep.BUILD.bazel`).
- **`srcs.bzl`** carries the curated `bp_top/flist.vcs` subset (285 files → `VERILOG_FILES`) mapped to archive labels, plus `BP_INCLUDE_DIRS_STR` (14 include dirs → `external/+_repo_rules+...`). `bsg_mem_*_synth` are dropped (macros.v FakeRAM wrappers); `stubs.v` carries the small FF memories bsg_fakeram can't size.
- `:rtl_data` stages the full archive HDL trees into the synth sandbox (`stage_data`) for `` `include `` resolution; yosys-slang reads the SystemVerilog directly (`SYNTH_HDL_FRONTEND=slang`).

**Verification**: `:rtl` builds and bp_uno-asap7 elaborates + synthesizes clean through yosys-slang (all FakeRAM macros resolved); the **asap7 `_final` netlist matches the `results.html` baseline exactly on logic** — seq **39641** identical, comb within 0.06 %, die/core/util/macros/ios identical — with P&R within tool noise (bufinv +2.1 %, WNS −510 → **+145 ps** better, Fmax +25 %). Removed the submodule, `setup.sh`, `release/repo`, and `release_srcs.bzl`; kept `dev/gen_macros_v.py` / `dev/patch_mem.py`, the `dev/generated/fakeram_*.cfg` + `sram/` macros, and the sky130hd macro-grid.

## FakeRAM regeneration (2026-05-13)

- **Generator**: `bsg_fakeram` (VLSIDA fork @ `asap7-area-calib-v2`, with `write_granularity: 1` enabled for per-bit write masks). Run via `tools/regenerate_sram.sh bp_processor <platform>`.
- **Cfg**: `designs/src/bp_processor/dev/generated/fakeram_{asap7,nangate45,sky130hd}.cfg` — 6 macros each, `1rw + per-bit wmask`.
- **Macros.v generator**: `designs/src/bp_processor/dev/gen_macros_v.py` produces `designs/{asap7,nangate45,sky130hd}/bp_processor/macros.v` with bsg_fakeram's port-index pin names (`rw0_clk`, `rw0_ce_in`, `rw0_we_in`, `rw0_wmask_in`, `rw0_addr_in`, `rw0_wd_in`, `rw0_rd_out`).
- **Prior generator**: in-repo `designs/src/bp_processor/dev/gen_fakeram.py` (area_per_bit heuristic + macros.v emission, now deleted).

### Macro vs FF fallback

The original 8-size LARGE_CONFIGS list shrinks to 6; two sizes become FF arrays via the `else begin : nz` branch of `macros.v`:

| (D, W) | Bits | Status | Reason |
|---|---:|---|---|
| 512x64 | 32 768 | macro | |
| 64x184 | 11 776 | macro | |
| 512x8 | 4 096 | macro | |
| 64x50 | 3 200 | macro | |
| **32x66** | 2 112 | **FF** | depth-32 fails CACTI on nangate45 (the +8-bit retry can't recover) |
| 32x48 | 1 536 | macro | |
| **8x174** | 1 392 | **FF** | depth-8 fails CACTI on nangate45 |
| 128x8 | 1 024 | macro | |

Per-bit write masking is necessary for the `bsg_mem_1rw_sync_mask_write_bit_synth` flavour — bp_processor passes `w_mask_i[width_p-1:0]` straight through to `rw0_wmask_in`. The bsg_fakeram fork patch (`write_granularity: 1`) is what makes that legal LEF/LIB/.v emission.

## sky130hd port — bp_uno (2026-05-26)

| Knob | Value | Notes |
|---|---|---|
| `DIE_AREA` / `CORE_AREA` | `0 0 8000 8000` / `20 20 7980 7980` | Fixed, not `CORE_UTILIZATION` — the auto-sized 5887 µm core can't host the macro grid (needs ~7600 µm y for 10 rows + channels). |
| `PLACE_DENSITY_LB_ADDON` | `0.10` | Std-cell utilization ends at 18.6% — plenty of room for routing. |
| `clk_period` | 36 ns | 3.6× nangate45's 9 ns, in line with the litedram nangate45→sky130hd ratio. Closes at +4.4 ns WNS. |
| `MACRO_PLACEMENT_TCL` | `macro_placement.tcl` (140 macros, R0, FIRM) | RTLMP's pin-edge-blind clustering of the 64 icache/dcache `data_mems[*]` collided their met2 escape lanes → unroutable congestion (`GRT-0116` at halo=60, then `GRT-0229` overflow saturation at halo=80). Same failure shape as cnn-sky130hd / NVDLA partition_c. |

### Macro grid regeneration

Dump the 140 macro instances from a freshly-floorplanned ODB, then run the grid generator:

```bash
bazel build //designs/sky130hd/bp_processor/bp_uno:bp_processor_floorplan
$OPENROAD -no_init tools/dump_macros.tcl >| \
    designs/src/bp_processor/dev/generated/bp_uno_sky130hd_macros.txt
python3 tools/gen_macro_grid.py \
    designs/src/bp_processor/dev/generated/bp_uno_sky130hd_macros.txt \
    designs/sky130hd/bp_processor/bp_uno/macro_placement.tcl \
    --gap-x 250 --chan 450
```

`--chan 450` mirrors NVDLA partition_c — gives every macro's bottom met2 pin edge a routing channel south of the row. `--gap-x 250` keeps adjacent macros' pin escape from colliding. The script sets every macro to R0 + FIRM at the end, so the post-source `rtl_macro_placer` leaves them alone.

### QoR (cached locally — see CLAUDE.md Cloudflare 100 MB note)

| Metric | Value |
|---|---|
| Setup WNS / TNS | +4.375 ns / 0 |
| Hold WNS / TNS | +0.129 ns / 0 |
| Route DRC | 0 |
| Sequential cells | 39 641 |
| Combinational cells | 248 260 |
| Inverters | 35 155 |
| Clock buffers | 8 538 |
| Timing-repair buffers | 28 111 |
| Total power | 0.294 W |
| Core utilization | 18.6 % |

`6_final.odb` is ~2.9 GB — far past the Cloudflare-tunnel 100 MB ceiling, so the remote cache reports `NOT CACHED`. Build locally to populate `~/.cache/bazel-disk-cache`; the local-build list in CLAUDE.md tracks this.

## 2026-06 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64) — bp_uno

- **nangate45**: clean pass, no change — WNS +1963 → **+1943 ps**, util 15.9 %, 439 607 logic
  cells (≈ baseline 439 722), Fmax 0.19 → 0.20 GHz. Workarounds kept.
- **asap7**: **flagged regression.** WNS +78 → −459 ps (Fmax 0.31 → 0.26, −16 %), 452 k cells
  (−2 %). Re-enabling repair (removing `SKIP_INCREMENTAL_REPAIR`) was tried and converged
  without the old hang, but gave the same −467 ps — the slowdown is netlist/placement-bound
  on the new RTLMP/router, not repair-fixable (same class as cnn-asap7). Original config
  (skip kept) restored; not recoverable via flow knobs without RTL/SDC changes.
- **sky130hd**: clean pass on the new tools — WNS **+4.14 ns** (≈ the +4.4 ns baseline), util
  18.6 %, 367 437 logic cells, 140 macros. 7.6 M-cell-class / local-only (over the Cloudflare
  ceiling); built + cached locally. Workarounds (MACRO_PLACEMENT_TCL hand-grid, repair skip) kept.

## 2026-07 re-validation (bazel-orfs 6c1bbca / OpenROAD b65c274c) — bp_uno

All three platforms **PASS** on the newer pin (built locally; the batch initially failed with a
wrong Bazel target — the macro names targets `bp_processor_gallery`, from `top="bp_processor"`,
not `bp_uno_gallery`). Unlike cnn/litepci, bp_uno's reg2reg is met, so the new resizer's
post-GRT repair converges normally — no `SKIP_INCREMENTAL_REPAIR` needed here beyond the
existing config.

- **asap7**: 451 474 logic cells (−0.1 %), WNS **−510 ps** (baseline was already −459; the small
  negative is the same netlist/placement-bound path noted for the 553c1c3 pin), Fmax 0.260 GHz
  (+0.1 %), power 271 mW.
- **nangate45**: 442 511 logic cells (+0.7 %), WNS **+576 ps** (met; base +1943), Fmax 0.212 GHz
  (+6.1 %), power 523 mW.
- **sky130hd**: 368 735 logic cells (+0.4 %), WNS **+3489 ps** (met; base +4144), Fmax 0.035 GHz
  (+15.1 %), power 488 mW. Detail route converged cleanly (1307 → 154 → 27 → 0 violations).

## gt2n — bp_uno (2026-09-25)

**Status**: finishing (not fully clean)
**Last updated**: 2026-09-25

### Configuration
- `CORE_UTILIZATION = 35` (`PLACE_DENSITY = 0.42`) — auto-sized via `CORE_UTILIZATION`, unlike the
  fixed `DIE_AREA` every other bp_uno port needed. RTLMP auto-placement handles the macros here with
  no hand-placed grid (unlike bp_uno-sky130hd / NVDLA partition_c-gt2n).
- `MAX_ROUTING_LAYER = M11`, `MIN_CLK_ROUTING_LAYER = M4` — `M6` (NVDLA partition_c's macro-heavy
  recommendation) was tried and made zero measurable difference; reverted to `M4`.
- Clock: `4628 ps` (Fmax 216.1 MHz, `period_min` 4620 ps)
- No `SKIP_INCREMENTAL_REPAIR` — unlike asap7/nangate45, gt2n needs incremental repair enabled to
  close (matches the snitch_cluster-gt2n finding); skipping it left 671 setup + 2329 hold violations.

### Decisions
- **2026-09-25**: initial gt2n port. Setup nearly closes (WNS -16.84 ps, 1 violation). Hold
  violations remained irrespective of loosening/tightening the clock period. `HOLD_SLACK_MARGIN`
  was tried and reduced hold violations but severely impacted setup timing (WNS to -572.83 ps);
  not used.

### Known issues / open questions
- Not fully clean: 1 setup violation (-16.84 ps), 17 hold violations (worst -9.06 ps). Root cause
  not isolated — further closure may need investigation beyond SDC/margin knobs.
