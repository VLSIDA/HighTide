# floonoc Design Decisions

Per-platform notes on tuning, workarounds, and platform-specific quirks for `floonoc` (PULP Network-on-Chip mesh).  See `CLAUDE.md` (root) for the canonical upstream-bug index.

Network-on-chip with std-cell-only logic; the only physical-design knobs are clock period, util, and IO placement (the design has many ports).  An `io.tcl` is shared across platforms to spread the IO ring.

## Hermetic RTL sourcing (2026-07)

The mesh is assembled hermetically by Bazel — no `dev/repo` submodule, no bender, no `dev/setup.sh` venv:

- **Bender is bypassed** (the bazel-orfs/gallery cva6 idiom): FlooNoC + its seven PULP dependencies are pinned `http_archive`s (`@floonoc_src` + `@pulp_{apb,axi,axi_stream,common_cells,obi,register_interface,tech_cells_generic}_src`, each at its `Bender.lock` revision), and the exact source subset the mesh needs is curated in **`srcs.bzl`** (the retired `bender script -t rtl -t floo_synth` flist, 218 files). The seven deps share one injected build file (`pulp_dep.BUILD.bazel`).
- **FlooGen runs under Bazel**: `:floonoc_gen` (py_binary, floogen bundled in `@floonoc_src`) renders the mesh topology (`floo_floonoc_mesh_noc[_pkg].sv`) from `dev/mesh_config.yml`; its PyPI deps (pydantic/networkx/matplotlib/mako/ruamel.yaml/click + closure) come from the **`pip_floogen`** hub (`requirements_lock.txt`).
- `cluster_blackbox.sv` / `floonoc_mesh_top.sv` (the 16 black-box cluster endpoints around the mesh) are HighTide-authored wrappers, now committed at `designs/src/floonoc/` instead of emitted as `setup.sh` heredocs.
- The upstream `*.svh` include trees are staged into the synth sandbox via `:rtl_data` + the platform BUILDs' `stage_data` (they're `include`d, not compiled); `VERILOG_INCLUDE_DIRS` points at the `@*_src` include dirs.

**Verification**: floogen output is **byte-identical** to the previously-committed mesh RTL (deterministic on the pinned `pip_floogen` versions); the full hermetic RTL elaborates + synthesizes clean through yosys-slang; and **asap7 `_final` QoR is an exact match to the `results.html` baseline** (die 62500, cells 80073, seq 13748, slack 114.06 ps, Fmax 1.41 GHz, power 95.8 mW — every metric identical), confirming the bender-bypass reproduces the same netlist and layout. Removed the submodule, `setup.sh`, and the entire `dev/generated/` flattened-deps snapshot; kept `dev/mesh_config.yml` (floogen input).

## Upstream history

- **2026-05-30**: bumped `dev/repo` `ed3e41de` → `064df165` (11 commits, v0.7.x → v0.8.1). v0.8.0 introduced the Reduction Feature (`floo_alu.sv`, `floo_reduction_unit.sv`, `floo_reduction_arbiter.sv`, `floo_reduction_sync.sv`) which pulls in the full `fpnew` (cvfpu) tree as a dependency — a significant scope expansion. v0.8.1 adds collective check and an exclusion knob for floogen RDL gen. Tail commit `064df16` adds a floogen collective-model check. Closes #83.

## asap7

**Status**: finishing
**Last updated**: 2026-04-29 (commit `ec7be591`)

### Configuration
- `TNS_END_PERCENT = 100`
- `io.tcl` present — spreads NoC ports around the die perimeter to relieve IO-region congestion
- Clock: `2000 ps` (Fmax ~500 MHz)

### Decisions
- **2026-04-29 `ec7be591`**: closed at 2 ns clock; manual io.tcl was needed because the auto IO placer clustered ports along one edge and choked routing in that region.
- **2026-06-04 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)**: closes clean, no change — WNS +1089 → +1114 ps on the 2 ns clock, util 20.4 %, 80 125 logic cells (slang frontend on yosys 0.64).

### Known issues / open questions
- None.

- **2026-11 toolchain upgrade (bazel-orfs 805ffd68 / OpenROAD 687848dd / yosys 0.68, asap7 BC→TC corner)**: still closes the pushed 821 ps clock on the slower TT libs — WS +36 ps (period_min 785 ps), zero violations. 92 610 logic cells (+15.7 % vs 80 073): corner-driven sizing, not synth growth — the resizer works harder to make 821 ps on TT than on the old FF libs. Expect it to deflate if the constraints pass relaxes the asap7 clocks.
## nangate45

**Status**: finishing
**Last updated**: 2026-04-29 (commit `ec7be591`)

### Configuration
- `TNS_END_PERCENT = 100`
- `io.tcl` present (same purpose as asap7)
- Clock: `5.0 ns` (Fmax ~200 MHz, ~311 MHz reported on results.html)

### Decisions
- **2026-04-29 `ec7be591`**: same shape as asap7 — io.tcl carried over with platform-appropriate metal-layer references.
- **2026-06-04 toolchain upgrade**: closes clean — WNS +1822 → +1838 ps on the 5 ns clock, util 18.2 %, 71 700 logic cells (+3.4 % vs baseline 69 332, within tolerance).

### Known issues / open questions
- None.

- **2026-11 toolchain upgrade**: passes — WS +0.18 ns at the pushed 1.98 ns clock (period_min 1.80 ns), 69 475 logic cells (−3.1 %), zero violations.
## sky130hd

**Status**: finishing
**Last updated**: 2026-06-26 (commit `68afbcb7`)

### Configuration
- `TNS_END_PERCENT = 100`
- `io.tcl` present — `edge_margin = 4.37 µm` (see Decisions for why)
- Clock: `20.0 ns` (Fmax target ~50 MHz)

### Decisions
- **2026-04-29 `ec7be591`**: gave the same treatment as the working platforms (io.tcl + 20 ns clock) but synthesis still doesn't reach `_final` on sky130hd.  Stops at `1_synth` per `tools/summary.sh` "Incomplete builds" output.
- **2026-06-04 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)**: big step forward — the old-tools synth stall is gone and the flow runs all the way to `6_final.odb`. **But the final report fails PSM-0069**: `Check connectivity failed on VSS` — many TAP/FILLER/stdcell `VGND` pins are left unconnected by the default sky130hd PDN under the new tools (PSM-0039 warnings precede it). So it produces a routed DB but not a clean signoff. **Flagged** — needs a PDN fix (followpin/strap coverage of VSS, likely a `pdn.tcl`) to close PSM; out of scope for the flow-knob upgrade. asap7 + nangate45 floonoc pass clean.
- **2026-06-26 `68afbcb7`** (committed 2026-07-03; the `bbc7fd0` SHA previously cited here was a stale pre-rebase SHA): PSM-0069 root cause found and fixed. The 1598 bottom-edge IO pins on met2 at `edge_margin=5.0 µm` had their spacing-expanded obstruction (obs_yMax=5381 nm) overlapping the row-0 VSS via area (y_min=5200 nm); `pdngen` silently dropped all row-0 met1×met4 via candidates with no PDN-0110 warning. Fix: reduced `edge_margin` to **4.37 µm** (nearest valid met2 y-track below the 4.82 µm threshold); obs_yMax drops to 4751 nm, clearing the via area. `_final` passes with `[INFO PSM-0040] All shapes on net VSS are connected.` See CLAUDE.md bugs table for the threshold formula.

### Known issues / open questions
- None.

- **2026-11 toolchain upgrade**: passes — WS +8.88 ns at the 20 ns clock (period_min 11.1 ns), 65 174 logic cells, zero violations. The 4.37 µm `edge_margin` PSM-0069 fix (68afbcb7) still holds under the new pdngen/PSM — `_final` connectivity clean.
## gt2n

**Status**: finishing
**Last updated**: 2026-08-15

### Configuration
- Custom `FOOTPRINT_TCL = io.tcl` — explicit pin placement for 6,395 IO pins (see Decisions)
- `DIE_AREA = "0 0 80 80"`, `CORE_AREA = "6 6 74 74"`
- `MAX_ROUTING_LAYER = M11`, `MIN_CLK_ROUTING_LAYER = M4`
- `HOLD_SLACK_MARGIN = 10`
- `TNS_END_PERCENT = 100`
- Clock: `958 ps` (Fmax 1.04 GHz)

### Decisions
- **Custom io.tcl**: mandatory for 6,395 IO pins — automated placement overflows routing at gt2n's tight pitches. Places pins on M2 (horizontal edges) / M3 (vertical edges), matching platform IO-placer defaults.

### Known issues / open questions
- None.
