## 2026-10-18 selected clock-valid baseline

Select the corrected-clock 20 ps routed hold guard. Its final result is setup
+164.647 ps, hold −0.355105 ps (one removal violation), DRC 0, and two slew
violations. All native `check_setup` checks pass, with no unclocked pins or
unconstrained endpoints. Keep the residual hold failure visible; this is a
comparison baseline, not a signoff-closed design.

Larger guards did not improve this point. At 40 ps, repair reports RSZ-0064,
global-route hold −232.88 ps / 79 violations, and final hold −191.035 ps /
70 violations. A bounded 25 ps check also leaves 70 final violations, worst
−191.669 ps. Both are rejected. Synthesis netlist/SDC and CTS results are
identical across the three guards; the change is in routed hold repair.
Restore the source guard to 20 ps and retain all three runs' actual metrics.
No clock period, I/O budget or timing exception was relaxed.

The selected run is `artifacts/asap7-liteeth-clock-startup-20261018`, with
`clock-coverage.json` and immutable physical results. The two rejected runs
are `asap7-liteeth-clock-margin-20261018` and
`asap7-liteeth-clock-margin25-20261018`. The unified reviewed build must use
the same corrected clock model and 20 ps guard and report its own final slack.

## 2026-10-18 PHY clock-model audit (full-flow validation pending)

The exhaustive final `check_setup` audit found 53 unclocked register/memory
clock pins and 61 unconstrained endpoints. The generated design selects CPLL
(`CPLLREFCLKSEL=7`, `RX/TXSYSCLKSEL=0`) and ties both QPLL clocks to zero.
`GTHE4_CHANNEL_DUMMY` ignored CPLL and selected only those zero QPLL inputs,
so the transmit domain was dead. The earlier positive system-clock timing,
including the isolated hold-only repair, is an incomplete reference.

The stub now selects the CPLL reference with its full three-bit selector and
uses RX/TXSYSCLKSEL for CPLL/QPLL0/QPLL1. Selection follows
[UG576 table 2-7](https://docs.amd.com/api/khub/documents/X8hVhAx~JVBkxiZRAjsdRg/content).
The ASIC surrogate forwards that reference 1:1; it does not implement analog
PLL multiplication or serial clock recovery. This is a benchmark of the
surrogate, not an ASIC implementation of an FPGA transceiver.

The BUFG_GT stub also toggled its output after N cycles, giving divide-by-2N
instead of N. Its counter now produces divide-by-(DIV+1), including DIV=7,
and the enable/reset mask semantics are corrected. The adaptation patch
explicitly ties CE=1, CEMASK=0, CLR=0 and CLRMASK=0 on all four instances;
the generator previously left these control ports open. Both edited legacy
model files use LF line endings. The clock-model testbench verifies seven
CPLL reference selections, both QPLL selections, all eight divider frequencies,
and the enable/reset masks. It runs through the same Yosys frontend before
Icarus simulation because the pre-existing vendor stub contains duplicate
declarations that Icarus rejects directly. The test passes; its logs are in
`artifacts/asap7-liteeth-clock-model-test-20261018`.

The ASAP7 SDC retains the 1022 ps system target and 204.4 ps numerical I/O
budget. It adds the configuration's 156.25 MHz reference (6400 ps), generated
half-rate clocks for DIV=1, and asynchronous system/PHY clock groups for the
separate external oscillators and existing CDC logic. PHY data pins retain
the same numerical budget referenced to the PHY clock. This boundary contract
is for the 1:1 surrogate model; it is not a SerDes signoff constraint set.
No new data-path exception within a clock domain was introduced.

A reset-free startup test matching the generated CE=1/CLR=0 usage also
exposed an unknown divider state. The surrogate counter now starts at zero,
providing a deterministic simulated phase; this does not implement an ASIC
power-on-reset circuit. The test confirms startup and the divided frequency
without toggling CLR, in addition to reset/mask behavior. These results are
in `artifacts/asap7-liteeth-clock-startup-test-20261018`.

The first full-flow trial reached mapped synthesis but its SDC referenced
top-level half-clock wire aliases removed by synthesis. It failed and is
retained in `artifacts/asap7-liteeth-clock-model-20261018`. The SDC now targets
the surviving explicit primitive output pins (`BUFG_GT_1.clk_buf/Y`, and the
RX counterpart if it survives optimization). The selected retry is
`artifacts/asap7-liteeth-clock-startup-20261018`; it completes with setup
+164.647 ps, hold −0.355105 ps (one removal check), routing DRC 0, and two slew
violations. All seven native `check_setup` checks pass: no unclocked pins,
unconstrained endpoints, loops, missing delays or generated-clock source
errors. The final clock objects are `clk`, `phy_ref_clk`, `phy_tx_half_clk`;
the RX half-rate branch is unused and optimized away.

The remaining removal check is from `GTHE4_CHANNEL.txresetdone_reg` on the PHY
half clock to the FDPE reset synchronizer on the full PHY clock. These clocks
are related and remain timed. Global-route hold slack +19.286 ps becomes
−0.355105 ps after extraction. Raise the hold-repair guard from 20 to 40 ps,
with no RTL, clock or interface changes; validate in
`artifacts/asap7-liteeth-clock-margin-20261018`. The previous clock-valid
20 ps result stays in the compact `liteeth-clock-model` tables. The larger
margin must be extracted and rechecked before acceptance. Previous
LiteEth snapshots retain their frozen old RTL/SDC and must not be attributed
to the new model. Common clock-model changes have only been exercised for the
ASAP7 flow in this audit.

# liteeth Design Decisions

- **2026-10 ASAP7 baseline audit**: the original flow
  completed with setup WNS +136.394 ps but hold WNS -161.968 ps and 323 hold
  violations. The SDC treats `sys_reset` as a clocked input, and the worst
  hold check ends at `udpcore_int_rst$_DFF_P_/D`. Excluding reset timing would
  weaken that interface contract. Both CTS and incremental repair were skipped.
  A hold-only CTS trial with a 30 ps margin closed hold (+28.7508 ps) but
  regressed final setup to -289.538 ps (332 violations), and was rejected.
  CTS placement estimates were substantially more pessimistic for hold than
  routed timing (original CTS -507.144 ps versus final -161.968 ps).
  The validated repair retains skipped CTS repair and enables the standard
  incremental global-route repair/legalization/reroute block with a hook
  requesting **hold-only** timing repair and a 20 ps margin. This uses routed
  parasitics while retaining the setup-repair workaround and the existing
  1022 ps clock / 204.4 ps I/O delay contract. Final extracted results:
  setup WNS **+167.810 ps**, hold WNS **+10.3744 ps**, zero setup/hold
  violations, zero route DRCs, Fmax **1.1707 GHz**. Sequential (2896) and
  combinational (12100) cell counts are unchanged; logic cells increase
  17858→20843 through buffer/inverter insertion. The synthesized netlist
  and synthesis SDC match the original run byte-for-byte. **54 slew-limit
  violations remain** and are recorded separately; this establishes setup/
  hold closure, not full electrical closure. Raw provenance and results are
  in `artifacts/asap7-liteeth-grt-hold-20261017/`.

Per-platform notes for the `liteeth` design (Verilog top
`liteeth_udp_usp_gth_sgmii`) — the LiteEth Ethernet stack (LiteX/Python)
configured with a UDP endpoint over the Xilinx UltraScale+ GTH-SerDes
SGMII PHY.

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
  - **asap7**: `SKIP_CTS_REPAIR_TIMING` + `SKIP_INCREMENTAL_REPAIR` **kept** — not because
    of the crash (it no longer crashes) but because re-enabling repair_timing on this design
    makes the new resizer over-buffer (cells +37%, buf/inv ×3.3) for only a marginal close.
    Skipping repair gives strictly better QoR. See [HighTide#75](https://github.com/VLSIDA/HighTide/issues/75).

## asap7

**Status**: finishing
**Last updated**: `8ec5a224` (2026-05-11 PPA area sweep)

### Configuration

| Util | Density | Halo | Clock (ps) | Notes |
|---:|---:|---:|---:|---|
| 50 | 0.55 | — | 1000 | `SKIP_CTS_REPAIR_TIMING=1` (ODB-1200); area-tuned 2026-05-11 |

### Decisions
- **2026-04-30 `c8d96617`**: hit ODB-1200 in CTS repair_timing once the OpenROAD pin moved from `5f1bd87f` to `578be38a` (HighTide #103). Same bug class that previously affected `liteeth_udp_stream_sgmii` (PR #76). Added `SKIP_CTS_REPAIR_TIMING=1`.
- **2026-05-11 PPA area sweep**: UTIL 35→50 / DENSITY 0.30→0.55. Die area 41,896 → 29,439 µm² (**−30 %**). UTIL=55 fails MPL-0003 (macros + default halo cannot tile in the smaller core).
- **2026-06-04 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)**: the new synth/place produces a ~128 ps slower critical path on the 920 ps clock, so at the prior util 43 the design closed at WNS −29.9 ps (timing miss). Relaxed `CORE_UTILIZATION` 43→38 (a flow knob, no SDC/RTL change): recovers WNS to **+111.7 ps** (≥ the pre-upgrade +98 ps), Fmax 1.22→1.24 GHz, cells +0.4 %, instance area +2.1 %, power −3 %. Cost is die area +13 % (util-driven whitespace only). Kept `SKIP_CTS_REPAIR_TIMING` + `SKIP_INCREMENTAL_REPAIR` (see Active workarounds — repair over-buffers here).

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
