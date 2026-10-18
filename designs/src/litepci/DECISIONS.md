# litepci — design decisions

litepci is the [enjoy-digital/litepcie](https://github.com/enjoy-digital/litepcie)
LitePCIe controller (TLP + DMA + MSI + Wishbone), generated from
`examples/kcu105.yml` (UltraScale+ `USPCIEPHY`, x4 Gen3, 128-bit data path,
2 DMA channels with monitoring).

The Verilog (`litepcie_core.v` + `pcie_us_stub.v`) is generated hermetically by
Bazel from the pinned `@litepci_src` archive run under the shared LiteX toolchain
with the checked-in `kcu105.yml` config; see `designs/src/litepci/BUILD.bazel`
(the `:gen_litepci` pipeline that replaced the retired `dev/gen.sh`).

## Top-level wrapper

The top module is `litepcie_core` (litex's emitted top name). All non-PHY
boundaries — DMA AXI-Stream channels (`dma0/1_reader/writer_axi_*`), MMAP
master/slave AXI-Lite, MSI IRQs — appear as real top-level ports. PHY-side
signals are the four PCIe lanes (`pcie_rx_p/n`, `pcie_tx_p/n`) plus the
differential refclk (`pcie_clk_p/n`) and async `pcie_rst_n`.

## Xilinx primitives in the generated Verilog

`gen.py` emits three non-portable cells regardless of the target SoC flow:

| Cell | Role | Treatment |
|------|------|-----------|
| `FDPE` | D flip-flop with async preset, 20 instances | Reuse liteeth's synthesizable stub at `designs/src/liteeth/libraries/xilinx/FDPE.v` |
| `IBUFDS_GTE3` | High-speed differential clock buffer feeding the GT block | Synthesizable stub at `designs/src/litepci/libraries/xilinx/IBUFDS_GTE3.v` that passes the (already single-ended in our ASIC build) refclk straight through to `O` and `ODIV2` — mapped via `USE_<PLATFORM>_CELLS` to a tech-specific BUFx2 |
| `pcie_us` | Xilinx UltraScale+ PCIe hard IP (134 ports) | True `(* blackbox *)` — treated as an off-chip macro with a generated placeholder LEF/LIB pair |

Both stubs and the blackbox are auto-derived from the freshly generated
`litepcie_core.v` by `dev/gen_phy_stub.py` (port list) and
`dev/gen_phy_lef.py` (per-platform LEF + dummy timing library). The LEF pin
layer is chosen per platform to match a horizontal-routing layer (M4 on
asap7, metal3 on nangate45, met3 on sky130hd) so the global router can find
access points on the macro's left/right edges.

## `$readmemh` inlining

`gen.py` emits a `$readmemh("litepcie_core_mem.init", mem)` for the LiteX CSR
identification string (~45 bytes of ASCII). Yosys is invoked from a Bazel
sandbox that doesn't have the `.init` file alongside the `.v`, so the read
fails at synthesis time. `dev/inline_readmemh.py` rewrites the call into
explicit `mem[i] = 8'hXX;` initial assignments — no runtime file IO needed.

## Memories — FakeRAM-mapped via the generic LiteX patcher

`gen.sh` runs `dev/inline_fakeram.py` over the freshly-generated
`litepcie_core.v`, which finds each LiteX-emitted memory block
(`// Memory <name>: <D>-words x <W>-bit` … through the closing
`assign <sig>_rdport_dat_r = …;`) and — if `W × D ≥ 4096` — replaces
the `reg` array + two `always` blocks with a `(* keep *)`
`fakeram_1rw1r_<W>w<D>d_sram` instantiation.  Liteeth does the same
job with hand-written per-variant `.patch` files; litepci has 20 such
memories across 5 geometries, so a regex over the always-the-same
block template is more maintainable than 20 hunks of unified diff.

| Width × depth | Bits | Instances | Subsystem |
|--------------:|-----:|----------:|-----------|
| 92  × 256     | 23 552  | 4 | DMA channel 0/1 writer + reader **descriptor tables** |
| 130 × 128     | 16 640  | 2 | DMA channel 0/1 writer **data FIFO** |
| 130 × 512     | 66 560  | 4 | DMA channel 0/1 buffering **syncfifo** 0–3 |
| 130 × 1024    | 133 120 | 2 | DMA channel 0/1 reader **data FIFO** |
| 230 × 128     | 29 440  | 8 | TLP packetizer/depacketizer **fragment FIFOs** |

Each platform's `designs/<platform>/litepci/sram/` carries the matching
bsg_fakeram LEF/LIB pair (configs at `dev/generated/fakeram_<platform>.cfg`).
The 8 smaller-than-4 Kb memories — the four 16×146 AXI-Stream CDC FIFOs,
the 4×10 MSI CDC FIFO, and three TLP sub-fragment FIFOs — stay as inferred
`reg` arrays and synthesize to flop arrays naturally.

**SRAM macro naming is not uniform across platforms** (post-#143 state).
The `inline_fakeram.py` patcher emits the original unified
`fakeram_1rw1r_<W>w<D>d_sram` name.  asap7's committed SRAM macros still
use that name, so the patcher matches them directly.  The repo-wide
bsg_fakeram wd_in LEF-pin-direction fix (`94296798` / `657bb977`) also
**renamed** nangate45's macros to `fakeram45_1rw1r_<W>w<D>d` and
sky130hd's to `fakeram130_1rw1r_<W>w<D>d`, and relocated the `pcie_us`
placeholder out of `sram/` into a dedicated `phy/{lef,lib}/` tree
(globbed by `phy_lefs`/`phy_libs` filegroups).  Consequence: **only
asap7 is currently consistent**.  nangate45 / sky130hd still need their
patcher cell names (or their renamed macros) reconciled before they will
synthesize against real FakeRAM — see the per-platform status below.

### Async-read → sync-read latency caveat

LiteX declares `Port 1 | Read: Async` for the four DMA descriptor
tables (`storage_5`, `storage_7`, `storage_11`, `storage_13` — the
writer/reader self tables for channels 0/1).  The committed FakeRAM
only exposes a sync read port, so the patcher routes
`<sig>_rdport_dat_r` through the FakeRAM's registered `r0_rd_out`,
adding one cycle of latency.  For the *benchmarking* flow we
target — synthesis, P&R, STA — that's harmless: yosys-slang and
OpenROAD see a clean memory cell, and STA now finds the
register-to-register paths through the DMA datapath that mocked
memories used to hide.  Functional simulation of the patched netlist
against the original RTL **would** show a 1-cycle skew on the
descriptor read path; we don't run that.

## pcie_us LEF sizing (PPA tune)

The pcie_us LEF is a placeholder, but its size dominates die area because
it contributes the only non-stdcell instance. The committed sizes are the
smallest tested values that pass GRT pin-access and DRT:

| Platform | LEF size | Pin layer | Stride | Pin column needed |
|----------|----------|-----------|--------|-------------------|
| asap7    | 80×80 µm  | M4 (horiz)     | 2 | ~62 µm  |
| nangate45| 280×280 µm| metal3 (horiz) | 2 | ~247 µm |
| sky130hd | 1000×1000 µm | met3 (horiz)| 2 | ~885 µm |

Trying `pin_stride = 1` on nangate45 hit `DRT-0419` warnings (no track
through pin center) followed by `repair_timing` non-convergence; on
sky130hd it hit `[ERROR DRT-0073] No access point for pcie_us/...`
because pin pitch matched the track pitch and the access-point algorithm
couldn't drop a via.

## pcie_us LIB: clock-output modeling (floorplan SIG11)

`gen_phy_lef.py`'s stub liberty must tag the pcie_us clock-source
outputs `clock : true`, **never** `function : "0"`.  The set
`{user_clk, int_qpll1outclk_out, int_qpll1outrefclk_out}` drives real
clock nets inside litepcie_core.  An earlier generator gave every output
`function : "0"`, which constant-folds `pcie_us/user_clk` to 0: STA then
finds no register-to-register paths, and — once the SDC hangs a
`create_clock` on that constant-tied pin — the floorplan-time metrics STA
**segfaults (signal 11)**.  The generator special-cases those three
scalar outputs with `clock : true`; the committed
`designs/<plat>/litepci/phy/lib/pcie_us.lib` are regenerated from it.

## SDC topology — one clock + the forwarded-clock feedthrough

litepcie_core exposes `clk` as an *output* port — it's a fanout of
`pcie_us/user_clk`, not the clock source.  Earlier drafts wrote
`create_clock -name sys_clk [get_ports clk]`, which STA silently accepted
but never propagated, producing `No launch/capture paths found` under
sys_clk.  The SDC creates the single user clock on `pcie_us/user_clk`
(the actual driver of the `sys_clk = pcie_clk = clk` chain inside
litepcie_core), so STA times all DMA / TLP register-to-register paths
through the FakeRAMs.

`clk` is the user clock *forwarded off-chip* — a buffered fanout of
pcie_us/user_clk, not a data output.  With `set_output_delay` on
`[all_outputs]` it gets timed as a ~4.9 ns *data* path that walks the
entire CTS clock-distribution buffer tree, producing a spurious ~−2 ns
WNS that dominates the report and that `repair_timing` cannot fix (the
buffers are existing clock buffers).  Fix: model `clk` as a generated
clock —

```tcl
create_generated_clock -name clk_fwd -source [get_pins pcie_us/user_clk] \
    -divide_by 1 [get_ports clk]
```

so the feedthrough is a clock network with launch/capture edges aligned.
Same workaround as `designs/asap7/litedram/constraint.sdc` (LiteX
`user_clk` output port) — a recurring LiteX-family pattern.

## Per-platform PPA + the structural hold-skew limit

### Important: earlier numbers were fictitious

A prior revision of this file tabulated asap7 closing at 3.6 ns with
−0.44 ns TNS.  Those numbers were measured with (a) the **pre-wd_in-fix**
FakeRAM LEFs — per the bsg_fakeram wd_in bug, upper-half `wd_in` pins
were mislabeled OUTPUT, so **half the register→FakeRAM write-data paths
were never timed** — and/or (b) a broken SDC that reported *no paths at
all*.  With the corrected wd_in-fixed LEFs and the working single-clock +
generated-clock SDC, the real timing is substantially harder.  The
numbers below are the honest, measured ones.

Commit `24bbf831` ("Design & flow fixes enabled by the macro recovery")
silently reverted PR #143's entire litepci real-FakeRAM + SDC work back
to mocked memories.  The current state restores #143's logic while
keeping the post-#143 wd_in-fixed SRAM macros and the `phy/` relocation.

### asap7 — measured (real FakeRAM, wd_in-fixed, util 75)

| Metric | Value |
|--------|------:|
| Target clk | 3.6 ns |
| Reg-to-reg **setup** | **MET, +0.758 ns** (closes) |
| Setup TNS / violations | −2.39 ns / 3 endpoints |
| Worst setup endpoint | FakeRAM → `mmap_slave_axi_lite_arready` (output-delay-bound I/O port, not a reg path) |
| **Hold** WNS / violations | **−2.22 ns / ~11 300** |
| Clock skew | ~2.2 ns |
| Die area | 0.653 mm² |
| Inst util | 75.3 % |
| Power | 55.4 mW |

**Setup closes; hold is structurally skew-bound.** The fixed LiteX RTL
clocks 20 large DMA/TLP FakeRAMs from a single small clock source —
the `pcie_us/user_clk` blackbox-macro pin.  Those 20 sink macros are
59 % (util 60) – 74 % (util 75) of the core area, so CTS must snake a
deep buffer chain (observed: 3-buffer / 0.21 ns to one macro vs.
25-buffer / 2.94 ns to another) → ~2.2–2.7 ns launch/capture skew →
~11 k hold violations.  This was shown unfixable by every in-scope
lever:

- **Utilization** (60 → 75): die −20 %, setup TNS −75 %, but skew only
  2.7 → 2.2 ns and hold-violation count flat — skew is ~die-size-
  independent.
- **Macro placement** — one tight block (overflows die height),
  balanced perimeter ring (overflows usable edge length), and two-band
  + central clock stripe (bands consume the full die, no stripe) all
  fail the same area/perimeter wall: the macros are too dense to
  co-locate compactly with the single clock-source pin *and* leave room
  for a balanced central clock spine at any util that meets the area
  goal.
- **SDC** — single-clock + generated-clock-feedthrough fixes removed the
  spurious −2 ns WNS but do not touch the physical skew.

So asap7's deliverable is: the design **closes setup** at 3.6 ns and is
**characterized as hold-skew-bound** — a legitimate benchmark result for
this fixed RTL.  Closing hold would require modifying the RTL (a clock
buffer/tree the SoC integrator would normally add), which the benchmark
charter forbids.

### nangate45 / sky130hd — NOT rebuilt; needs reconciliation

These were **not** re-verified in the real-FakeRAM restore.  Their
`constraint.sdc` and `BUILD.bazel` are still the regressed (`24bbf831`)
mocked-memory versions, and their SRAM macros were renamed
(`fakeram45_*` / `fakeram130_*`) by the wd_in-fix reorg so the patcher's
`fakeram_1rw1r_<W>w<D>d_sram` cell names will not resolve until
reconciled (rename the macros back, or teach `inline_fakeram.py` /
`fakeram_<plat>.cfg` the platform-prefixed names).  Until then only
asap7 carries the real-FakeRAM build.

### Knob summary (asap7)

| Platform  | CORE_UTILIZATION | PLACE_DENSITY | MACRO_PLACE_HALO |
|-----------|------------------|---------------|------------------|
| asap7     | 75               | 0.80          | 5 5              |

util 75 is the measured best PPA point; the hold limit is structural and
util-independent, so there is no benefit to trading area for a lower util.

## 2026-06 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)

The **CTS-0122 fix is now in the OpenROAD pin** (the local patch was dropped), so the
clock tree is built normally — the ~2.2/9.3 ns structural CTS skew that dominated litepci
is gone. **asap7** now closes with a real clock tree: WNS −883 → **+944 ps** (cells +29.7 %,
the cost of a proper clock + repair vs the prior skew-broken state); both ODB-1200
workarounds (`SETUP_MOVE_SEQUENCE`, `SKIP_INCREMENTAL_REPAIR`) **removed** — the resizer bug
is fixed. **nangate45**: both removed, reaches `_final` (its WNS is still dominated by the
pre-existing forwarded-clock SDC quirk — Fmax≈0, unchanged from baseline; not a regression).
**sky130hd**: **flagged — does not route on the new tools.** It is the hardest of the three
ports (1000×1000 `pcie_us` + 20 large FakeRAMs on sky130's coarse pitch). The new OpenROAD
299f3015 global router cannot resolve its congestion: at util 30 GRT loops its 30 congestion
iterations indefinitely (~23 h CPU, no convergence); dropping util 30→24 instead hard-fails
with **GRT-0116** after the iteration budget. `SETUP_MOVE_SEQUENCE` (split_load-drop) +
`SKIP_INCREMENTAL_REPAIR` are kept but the blocker is GRT routability, not repair. Recovering
this needs dedicated congestion work (macro re-floorplan, routing-layer adjustment, or a
larger die) beyond the upgrade's flow-knob scope. asap7 + nangate45 litepci both pass.

## 2026-07 re-validation (bazel-orfs 6c1bbca / OpenROAD b65c274c) — `SKIP_INCREMENTAL_REPAIR` re-added; nangate45 synth fixed

Two new-tools issues surfaced (both k8s-verified fixes):

1. **New-resizer `repair_timing` non-convergence → `SKIP_INCREMENTAL_REPAIR = 1` re-added on
   asap7 *and* nangate45.** The 553c1c3 upgrade above removed the skip (ODB-1200 was fixed in
   299f3015). But the b65c274c resizer's post-GRT `repair_timing` **does not converge** on
   litepci's forwarded-clock reg2reg feedthrough: the worst reg2reg path is the LiteX `user_clk`
   off-chip forward (WNS ≈ −898 ps), which is structural (io-feedthrough, not silicon) and
   unrepairable. The pass keeps buffering (~1450 iters/hr, TNS decaying asymptotically) and never
   terminates (killed at ~2 h / iter ~2200 with TNS still hugely negative). With the skip, both
   platforms reach `_final`. NOTE: the asap7 arg had long been *described* in a BUILD.bazel
   comment ("Skip the whole post-GRT repair block") but the argument was never actually set, so
   the flow had been running the (now non-converging) repair the whole time — now set for real.
   Result **asap7 PASS**: 71 328 logic cells (−26.6 % — the omitted repair no longer sprays
   buffers), WNS **+927 ps** (reg2reg met, setup TNS = 0; the +slack is the io-feedthrough),
   Fmax 0.374 GHz.

2. **nangate45 synth was build-broken by an SDC clock-period sed poisoning → `constraint.sdc`
   comment reworded.** ORFS derives the ABC target clock period by grepping the SDC with a naive
   sed (`variables.mk`) that takes the first `-period <n>` / `set clk_period <n>` token in the
   file. The n45 SDC comment quoted a backtick example (`` `-period 10000` ``); the sed captured
   `10000` *with the trailing backtick*, and `echo 10000\` > clock_period.txt` triggered
   unterminated shell command-substitution → make **Error 2**, killing synth before floorplan.
   Reworded the comment (no hyphen-period token, no backtick) so the sed cleanly extracts
   `set clk_period 10`. Result **nangate45 PASS**: 68 910 logic cells (−2.3 %), WNS **+4266 ps**
   (reg2reg met), Fmax 0.174 GHz. (The old baseline's +3 197 480 ps was the 1000× ns/ps
   unit-error artifact.) **Follow-up**: the 10 ns clock is a never-tightened probe value — the
   huge +slack is not meaningful; tighten to `period_min × 1.10` from a routed measurement to get
   a real Fmax.

**sky130hd**: still **flagged — does not route** (GRT congestion, unchanged from the 553c1c3
section above; its stage ODBs also bust the Cloudflare cache cap). asap7 + nangate45 pass.

### 2026-09: sky130hd clock-period parser regression

The sky130hd SDC placed a historical reference-clock example before the real 20 ns
clock-period assignment. The extraction expression in the pinned ORFS revision therefore
returned `10000` with a trailing backtick instead of `20`, stopping the synthesis rule
while generating `clock_period.txt` ([HighTide#238](https://github.com/VLSIDA/HighTide/issues/238)).
The real assignment now precedes the historical note, and the note no longer contains the
parser's conflicting token. This restores synthesis startup only; the later sky130hd GRT
congestion tracked in [HighTide#204](https://github.com/VLSIDA/HighTide/issues/204) is unchanged.

## Bug workarounds in the real-FakeRAM build

| Knob | Reason |
|------|--------|
| ~~`SETUP_MOVE_SEQUENCE` / `SKIP_INCREMENTAL_REPAIR`~~ | ODB-1200 fixed in OpenROAD 299f3015. Removed on asap7 + nangate45; sky130hd keeps `SETUP_MOVE_SEQUENCE` (split_load-drop) for repair convergence only — see the upgrade section above. |

Note `SKIP_INCREMENTAL_REPAIR = 1` also disables post-GRT hold repair.
That is *not* the cause of the asap7 hold story above — a ~2.2 ns
structural CTS skew is far beyond what data-side hold buffering could
absorb anyway — but it does mean the ~11 k count is fully unrepaired.

## `GDS_ALLOW_EMPTY`

`hightide_design()` defaults to `fakeram.*`. Each platform extends that to
`fakeram.*|pcie_us` so OpenROAD doesn't insist on a GDS body for the PCIe
hard-IP blackbox.
