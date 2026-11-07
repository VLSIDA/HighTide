# ternip Design Decisions

Per-platform notes for the ternip SystemVerilog ternary matmul inference accelerator.

| Variant | Description |
|---|---|
| `ternip_core` | Single-issue accelerator with a vector register file and a 16-bit tile matmul (TMATMUL) datapath. |

FakeRAM macros live at `designs/<platform>/ternip/sram/{lef,lib}/`; the shared
memory wrapper is `designs/src/ternip/ternip_pipelined_mem_fakeram.v`.

## SRAM macro rename to platform-neutral `fakeram_*` (2026-10)

Renamed `fakeram7_512x16` → `fakeram_512x16` on all three platforms (same
suite-wide cleanup as snitch_cluster, PR #248): the `7` was asap7 naming carried
onto nangate45/sky130hd. In the same pass:

- The shared wrapper moved from `designs/asap7/ternip/ternip_pipelined_mem_fakeram7.v`
  to `designs/src/ternip/ternip_pipelined_mem_fakeram.v` (it was always
  platform-neutral; nangate45/sky130hd referenced it cross-platform).
- **asap7 snap-grid key fix**: the cfg used the buggy snake_case
  `snap_width_nm`/`snap_height_nm` keys (silently ignored → 1 nm grid); now
  camelCase, macro lands exactly on the 0.190/1.400 µm site grid
  (34.560×43.200 → 34.580×43.400, +0.06/+0.5 %).
- nangate45/sky130hd regenerated at identical sizes; internal PG-strap
  offsets shifted ~1.1 µm because the committed LEFs predated the current
  bsg_fakeram pin (`2db2c32`) — pins and size unchanged.

All three platforms' cached results invalidate and rebuild.

## FakeRAM regeneration (2026-05-13)

- **Generator**: `bsg_fakeram` (VLSIDA fork @ `asap7-area-calib-v2`), invoked via `tools/regenerate_sram.sh ternip asap7`.
- **Cfg**: `designs/src/ternip/dev/generated/fakeram_asap7.cfg` — 1 entry, `fakeram7_512x16` (16×512=8 Kb, 1rw, `no_wmask`).
- **Prior generator**: in-repo `designs/src/ternip/dev/gen_fakeram.py` (area_per_bit heuristic, now deleted).
- **Size delta**: `fakeram7_512x16` shrinks from 90.56 × 45.36 µm² (aspect 2.0:1, 4108 µm²) to **34.56 × 43.20 µm² (aspect 1.25:1, 1493 µm²)** — −64 % area. The bsg_fakeram analytical formula uses Clark et al.'s ASAP7 6T bitcell (0.029 µm²) with a 2.5× per-dim periphery overhead and dynamic column muxing.

## Active workarounds

None — ternip closes with RTLMP placement.

## asap7

**Status**: finishing
**Last updated**: 2026-06-04 (bazel-orfs 553c1c3 upgrade validation).

### Decisions
- **2026-06-04 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)**: all three platforms close clean, no change needed — asap7 WNS +808 → +837 ps (util 71.2 %, 18 833 cells), nangate45 +3454 → +3410 ps, sky130hd +9916 → +9286 ps (all huge positive margins; Fmax within ~7 %). No workarounds.
- **2026-05-28 `187957b5`**: bumped `dev/repo` to upstream `187957b5` — single commit, improves rowwise multioperand combinational operations in `rtl/fus/ternip_rowwise_operation.sv`. Closes #148.
- **2026-05-28 `b48037e2`**: bumped `dev/basejump_stl` to `b48037e2` (3 commits: rp_groups `.v` extensions, `bsg_fifo_1r1w_narrowed.sv` update, `bsg_reduce balanced_p` param). None touch files in `_BSG_FILES` — regenerated `dev/bsg/` is bit-identical, build is pure cache hit. Closes #149.

### Configuration

| Util | Density | Halo | Clock (ps) | Notes |
|---:|---:|---:|---:|---|
| 45 | 0.55 | 4 4 | (per `constraint.sdc`) | RTLMP places the 10 banked SRAMs; `macro_placement.tcl` removed when the regenerated 34×43 µm macros made the old hand-placement coords (sized for 90×45 µm macros) obsolete. |

- **2026-11 toolchain upgrade (bazel-orfs 805ffd68 / OpenROAD 687848dd / yosys 0.68, asap7 now TC corner)**: all three platforms close clean at the frequency-pushed clocks, no knob changes — asap7 WS +14 ps at the 953 ps clock (period_min 939 ps, 19 359 logic cells, +2.8 % vs 18 833 — within the 5 % gate; note the corner moved BC→TC, so closing at the same pushed clock on *slower* libs is a strict improvement), nangate45 WS +0.37 ns at 1.86 ns (period_min 1.49 ns), sky130hd WS +0.46 ns at 8.43 ns (period_min 7.97 ns). TNS 0 and zero DRC/slew/cap violations everywhere. **Known issue (pre-existing, also on main):** synthesis instantiates ZERO fakeram macros — `vector_registers` (128,4096) matches no generate branch in `ternip_pipelined_mem_fakeram.v`, so the committed sram/ LEF/LIBs are dead weight and the array synthesizes as flops. Needs a generate-branch fix or cfg/LEF cleanup as a separate change (not an upgrade regression).
