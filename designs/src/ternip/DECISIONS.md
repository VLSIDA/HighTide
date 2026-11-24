# ternip Design Decisions

Per-platform notes for the ternip SystemVerilog ternary matmul inference accelerator.

| Variant | Description |
|---|---|
| `ternip_core` | Single-issue accelerator with a vector register file and a 16-bit tile matmul (TMATMUL) datapath. |

FakeRAM macros live at `designs/<platform>/ternip/sram/{lef,lib}/`; the shared
memory wrapper is `designs/src/ternip/ternip_pipelined_mem_fakeram.v`.

## Memories restored (2026-11-24) — all QoR before this measured a memoryless design

**What was wrong.** Since `ae7666b1` (2026-05-13 15:06, `hightide.svh` D
1024→2560, TmatmulParallelism 64→256, VectorParallelism 1→8; later
NumVectorRegisters 4→8 in `7dd6b73f`), none of ternip's three
`ternip_pipelined_mem` instances matched a generate branch in the wrapper, and
the wrapper had no default branch. No storage was instantiated and every
memory's read data was undriven: 0 macros and 0 memory flops on every platform
(2,399 flops total, vs 606,208 memory bits). This is not the old 1024×16
import-buffer decision (`b1a0dfa4`, 08:43 the same morning, moved that one
16-deep buffer to flops for M4 DRC); that commit's wrapper still mapped the
other two memories to 10 × `fakeram_512x16`. The config bump six hours later
changed all three shapes and the wrapper was never updated, on any ternip
branch. The earlier notes below ("RTLMP places the 10 banked SRAMs", "the
array synthesizes as flops") were wrong from 2026-05-13 on.

| Instance | Shape (width × entries) | Bits | Old mapping | Now |
|---|---|---|---|---|
| `vector_registers` | 128 × 4096 | 512 Kb | none (deleted) | 8 × `fakeram_512x128`, depth-banked, one bank per vector register (addr = {select[2:0], offset[8:0]}) |
| `tmatmul` export | 128 × 320 | 40 Kb | none (deleted) | 1 × `fakeram_512x128`, addresses 0–319 |
| `tmatmul` import | 4096 × 10 | 40 Kb | none (deleted) | flip-flops: depth 10 is below fakeram's minimum and 4096-bit words exceed asap7 pin routing; `SYNTH_MEMORY_MAX_BITS` 16384→40960 |

The wrapper now ends in a `$error` default branch, so a future config change
fails elaboration instead of silently deleting memory. `fakeram_512x16` was
replaced by `fakeram_512x128` in all four cfgs and regenerated
(`tools/regenerate_sram.sh`): asap7 138.32 × 86.8 µm, nangate45 210.14 ×
235.2 µm, sky130hd 684.94 × 1115.2 µm (0.76 mm² each, ~6.9 mm² for 9),
gt2n 117.39 × 73.44 µm. Expect a much larger design than the 2,399-flop
numbers below, since logic downstream of the memories was likely pruned
too; every platform needs re-closing and its old QoR is void.

Re-close so far:
- **nangate45**: closes unchanged at util 70 / 1.86 ns — setup WS +0.034 ns,
  hold +0.027 ns, TNS 0; 71,708 flops, 9 macros, 197K comb cells; period_min
  1.83 ns (548 MHz, vs 1.49 ns on the memoryless design).
- **sky130hd — manual floorplan, utilization unchanged**: RTLMP at util 65
  packed the 9 macros 20 µm apart (sky130 fakeram pins sit on all four edges:
  N 67, S 128, W 37, E 36) and split the vector-register banks across the die
  → GRT-0116 on met1/met2. Lowering util was the wrong fix (it was briefly
  tried, `3e3a4fa1`, and reverted before it ran). `macros.tcl` now places banks
  0–3 + the export buffer in a top row (R0) and banks 4–7 in a bottom row (MX),
  all 128-pin S edges facing the middle band that holds the bank read mux;
  200 µm channels, 100 µm outer margins; `tapcell.tcl` adds a 30 µm row-cut
  halo per macro. Die 4400 × 3484 µm = the util-65 die's area (15.33 mm²),
  made wider so no S edges face each other; PLACE_DENSITY back to 0.70.
- **gt2n — manual floorplan at the util-80 area**: at util 80 the 9 macros
  are 63% of the core and RTLMP fails MPL-0003; the brief util 80 → 60
  workaround (`9d7053c6`) let RTLMP place them but scattered the banks (bank
  → read-mux max 321 µm, banks 0/1 and 3/5 with S edges 8 µm apart). Same
  two-row layout as sky130hd: die 630.9 × 196.7 µm (124,107 µm² = the util-80
  area; 3.2:1 because 5 macros must fit in a row), 8 µm channels, 40 µm
  middle band; bank → mux max 208 µm. PLACE_DENSITY back to 0.85.
- **asap7 — accepted baseline at the old 953 ps clock (2026-11-24, `0bd6b8e8`,
  knobs unchanged; PPA done separately)**: closes to `_final` with setup WS
  −102 ps, TNS −19.3 ns, hold +24 ps; 71,708 flops, 9 macros, 267K comb
  cells, die 231,505 µm² (published memoryless build: 3,677 µm²), 235 mW.
  System Fmax 0.948 GHz vs 1.17 GHz published (−19 %, matching nangate45's
  −18 %: the real memory paths and datapath are back). RTLMP's placement is
  reasonable here, unlike sky130hd: banks 0–3 down the left edge, 4–7 down
  the right, export buffer top-right, datapath in the central column between
  them, i.e. the bank-aware arrangement rotated 90°. For the PPA pass:
  ~1,160 ps (1.1 × the ~1,054 ps achieved) closes it as is.

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
| 45 | 0.55 | 4 4 | (per `constraint.sdc`) | RTLMP places the 10 banked SRAMs (true only until `ae7666b1`, 2026-05-13; see the restoration note at top); `macro_placement.tcl` removed when the regenerated 34×43 µm macros made the old hand-placement coords (sized for 90×45 µm macros) obsolete. |

- **2026-11 toolchain upgrade (bazel-orfs 805ffd68 / OpenROAD 687848dd / yosys 0.68, asap7 now TC corner)**: all three platforms close clean at the frequency-pushed clocks, no knob changes — asap7 WS +14 ps at the 953 ps clock (period_min 939 ps, 19 359 logic cells, +2.8 % vs 18 833 — within the 5 % gate; note the corner moved BC→TC, so closing at the same pushed clock on *slower* libs is a strict improvement), nangate45 WS +0.37 ns at 1.86 ns (period_min 1.49 ns), sky130hd WS +0.46 ns at 8.43 ns (period_min 7.97 ns). TNS 0 and zero DRC/slew/cap violations everywhere. **Known issue (pre-existing, also on main), corrected 2026-11-24:** none of the three memories matched a wrapper branch, so they had no storage at all, not flops (0 macros, 0 memory flops). Fixed by the memory restoration at the top of this file; these QoR numbers are void.

## gt2n

**Status**: finishing
**Last updated**: 2026-11-16 (first gt2n close, 2026-11 pin — bazel-orfs 805ffd68 / OpenROAD 687848dd / yosys 0.68)

### Configuration

| Util | Density | Halo | Clock (ps) | Notes |
|---:|---:|---:|---:|---|
| 80 | 0.85 | — | 850 | `MAX_ROUTING_LAYER M11`, `MIN_CLK_ROUTING_LAYER M4`, `SYNTH_MEMORY_MAX_BITS 16384`; `set_false_path -from rst_ni` |

### Decisions
- **2026-11-16 first gt2n port (NRP k8s, results under `2cc59c5`)**: ported from asap7 per the port-design skill. BSPDN frees the frontside routing tracks, so high utilization is the intended design point — started at util 80 / density 0.85 (asap7 runs 45) and it closed first try. QoR (grt_report — gt2n has no OpenRCX rules, so `_final_report` fails STA-1670 and global-route parasitics are the reporting basis): setup WS +269 ps at the 850 ps clock, **Fmax 1.72 GHz** (vs 1.06 GHz asap7 — a 2nm-vs-7nm datapoint, not a tuning delta), hold WS +17.7 ps, TNS 0, zero setup/hold/slew/cap/fanout violations. 1080 µm² core, ~41.4k instances. Clock scaled 953→850 ps as the initial guess and was already conservative; a frequency push (period_min ≈ 581 ps) is deferred to the post-release PPA pass.
- **0-macro caveat, corrected 2026-11-24**: the port replicated the other platforms' state, in which none of the three memories matched a wrapper branch and all three had no storage (not flops). Fixed suite-wide by the memory restoration at the top of this file; this port's QoR is void.

### Known issues / open questions
- Frequency push to ~640 ps (period_min 581 × 1.10) queued for the PPA pass.
