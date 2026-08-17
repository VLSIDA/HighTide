# NVDLA Design Decisions

Per-platform notes for NVDLA `nv_small` (NVIDIA Deep Learning Accelerator), split into five partitions per the upstream `nv_small` build manifest: `a`, `c`, `m`, `o`, `p`.

| Partition | Description |
|---|---|
| `a` | Activation / convolution data path (was the largest SRAM consumer; now all SRAMs FF). |
| `c` | Configuration + post-processor; 2 SRAM macros. |
| `m` | Master controller / address generator. No SRAMs. |
| `o` | Output processor / pooling + scaling; 8 SRAM macros. |
| `p` | PDP (planar data processor); 4 SRAM macros. |

FakeRAM macros live at `designs/<platform>/NVDLA/sram/{lef,lib}/`; the per-partition filegroups in each platform's `BUILD.bazel` carry the macros each partition needs.

## Hermetic RTL sourcing (2026-07)

NVDLA's RTL (`vmod/`, 546 files) is the *output* of NVDLA's spec build: `tmake -build vmod` over the parameterized `nvdla/hw` `nv_small` source, with a pre-baked `NV_NVDLA_cfgrom.v` substituted. The retired `dev/setup.sh` did this by downloading and running Perl 5.10.1 + Python 2.7.18 + JDK11 + SystemC 2.3.0 — the deferred hard case.

**It is now a hermetic Bazel genrule** (`//designs/src/NVDLA:gen_vmod`). The legacy pins are *not* required — the vmod build reproduces **byte-for-byte** (all 546 files) with modern, Bazel-provided tools:

| Retired (setup.sh download) | gen_vmod uses |
|---|---|
| perl 5.10.1 | system perl + `dev/perl_lib/` (vendored pure-perl `YAML` + `XML::Simple`/`XML::SAX`) |
| python 2.7.18 | `rules_python` python3 (`$(PYTHON3)`) |
| JDK 11 (for `Ordt.jar`) | `rules_java` JDK (`$(JAVA)`) |
| SystemC 2.3.0 | not needed (cmod/sim only) |

- `@nvdla_hw_src` (`http_archive`, pinned `771f20cc`, nv_small) supplies the source; `gen_vmod` copies it to a writable tree, runs `tmake -build vmod` with `dev/tree.make` (tool paths made overridable → modern tools), substitutes the cfgrom, drops the `.vcp` cpp-intermediates, and emits the 546-file vmod (enumerated in `vmod_files.bzl`). Generated headers live under `bazel-out/…/vmod/{include,vlibs}`, so the partition BUILDs' `VERILOG_INCLUDE_DIRS` point there.
- **SRAM patching is the committed-override layer** (`macros.v` RAMDP/RAMPDP→FakeRAM bridge + `dev/generated/sram_ff/*.v` FF stubs), same pattern as bp_processor — unchanged by this migration; the generated rams instantiate `RAMDP_*`/`RAMPDP_*` which `macros.v` maps to `fakeram_*`.

Removed: the `dev/repo` submodule (`.gitmodules` now has **no design submodules** — NVDLA was the last), `dev/setup.sh`, and `dev/install/*` (the legacy toolchain downloads). Verified: `gen_vmod` output is byte-identical to the previously-committed `vmod/`; `:rtl` builds; partition_m + partition_a synth clean (the latter exercising the FakeRAM/FF SRAM layer).

## FakeRAM regeneration (2026-05-13)

- **Generator**: `bsg_fakeram` (VLSIDA fork @ `asap7-area-calib-v2`), invoked via `tools/regenerate_sram.sh NVDLA <platform>` per platform.
- **Cfg**: `designs/src/NVDLA/dev/generated/fakeram_{asap7,nangate45,sky130hd}.cfg` — 14 entries each, all `1r1w` with `no_wmask`.
- **Prior generator**: in-repo `designs/src/NVDLA/dev/gen_fakeram.py` (area_per_bit heuristic, now deleted).

### Macro vs FF fallback

The original `gen_fakeram.py:SRAM_SIZES` list had 20 (width, depth) pairs. Six become flip-flop register arrays instead of hard macros:

| (W, D) | Bits | Reason |
|---|---:|---|
| (6, 128) | 768 | sub-1 KB (below CACTI's reach on the non-asap7 platforms) |
| (9, 80) | 720 | sub-1 KB |
| (66, 8) | 528 | sub-1 KB |
| (64, 16) | 1024 | depth-16, CACTI fails on nangate45 / sky130hd |
| (256, 16) | 4096 | depth-16, CACTI fails on nangate45 / sky130hd |
| (272, 16) | 4352 | depth-16, CACTI fails on nangate45 / sky130hd |

The FF stubs are emitted by `designs/src/NVDLA/dev/gen_ff_rams.py` into `designs/src/NVDLA/dev/generated/sram_ff/fakeram_<W>x<D>_1r1w.v` and included in the `:rtl` filegroup. Pin names mirror bsg_fakeram's `1r1w` convention (`r0_*` / `w0_*`) so the existing `designs/src/NVDLA/macros.v` wrappers don't change.

### Per-partition filegroups (after regen)

| Partition | Macros | FF instances (via the .v stubs) |
|---|---|---|
| a | – | 256x16, 272x16 |
| c | 64x256, 11x128 | 64x16, 6x128, 66x8 |
| m | – | – |
| o | 18x128, 8x256, 4x256, 7x256, 66x64, 15x80, 22x60, 32x128 | 9x80 |
| p | 16x160, 65x160, 14x80, 66x80 | – |

## asap7

**Status**: partitions `a`, `m`, `o` cached on remote build cache; partition `c` finishing locally (local sweep `6_final`, 2026-05-16); partition `p` not yet finishing.

### 2026-06 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)
- **partition_a**: builds unchanged — WNS +344.8 ps on the 1500 ps clock, util 62.0 %, 62 350 logic cells. No change needed.
- **partition_o**: the new global router tipped util 45 into a GRT-0116 congestion failure at detailed route. Relaxed `CORE_UTILIZATION` 45→40 (flow knob): routes clean, WNS +74.3 ps, util 42.5 %, 241 685 logic cells, +die area only.
- **partition_m**: hit the new-OpenSTA `write_sdc` bug — expanding `set_false_path -to [get_pin */SETN|/RESETN]` emits corrupted (invalid-UTF8) instance names into `1_synth.sdc`, which Tcl 9 rejects at floorplan. Removed those two redundant async-set/reset false-paths (reset sources are already `-from` false-pathed and the reset nets are `set_ideal_network`) on **both asap7 and sky130hd**; the new flow then closes clean — asap7 WNS +503 ps @1500 ps (util 56.8 %, 19 667 cells), sky130hd WNS +3324 ps (util 58.1 %, 11 022 cells). Timing healthy; the dropped false-paths carried no real timed path.
- **partition_c** (asap7 + nangate45): same `write_sdc` SDC fix applied (the `*/SETN|/RESETN` removal). Both reach `_final` — asap7 WNS **−1245 → −183 ps** (improved; still setup-negative, util 30.6 %, 268 324 cells), nangate45 WNS +802 ps (util 30.8 %, 250 898 cells). No multibyte/floorplan failure after the fix. (sky130hd partition_c still does not finish — the documented GP plateau below.)

## nangate45

**Status**: partitions `a`, `m`, `o`, `p` all reach `_final`; partition `c` finishing locally.

### 2026-06 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)
- **partition_a / _o / _p**: build unchanged, all close clean — `a` WNS +1525 ps (util 42.7 %, 53 030 cells), `o` WNS +1125 ps (util 36.0 %, 189 268 cells, Fmax 1.58 — multi-clock), `p` WNS +896 ps (util 35.6 %, 67 284 cells). No GRT congestion on nangate45 (unlike asap7 partition_o).
- **partition_m**: same OpenSTA `write_sdc` workaround (removed the `*/SETN|/RESETN` async false-paths) — closes WNS +1838 ps, util 50.7 %, 13 053 cells. (asap7 `partition_p` also passes here: WNS +62.8 ps, util 46.8 %, 98 602 cells.)

## sky130hd

**Status**: partitions `a`, `m`, `o`, `p` cached on remote build cache; **partition `c` finishing** (clean `_final`, 0 DRC, 2026-07-02, see below).

### 2026-06 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)
- **partition_a / _o / _p**: build unchanged, all close clean — `a` WNS +4209 ps (util 48.5 %, 35 825 cells), `o` WNS +975 ps (util 23.8 %, 185 458 cells), `p` WNS +575 ps (util 31.1 %, 64 868 cells). No GRT congestion (unlike asap7 partition_o).
- **partition_m**: same OpenSTA `write_sdc` workaround as asap7 (removed the redundant `*/SETN|/RESETN` async false-paths) — closes at WNS +3324 ps, util 58.1 %, 11 022 cells.

### 2026-07 re-validation (bazel-orfs 6c1bbca / OpenROAD b65c274c)
- **partition_o**: **finishes** on the newer pin (k8s, verified 2026-07-15). Detail route is *very* slow on this pin — ~10 h wall (single 5_route action), with the post-route antenna-repair pass converging 5391→23 violations — but it reaches `_final` cleanly. An earlier upgrade note had flagged partition_o-sky130hd as a "detail-route congestion" non-finisher; that was **wrong** — it is slow, not blocked. (Fresh QoR not re-captured locally: its stage ODBs are large and a local re-run would repeat the ~10 h route; `results.html` carries the 26Q3 QoR for this row with a note.)

### partition_c: GP plateau fixed + GRT-0183 fixed + DRC clean (2026-07-02)
- **GP plateau** (overflow ~0.31, target 0.10): fixed by hand-placed macro grid via `MACRO_PLACEMENT_TCL` — 8 columns, alternating R0/MX rows, gap-x 900 µm, cold channel 300 µm (R0→MX), hot channel 550 µm (MX→R0), fakeram_11x128 aside in left corridor (`tools/gen_macro_grid.py`). Alternating R0/MX is load-bearing — an all-R0 uniform-spacing control build exhausted the 64-iteration DRT budget with residual violations while alternating converged cleanly. gap-x 900 µm is required at macro corners: `nv_ram_rws_16x64` (16-deep, below CACTI floor) has no fakeram LEF — yosys synthesizes all 16 instances as FF arrays, RTLMP packs them into inter-column gaps adjacent to their functionally related macro corners, and the router runs out of tracks where horizontal and vertical routing pressure converge.
- **GRT-0183** (`repair_antennas` heap underflow, triggered by sky130hd's high antenna count): fixed by `patches/openroad-grt-0183-fix.patch` (upstream PR #10743, merged 2026-06-24 — remove once OR pin advances past that date).
- **SDC fix**: replaced `set_false_path -to [get_pin */RESETN|/SETN]` (asap7 pin names, silent no-ops on sky130hd) with port-level `-from` false-paths; added `set_ideal_network [get_nets {nvdla_core_rstn}]`.
- WNS +0.03 ns, Fmax **66.80 MHz** (`period_min` 14.97 ns vs 15 ns), 0 DRC violations, `CORE_UTILIZATION` 25, `PLACE_DENSITY` 0.20, ~265 k logic cells, core 128.9 mm².

## gt2n

**Status**: finishing. Per-partition details and known issues below.

### Configuration
- **partition_a** (no macros, FF-array SRAMs): `CORE_UTILIZATION=80`, `PLACE_DENSITY=0.88`, `MAX_ROUTING_LAYER=M11`, `MIN_CLK_ROUTING_LAYER=M4`, `HOLD_SLACK_MARGIN=20`, `SYNTH_MEMORY_MAX_BITS=8192` (4352-bit FF instance trips the ORFS default 4096 cap). Clock: 895 ps (Fmax 1.12 GHz). Die area 4506 µm².
- **partition_c** (65 SRAM macro instances, 2 macro types: `64x256`/`11x128`): `DIE_AREA="0 0 855.792 716.928"`, `CORE_AREA="1.008 1.008 854.784 715.808"`, `MAX_ROUTING_LAYER=M11`, `MIN_CLK_ROUTING_LAYER=M6`, `MACRO_BLOCKAGE_HALO=0.5`. Clock: 1300 ps, achieved Fmax 635.80 MHz.
- **partition_m** (no SRAM macros): `CORE_UTILIZATION=82`, `PLACE_DENSITY=0.87`, `MAX_ROUTING_LAYER=M11`, `MIN_CLK_ROUTING_LAYER=M4`. Clock: 660 ps (Fmax 1.52 GHz). Die area 1334 µm².
- **partition_o** (17 SRAM macro instances, 8 macro types): `CORE_UTILIZATION=46`, `MAX_ROUTING_LAYER=M11`, `MIN_CLK_ROUTING_LAYER=M4`, `MACRO_PLACE_HALO="8 8"`, `HOLD_SLACK_MARGIN=40`. Multi-clock: `nvdla_core_clk` (2270 ps, Fmax 440 MHz) + `nvdla_falcon_clk` tracked at the NVIDIA reference core:falcon ratio (1.25). Die area 54218 µm².
- **partition_p** (6 SRAM macro instances, 4 macro types): `CORE_UTILIZATION=45`, `MAX_ROUTING_LAYER=M11`, `MIN_CLK_ROUTING_LAYER=M6`, `MACRO_PLACE_HALO="5 5"`, `MACRO_BLOCKAGE_HALO=0.5`, `HOLD_SLACK_MARGIN=50`. Clock: 1433 ps (Fmax 698 MHz). Die area 33257 µm².
- `TNS_END_PERCENT=100` on all five.

### Decisions
- **asap7 is not a reliable reference for gt2n targets**: gt2n's per-square sheet resistance is dramatically higher than asap7's even at layers with near-identical pitch — e.g. M4 (0.042µm gt2n vs 0.048µm asap7, only ~12.5% apart) is 3.506 Ω/□ on gt2n vs 0.433 Ω/□ on asap7, an 8.1x gap that pitch differences can't explain. This isn't a material story either — gt2n uses ruthenium at the lower layers specifically because it scales better than copper at nanoscale linewidths, so a real process should look relatively *better* here, not 8x worse. The more plausible explanation is that asap7, an older predictive/academic PDK, is simply optimistic on interconnect resistance relative to what a real advanced-node process delivers. Fmax/area achieved on asap7 for the same RTL should not be treated as a dependable target for gt2n.
- **FakeRAM cfg**: partitions c/o/p share `fakeram_gt2n.cfg` (14 SRAM macro configs).
- **partition_c**: uses a hand-placed 8×8 SRAM bank grid (`macro_placement.tcl`) and applies an inter-partition I/O delay credit post-CTS (`pre_grt.tcl`) to more realistically model the clock-network latency that boundary signals would see if the partitions were connected as one die.
- **partition_o / partition_p**: several inter-partition boundary signals are zero-logic passthroughs of primary inputs with no on-chip source register in the standalone per-partition build, so the blanket `set_input_delay` under-budgets their true minimum arrival. Both partitions add scoped `-min` overrides on those specific signals in `constraint.sdc`.

### Known issues / open questions
- **partition_o**: minor hold violations (8, worst −58.34 ps).
- **partition_c**: incremental hold repair at global routing did not converge within ~18h (run setup-only instead) — may close with more time.
