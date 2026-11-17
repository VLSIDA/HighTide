# vortex Design Decisions

- **2026-10 baseline audit**: removed the earlier percentage-based ASAP7
  input/output delay assignments, which were overwritten by the later fixed
  10 ps assignments. The effective 10 ps interface contract is unchanged;
  the SDC now expresses it once so a clock-period edit cannot be mistaken
  for a change to I/O delay.

Per-platform notes for the `vortex` design (Vortex GPGPU, Verilog top `Vortex`).
See `CLAUDE.md` (root) for the canonical upstream-bug index.

Vortex is a SystemVerilog GPGPU synthesized through the **yosys-slang** frontend
(`SYNTH_HDL_FRONTEND = slang`). It instantiates 6 hard FakeRAM macros
(`128x64`, `21x256`, `21x64`, `32x1024`, `512x64`, `128x256`) plus several
sub-CACTI arrays that fall through to a behavioral reg-array stub. Only **asap7**
reaches `_final` today; nangate45 / sky130hd are not yet closing and are out of scope.

## Active workarounds

- **yosys-slang `#304`** (phantom `1'x` driver on interface-array modport bits) — fixed
  by pinning `yosys-slang` at `eabdfd1` in `yosys_slang.bzl`. Still required; the plugin
  builds and parses Vortex cleanly against **yosys 0.64** after the 2026-06-04 upgrade
  (`read_slang` runs without the multidriver/`1'x` error).

## asap7

**Status**: reaches `_final` (setup-critical — worst path is SRAM-access bound; WNS negative)
**Last updated**: 2026-06-04 (bazel-orfs 553c1c3 upgrade)

### Configuration
- `SYNTH_HDL_FRONTEND = slang`, `SYNTH_HIERARCHICAL = 0`
- `CORE_UTILIZATION = 56`, `PLACE_DENSITY_LB_ADDON = 0.46`, `MACRO_PLACE_HALO = 5 5`
- `TNS_END_PERCENT = 100`
- Clock: `1100 ps`

### Decisions
- **2026-06-04 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)**:
  builds clean; slang frontend parses Vortex on yosys 0.64. Netlist essentially unchanged
  (211 921 logic cells vs 214 803 baseline, −1.3 %; instance area −1.1 %; die ±0 %; power +1.4 %).
  Timing regressed: WNS −55.96 → **−134.82 ps** on the 1100 ps clock (Fmax 0.87 → 0.81 GHz,
  −6.9 %). The worst path runs **from a dcache `fakeram_128x256` macro output through the
  cache response-queue logic to a capture flop** — an SRAM-read-bound, single-cycle path.
  Flow knobs (util / density / halo) can't shorten the SRAM's intrinsic access delay, and
  RTL/SDC are off-limits for this upgrade, so the path is not recoverable without a
  pipeline/clock change. Accepted as-is: the design was already setup-negative pre-upgrade
  (−56 ps), area/power are within ~1.4 %, and it reaches `_final` exactly as before.

### Known issues / open questions
- Setup WNS negative (−134.82 ps); SRAM-bound critical path. Recovering it needs an RTL
  pipeline change or a looser clock — out of scope for the toolchain upgrade.

## nangate45

**Status**: reaches `_final` on bazel-orfs 553c1c3.
**Last updated**: 2026-06-04 (toolchain upgrade)

- **2026-06-04**: closes timing — WNS +661 → +626 ps, util 35.7 %. But yosys 0.64's slang
  frontend grows the netlist on this design's FF-fallback memories: **123 554 → 154 070
  logic cells (+24.7 %)**. multiple levers were tried — `ABC_AREA=1` (worse, +71%), `set_max_fanout` 32→64 (−0.1%, comb count
  identical → not SDC/fanout-driven), and `SYNTH_HIERARCHICAL=1` were all tried — none recover
  it; the growth is purely yosys-0.64 ABC combinational tech-mapping for the nangate45/sky130
  cell libraries (asap7's mapping is unaffected). The SDC is consistent across the regression
  (same constraints produced the leaner old-tools baseline). **Accepted/backed off**: area-only,
  designs still close (n45 +626 ps) / route (sky −172 ps).

  **Root cause (2026-06-10, confirmed):** the synth stat is dominated by **MUX2_X1 = 54 100
  cells** — the read-multiplexer trees of the FF-fallback memories (the depth-16 reg-arrays
  n45/sky cannot size as macros). yosys 0.64 lowers/shares those read muxes far less
  efficiently than 0.62, a **front-end memory-lowering change set before ABC**. That is why
  the count is **invariant to the clock period** (95 480 comb / 54 100 MUX2 at both 3.0 ns and
  4.0 ns — relaxing the period only grows WNS, leaving cells and achievable Fmax unchanged),
  to `set_max_fanout`, and to ABC area/speed mode. Not an SDC/clock issue. The only real
  remedies are structural — a yosys memory-mux-sharing option, or sizing the depth-16
  memories as macros — both beyond the flow-knob scope of this upgrade.

## sky130hd

**Status**: reaches `_final` on bazel-orfs 553c1c3 (setup-negative).
**Last updated**: 2026-06-04 (toolchain upgrade)

- **2026-06-04**: WNS +130 → **−172.6 ps** (SRAM-bound path, same as asap7) and **94 627 →
  121 621 logic cells (+28.5 %)** — same yosys-0.64 FF-fallback growth as nangate45;
  `ABC_AREA=1` reverted (made it 159 164). Reaches `_final`; flagged QoR regression (cells +
  setup), neither recoverable via flow knobs without RTL/SDC changes.
