# liteeth Design Decisions

Per-platform notes for the `liteeth` design (Verilog top
`liteeth_udp_usp_gth_sgmii`) — the LiteEth Ethernet stack (LiteX/Python)
configured with a UDP endpoint over the Xilinx UltraScale+ GTH-SerDes
SGMII PHY.

## GTH transceiver moved off chip (2026-11-24) — all earlier QoR is void

**What was wrong.** The generated core instantiates a Xilinx GTHE4_CHANNEL (FPGA
hard IP). Since `b6e9cf94` (2025-11) it was replaced by
`libraries/xilinx/GTHE4_CHANNEL_DUMMY.v`, which has no serializer/deserializer:
its `TXDATA` was declared 5 bits (the core connects 16) and fed nothing, its
serial output just echoed the serial input, and with `LOOPBACK`/`RXPRBSSEL`
tied 0 by the generator its `RXDATA` was constant 0. Synthesis therefore pruned
the PCS (8b/10b encode/decode and PCS state machines): asap7 2,991 flops →
3,295 once fixed (+10 %; the UDP/IP/MAC/DHCP logic was always present). Found
by the 2026-11-24 memory/pruning audit; the macro count was unaffected because
the FIFO macros carry `(* keep *)`, though the RX CDC FIFO's write port was
tied to constants.

A second, older bug: LiteX instantiates `BUFG_GT` with only `DIV/I/O`. The
stand-in's unconnected `CE/CEMASK/CLR/CLRMASK` floated, synthesis held its
divider in reset, and the `DIV=1` half-rate TX/RX clocks were **constant 0** —
the PCS half-rate domains were never clocked in any build.

**Fix (`dev/gth_offchip.py`, run by the `gen_liteeth_core` genrule).** The GTH
instance is deleted and its PCS-side interface becomes 21 `gth_*` chip ports,
as in an ASIC with an external SerDes: 12 outputs (`gth_txdata[15:0]`,
`gth_txctrl0/1`, GT resets, PLL power-down, comma-align enables, forwarded
TX/RX user clocks) and 9 inputs (`gth_rxdata[15:0]`, `gth_rxctrl0/1`,
`gth_cplllock`, `gth_gtpowergood`, `gth_rx/txresetdone`, `gth_rx/txoutclk`).
Constant tie-offs and GTH outputs nothing reads are dropped; the serial pins
and `sgmii_refclk` (which only fed the GTH) leave the chip. The script also
ties `BUFG_GT`'s `CE/CEMASK/CLR/CLRMASK` to the Xilinx defaults, and
`BUFG_GT.v`'s divider now divides by `DIV+1` (it divided by `2*(DIV+1)`).
`GTHE4_CHANNEL_DUMMY.v` is no longer synthesized (kept for port directions).

**SDC (all platforms).** Clocks `gth_tx`/`gth_rx` on `gth_txoutclk`/
`gth_rxoutclk` and generated `/2` clocks `gth_tx_half`/`gth_rx_half` on the
`BUFG_GT_1`/`BUFG_GT_3` divider outputs, all asynchronous to `clk`. They are
constrained at standard gigabit rates (1000BASE-X, 1.25 Gbaud): `gth_period` =
8 ns (125 MHz) full rate, 16 ns (62.5 MHz) half rate, on every platform and
independent of the system clock (maintainer's call, 2026-11-24; an earlier
draft used the system period as a stress test). RX data/ctrl inputs are timed against `gth_rx_half`, TX
data/ctrl outputs against `gth_tx_half`; resets, comma-align and status ports
are false-pathed. Checked on asap7 at floorplan: 0 unclocked registers, all
four GTH clock groups time real paths; the only unconstrained endpoints are
those false paths, the forwarded user-clock outputs, and `sys_reset`.

Every platform's earlier liteeth QoR, including the 2026-11 bazeltuner result
(asap7 900 ps / util 45 / density 0.55), measured the pruned design and must be
re-established.

**Accepted baseline (2026-11-24, `abd15446`, knobs unchanged).** These closes
are the new liteeth baseline, including the timing loss; PPA is being done
separately. Use the per-clock `finish__timing__fmax__clock:clk` — the headline
`finish__timing__fmax` now reports the fastest of the five clocks (a GTH clock)
and overstates liteeth about 2×.

| platform | flops | sys-clock Fmax | setup WS | hold WS | vs published (webpage) |
|---|---:|---:|---:|---:|---|
| asap7 (810 ps) | 3,295 | **1.252 GHz** | +11.6 ps (TNS 0) | −16 ps | 1.09 → 1.25 GHz (+15 %): 2026-11-25 PPA scout config (below) on the manual floorplan. At 900 ps before the scout: 1.088 GHz / −19 ps (TNS −49 ps) / hold −122 ps; manual floorplan (`18e270d4`): die 175,046 → 96,110 µm² (−45 %; published 206,690), repair buffers 954 → 771, power 0.0357 → 0.0343 W. Worst path is now `core_ip_rx_depacketizer_header[79]` → the RX CDC FIFO `u_storage_64w64d_1` (the 575 ps wire is gone). (RTLMP util 0.45: 1.051 GHz / −51 ps / hold −216 ps) |
| nangate45 (1.66 ns) | 3,295 | 0.689 GHz | +0.21 ns | +0.016 ns | 0.68 → 0.69 GHz; manual floorplan (`18e270d4`): die 551,938 → 473,221 µm² (−14 %), power 0.124 → 0.114 W, repair buffers 873 → 789, hold now clean. (RTLMP at util 0.60: 0.673 GHz, hold −0.027 ns) |
| sky130hd (10 ns) | 3,295 | 0.138 GHz | +2.77 ns | −0.016 ns | 0.10 → 0.14 GHz (+38 %); manual floorplan (`5c58ca05`): die 11.09 → 7.86 mm² (−29 %; published 9.58 mm²), repair buffers 1,017 → 856, power unchanged (0.069 W). (RTLMP at util 0.45: 0.121 GHz, +1.57 ns, hold +0.13 ns) |
| gt2n (1450 ps, GRT parasitics) | 3,295 | 0.731 GHz | +82 ps | +0.01 ps | vs `c352728` (no webpage build): 697 → 731 MHz (+4.9 %); manual macros.tcl, so placement unchanged. Gigabit PHY clocks (`91727fe0`); the stress-clock run was 0.722 GHz / +65 ps |

Starting points for the PPA pass:
- asap7 worst path: `udpcore_tx_fifo_consume[3]` → `u_storage_64w1024d_5/r0_addr_in[3]`,
  575 ps of it one buffered wire (logic cluster bottom-left, that FIFO top-left)
  plus ~140 ps of clock skew (the macro's clock arrives earlier than the
  register tree's). Macro setup is 50 ps; splitting the FIFOs into smaller banks
  would not fix it (it adds periphery area and a read mux, and the address bus
  still fans out to every bank). A floorplan keeping the logic next to its
  FIFOs, and balancing the macro clock pins, are the levers; relaxing the
  clock to ~1,080 ps (1.1 × the 983 ps achieved) closes it as is.
- asap7 manual floorplan — DONE 2026-11-24 (`designs/asap7/liteeth/macros.tcl`),
  adapted from the bt-study-fp sweep agent's layout: the two 64w1024d FIFOs
  stacked with a 70 µm logic band between, north edges (clk/ce/we + 63
  rd_out) facing the band (bottom R0, top MX), the three 64w64d FIFOs in a row
  inside the band at the left; side margins 10 µm (address pins, where the
  critical path ends, sit on the W/E edges). Die 255.0 × 376.9 µm = util 0.82
  incl. macros (was RTLMP at util 0.45, core 0.173 mm²).
- asap7 PPA on the manual floorplan — 2026-11-25 scout wave (bazeltuner, 41
  one-parameter trials + reference at global route, then stepwise
  combinations, then `_final`). With the macros fixed the placement-seed noise
  band is 1.9 % of PPA (fmax / (core area × energy)); under RTLMP the same
  design had a 10 % floorplan band and most single-parameter verdicts were
  macro-placement luck. Adopted: **clock 900 → 810 ps, `SYNTH_HIERARCHICAL=1`,
  `SKIP_CTS_REPAIR_TIMING` and `SKIP_INCREMENTAL_REPAIR` removed,
  `PLACE_DENSITY` 0.55 → 0.65.** `_final`, same die (core 94,750 µm²):

  | | before (900 ps) | after (810 ps) |
  |---|---:|---:|
  | system-clock Fmax | 1.088 GHz | **1.252 GHz (+15.1 %)** |
  | setup WS / TNS | −19 ps / −49 ps | **+11.6 ps / 0** |
  | hold WS / violations | −122 ps / 217 | −16 ps / 20 |
  | power | 34.3 mW | 37.8 mW (energy per cycle 30.9 → 30.6 pJ) |
  | std cells | 25,768 | 27,156 (+5.4 %) |
  | DRC / antenna | 0 / 0 | 0 / 0 |

  Each of the three main changes is needed: at global route, repair on alone
  is +6.5 % PPA, + clock 810 is +9.7 %, + hierarchical synthesis is +17.7 %;
  removing any one from the set costs 4–9 %. Density 0.65 / 0.75 is within
  the noise band at global route, but at `_final` the 0.55 variant of the same
  config missed setup (1.168 GHz, WS −46 ps), so 0.65 is the committed value.
  The remaining hold violations are the system-clock IO → FIFO-macro paths
  noted above. Tried and dropped: `GPL_KEEP_OVERFLOW=0.2` (+5 % alone, −3 %
  in combination), clock 760 ps (no better than 810), `ABC_AREA=1` (−2.7 %),
  density 0.45 (−2.5 %), `CTS_CLUSTER_SIZE=10` (−5 %), relaxing the clock
  (−5 % at 990 ps); `GPL_TIMING_DRIVEN=0` is −60 %.
- nangate45 manual floorplan — DONE 2026-11-24: the two 64w1024d FIFOs side by
  side along the bottom (MX, 96-pin S edges up), the three 64w64d FIFOs along
  the top (R0), 84 µm logic band; 40 µm channels, 20 µm margins. Die 624.9 ×
  757.2 µm at util 0.70 (core 0.547 → 0.473 mm²).
- sky130hd manual floorplan — DONE 2026-11-24 (`designs/sky130hd/liteeth/macros.tcl`,
  `tapcell.tcl`): the two 64w1024d buffers along the bottom (MX, 96-pin S edges
  up), the three 64w64d FIFOs centered along the top (R0, S edges down), a 365 µm
  logic band between, 150 µm channels, 100 µm outer margins, 30 µm row-cut halo;
  die 2678.5 × 2935.9 µm at util 0.65 (core 7.86 mm², −29 %), PLACE_DENSITY
  0.65. Original note: sky130hd wants a manual floorplan at higher utilization (maintainer,
  2026-11-24). The core is 11.06 mm² for 4.83 mm² of macros (2 ×
  `fakeram_1rw1r_64w1024d` 1164 × 1896 µm + 3 × `64w64d` 291 × 476 µm) and
  0.28 mm² of std cells, i.e. 54 % empty: RTLMP stacks the small FIFOs down
  the left edge, squeezes the logic into a strip beside them, and leaves the
  top-right empty. Sketch: util ~65–70 % (core ~7.3–7.9 mm², −30 %), the two
  large FIFOs side by side along one edge, the three CDC FIFOs on the
  opposite edge, logic in the band between; sky130 fakeram pins sit on all
  four edges, so keep ≥100–200 µm channels and a row-cut halo (see
  ternip-sky130hd's `macros.tcl`/`tapcell.tcl`). The same idea likely helps
  nangate45 and asap7.
- RTLMP's placement got worse on both platforms after the change (nangate45:
  logic squeezed into a thin channel between the two large FIFOs, top-left
  quadrant empty, +28 % repair buffers).
- Hold violations are on system-clock IO into FIFO macros (`udp0_sink_last` on
  nangate45; −315 ps already on the published asap7 build): ideal-clock input
  delays against propagated macro clocks.

## Hermetic RTL generation (2026-07, gallery-style)

`liteeth_udp_usp_gth_sgmii.v` is generated hermetically by Bazel, not a
checked-in vendored file regenerated by a `dev/setup.sh` venv + submodule.
It **reuses the shared LiteX toolchain** established for litedram (`@migen_src`,
`@litex_src`, and the `pip_litex` hub) and adds two design-specific archives:
`@liteeth_src` (pinned at `ef5f9ee0` — the SHA `setup.sh` pip-installed, i.e.
the package `import liteeth` actually resolved to, **not** the stale `dev/repo`
submodule gitlink `883f3a4b`) and `@liteiclink_src` (`ef9c2950`, required by the
`USP_GTH_1000BASEX` PHY's `GTHChannelPLL`). The `:liteeth_gen` py_binary +
`:gen_liteeth_core` genrule replace `dev/setup.sh`/`gen.sh` — no venv, no
submodule.

- **Recovered config**: the generator config was previously an *uncommitted*
  upstream example (`liteeth/examples/udp_usp_gth_sgmii.yml`). It is now
  committed as `designs/src/liteeth/liteeth_udp_usp_gth_sgmii.yml` so the RTL is
  reproducible without an external file.
- **Reproducibility**: same treatment as litedram — `PYTHONHASHSEED=0` +
  `sed`-normalized build-timestamp header lines → byte-reproducible output.
- **The ASIC-adaptation patch** (`patches/liteeth_udp_usp_gth_sgmii.patch`)
  renames the module `liteeth_core → liteeth_udp_usp_gth_sgmii`, comments out
  `$readmemh` ROM inits, and swaps the real `GTHE4_CHANNEL` transceiver for the
  `GTHE4_CHANNEL_DUMMY` stub. It is applied declaratively in the genrule. It
  applies cleanly to freshly-generated (litex `a25eeec`) RTL even though the old
  committed core's header named litex `4a114b30` — the patched regions are
  stable across those litex revisions.
- `libraries/xilinx/*.v` (incl. `GTHE4_CHANNEL_DUMMY`), `macros.v`, and the
  `dev/generated/fakeram_*.cfg` FakeRAM configs are HighTide-authored and stay
  checked in. Consumers still reference the stable `:liteeth_rtl` label.

This is the most complex liteeth variant: UDP streaming protocol + a high-speed serial PHY whose Xilinx UltraScale+ GTH transceiver brings in the most logic, and the one that exercises the most OpenROAD corner cases. It is the sole liteeth design kept in HighTide as of 2026-05-12 — the other five variants (`mac_axi_mii`, `mac_wb_mii`, `udp_raw_rgmii`, `udp_stream_rgmii`, `udp_stream_sgmii`) were removed when the suite was simplified.

| Verilog top                 | Protocol | PHY                          |
|---|---|---|
| `liteeth_udp_usp_gth_sgmii` | UDP      | Xilinx UltraScale+ GTH SGMII |

FakeRAM macros live at `designs/<platform>/liteeth/sram/{lef,lib}/`.

## FakeRAM regeneration (2026-05-13)

- **Generator**: `bsg_fakeram` (VLSIDA fork @ `asap7-area-calib-v2`), via `tools/regenerate_sram.sh liteeth <platform>`.
- **Cfg**: `designs/src/liteeth/dev/generated/fakeram_{asap7,nangate45,sky130hd}.cfg` — 2 macros each, `1rw1r` (1 rw + 1 read-only), `no_wmask`.
- **Prior generator**: OpenFakeRAM (LEFs marked `# Generated by OpenFakeRAM`) on all three platforms.
- **Size delta**: asap7 macros grow ~5× (the prior OpenFakeRAM LEFs were unrealistically dense for 7nm); nangate45 / sky130hd within 1–2 % of CACTI's previous outputs. `macros.v` at `designs/src/liteeth/macros.v` already uses bsg_fakeram's `rw0_*` / `r0_*` pin names, so no RTL update was needed.

## Active workarounds

- **ODB-1200 / RSZ-0074** in `repair_timing` — the underlying OpenROAD resizer bug
  (InsertBufferBeforeLoads / SplitLoadMove) is **fixed** as of the bazel-orfs 553c1c3 /
  OpenROAD 299f3015 upgrade (2026-06-04).
  - **nangate45 / sky130hd**: `SKIP_INCREMENTAL_REPAIR` **removed** — post-GRT repair now
    runs without crashing and QoR is unchanged.
  - **asap7**: `SKIP_CTS_REPAIR_TIMING` + `SKIP_INCREMENTAL_REPAIR` **removed 2026-11-25**.
    They had been kept because repair_timing over-buffered the old (GTH-stub, RTLMP) design
    (cells +37%, buf/inv ×3.3) for only a marginal close. On the GTH-off-chip netlist with
    the manual floorplan, repair on is +6.5 % PPA alone and, with the 810 ps clock and
    hierarchical synthesis, closes setup at 1.252 GHz for +5.4 % cells. See
    [HighTide#75](https://github.com/VLSIDA/HighTide/issues/75).

## asap7


- **bazeltuner TPE campaign — 900 ps / util 45 / density 0.55 / 4 µm RTLMP
  channels (2026-11-19)**: 47-trial TPE (4×12, fmax objective, spec
  `suites/hightide/specs/liteeth_asap7.json`; baseline seed skipped — the
  1022 ps clock is off the 850–1250/50 grid) replacing the post-migration
  fallback 1022/38/0.30. Winner verified at final: fmax 1.134 GHz
  (period_min 882 ps), WS +18 ps / TNS 0, core 172 777 µm², 33.4 mW —
  **dominates the baseline on every axis** (0.978 GHz / WS −0.3 ps /
  204 652 µm² / 33.4 mW): +15.9 % Fmax, −15.6 % area, equal power.
  Tight 4 µm channels won decisively (12/20 µm consistently slower), and
  density 0.55 — abandoned in 2026-05 to RSZ-0074 routing failures — is
  routable again on the 2026-11 pin with them. Committed; both ODB-1200
  family skips retained.

**Status**: finishing
**Last updated**: 2026-11-16 (2026-11 pin validation)

- **2026-11-16: 2026-11 pin validation + one-off NRP DRT runtime anomaly.** The
  first NRP run of this pin sat **47 h inside `5_2_route`** with openroad at
  ~89 % CPU (42 CPU-hours). (The stage log read 0 bytes at the time, but that
  is NOT evidence of a hang — verified the same day that the ORFS
  `run_command.py` wrapper buffers the stage log until the stage completes, so
  an empty log mid-stage is normal.) Killed on elapsed-time grounds alone: a
  local rebuild of the identical action (same commit, same cached inputs,
  ~24 threads vs the pod's 4) **closed DRT in 4m40s / 3 iterations / 0 antenna
  violations**, so even at 4 CPUs the pod should have finished in well under an
  hour. Not reproduced; no upstream issue filed (no stack captured;
  environment- or thread-count-sensitive, possibly nondeterministic). If it
  recurs, grab `gdb -p <pid> -batch -ex "thread apply all bt"` twice 60 s apart
  inside the pod before killing. QoR (local, TC
  corner): period_min 1022 ps (Fmax 0.98 vs 1.09 BC baseline, −10 % — inside
  the accepted corner switch), setup WS −0.3 ps, power 33.4 mW. Reported hold
  WS **−336 ps is spurious**: the worst min path is the `sys_reset` *input
  port* → reset-synchronizer flop, i.e. a `set_input_delay` hold check on an
  async-style reset input (IO-constraint artifact family, like the setup
  feedthrough trap) — reg2reg hold is clean. Cache seeded from the local build
  (backfill 31 blobs / 21.7 GB); NRP job resubmitted as a replay to publish.

### Configuration

| Util | Density | Halo | Clock (ps) | Notes |
|---:|---:|---:|---:|---|
| 50 | 0.55 | — | 1000 | `SKIP_CTS_REPAIR_TIMING=1` (ODB-1200); area-tuned 2026-05-11 |

### Decisions
- **2026-04-30 `c8d96617`**: hit ODB-1200 in CTS repair_timing once the OpenROAD pin moved from `5f1bd87f` to `578be38a` (HighTide #103). Same bug class that previously affected `liteeth_udp_stream_sgmii` (PR #76). Added `SKIP_CTS_REPAIR_TIMING=1`.
- **2026-05-11 PPA area sweep**: UTIL 35→50 / DENSITY 0.30→0.55. Die area 41,896 → 29,439 µm² (**−30 %**). UTIL=55 fails MPL-0003 (macros + default halo cannot tile in the smaller core).
- **2026-06-04 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)**: the new synth/place produces a ~128 ps slower critical path on the 920 ps clock, so at the prior util 43 the design closed at WNS −29.9 ps (timing miss). Relaxed `CORE_UTILIZATION` 43→38 (a flow knob, no SDC/RTL change): recovers WNS to **+111.7 ps** (≥ the pre-upgrade +98 ps), Fmax 1.22→1.24 GHz, cells +0.4 %, instance area +2.1 %, power −3 %. Cost is die area +13 % (util-driven whitespace only). Kept `SKIP_CTS_REPAIR_TIMING` + `SKIP_INCREMENTAL_REPAIR` (see Active workarounds — repair over-buffers here).

- **2026-11 toolchain upgrade (bazel-orfs 805ffd68 / OpenROAD 687848dd / yosys 0.68, asap7 BC→TC corner)**: slang is now the default HDL frontend — three source fixes needed (dead same-name wrapper modules in macros.v deleted, GTPE2 dummy param name, net-initializer strip in the genrule sed; commit be634774). Closes at the pushed 1022 ps clock with WS −0.31 ps (period_min 1022.31 ps — i.e. dead-on the old BC-corner push target while now timing on the *slower* TC libs; asap7 timing advisory this upgrade, constraints to be re-derived). 18 032 logic cells, zero DRC/slew/cap violations.

## nangate45

**Status**: finishing
**Last updated**: `8ec5a224` (2026-05-11 PPA area sweep)

### Configuration

| Util | Density | Halo | Clock (ns) | Notes |
|---:|---:|---:|---:|---|
| 60 | 0.65 | — | 10 | `SYNTH_HIERARCHICAL=1`; area-tuned 2026-05-11 |

### Decisions
- nangate45 closes without the ODB-1200 workaround that asap7 needs — the bug is sensitive to the specific resizer-state interaction triggered by asap7's smaller cells.
- **2026-05-11 PPA area sweep**: UTIL 45→60 / DENSITY 0.40→0.65. Die area 746,271 → 560,103 µm² (**−25 %**). This was the headline single-variant win on nangate45.
- **2026-06-04 toolchain upgrade**: removed `SKIP_INCREMENTAL_REPAIR` (RSZ-0074 fixed in OpenROAD 299f3015). QoR essentially unchanged — WNS +5950 ps (relaxed 10 ns clock, unchanged), 17950 logic cells (−2 %), die −0.1 %.

- **2026-11 toolchain upgrade (TC n/a — single corner)**: passes unchanged — WS +0.12 ns at the pushed 1.66 ns clock (period_min 1.54 ns), 18 110 logic cells (+0.9 %), zero violations.

## sky130hd

**Status**: finishing
**Last updated**: `8ec5a224` (2026-05-11 PPA area sweep)

### Configuration

| Util | Density | Halo | Clock (ns) | Notes |
|---:|---:|---:|---:|---|
| 52 | 0.57 | 30 30 | 10 | area-tuned 2026-05-11 |

### Decisions
- sky130hd halo is 30×30 — large enough to keep std cells out of the macro shadow given sky130hd's wide cells.
- ODB-1200 doesn't trigger on sky130hd, same as nangate45.
- **2026-05-11 PPA area sweep**: UTIL 50→52 / DENSITY 0.40→0.57. Die area 3,864,920 → 3,716,410 µm² (−4 %). The baseline at UTIL=50 already had 50 max-slew + 4 max-cap DRV violations; UTIL=52 improves both (46/0). UTIL=55 fails global-route congestion.
- **2026-06-04 toolchain upgrade**: removed `SKIP_INCREMENTAL_REPAIR` (RSZ-0074 fixed in OpenROAD 299f3015). Closes with large margin (WNS +731 ps), instance area +1.4 %, die +0.02 % — within tolerance.
- **2026-11 toolchain upgrade**: the new GRT tips util 52 into GRT-0116 congestion (same pattern as sha3/coralnpu on sky130hd); relaxed `CORE_UTILIZATION` 52→45 (committed with the fakeram strap regen, 9fde5e9d). Passes with WS +1.00 ns at the 10 ns clock (period_min 9.00 ns), 14 726 logic cells, zero violations.

## gt2n

**Status**: finishing
**Last updated**: 2026-11-16 (first gt2n close, 2026-11 pin — bazel-orfs 805ffd68 / OpenROAD 687848dd / yosys 0.68)

### Configuration

| Die | Density | Halo | Clock (ps) | Notes |
|---|---:|---:|---:|---|
| explicit 434×210 (core 2 2 432 208) | 0.60 | — | 1450 | Manual `place_macro` grid in `macros.tcl` (5 macros); `MAX_ROUTING_LAYER M11`, `MIN_CLK_ROUTING_LAYER M4`; `set_false_path -from sys_reset`; `-D USE_GT2N_CELLS` |

### Decisions
- **2026-11-16 first gt2n port — RTLMP MPL-0045 forced a manual floorplan
  (`2cc59c5b`)**: the five SRAM macros (two 64w1024d at 24.9k µm² each + three
  64w64d) total 54,445 µm² against only ~933 µm² of 2nm std cells, and the
  LiteX netlist is flat, so RTLMP's `breakLargeFlatCluster` TritonPart
  partition fails at every balance relaxation (1→91) regardless of die size or
  `RTLMP_MAX_LEVEL` — see the CLAUDE.md bug-table row and
  [OpenROAD#11820](https://github.com/The-OpenROAD-Project/OpenROAD/issues/11820)
  (our self-contained liteeth-gt2n repro posted 2026-11-16; tarball on the
  `repro-mpl0045-2026-11-16` prerelease). Workaround: explicit 450×310 die
  (39 % macro) with the two big SRAMs in the bottom corners, the three small
  ones in a middle row, std cells keeping the top band; macros arrive FIXED so
  RTLMP is skipped entirely. Remove `macros.tcl` + explicit die once the pin
  carries the upstream fix (by-instance-count fallback proposed on the issue).
- **2026-11-16 clock retarget 900 → 1450 ps (`217eadd1`, results under
  `217eadd`)**: first close at the 900 ps guess gave period_min 1310 ps
  (SRAM-access-bound, like asap7); retargeted to period_min × 1.10. Closes
  with setup WS +0.8 ps at 1450 ps (period_min 1449 ps, **Fmax 690 MHz** vs
  0.98 GHz asap7 — the SRAM macro access arc dominates on both), TNS 0, zero
  setup/slew/cap/fanout violations. Reported hold WS −23.6 ps (19 endpoints)
  is entirely the input-port `set_input_delay` hold-check artifact
  (`udp0_udp_port[*]` → FF, same class as litepci/partition_p); worst
  *internal* hold path is MET at +1.4 ps. GRT congestion is a non-issue
  (zero overflow, M2/M3 ≤ 2.3 % usage).
- **2026-11-17 die shrink 450×310 → 434×210 (`c352728a`, results under
  `c352728`)**: the first-close die had 39 % macro coverage and only ~0.8 %
  of the die in actual logic (zero congestion everywhere), so repacked to
  10 µm margins / 15 µm channels with the three small SRAMs moved into the
  top band beside the std cells. Die −34.7 % (139,500 → 91,140 µm², macro
  coverage 60 % — near the packing bound for a design that is 98 % SRAM by
  cell area). Strictly better QoR: setup WS +14.3 ps (period_min 1436 ps →
  Fmax 697 MHz), power 17.4 → 15.7 mW (−10 %, shorter wires), and **hold
  now clean too** (WS +0.69 ps, 0 violations) — the shorter clock tree
  shrank the insertion delay enough that the input-port hold artifact from
  the first close disappeared.
- Reporting basis is `_grt_report` (global-route parasitics): gt2n has no
  OpenRCX rules yet, so `_final_report` fails STA-1670 on the empty SPEF —
  platform-level follow-up, not a design issue.

### Known issues / open questions
- MPL-0045 manual floorplan is temporary — retry plain RTLMP on each pin bump (CLAUDE.md bug table tracks it).
- ~~The −23.6 ps IO hold artifact~~ — cleared by the 2026-11-17 die shrink (shorter clock insertion delay); hold is now fully clean.
