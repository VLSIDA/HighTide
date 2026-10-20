# snitch_cluster Design Decisions

Per-platform notes for `snitch_cluster` (PULP Snitch multi-core cluster, top
`snitch_cluster_wrapper`). See `CLAUDE.md` (root) for the canonical upstream-bug index.

Very large logic design (~1.5M std cells), no hard macros on asap7 beyond the 38 the
wrapper instantiates. Carries `SKIP_CTS_REPAIR_TIMING` + `SKIP_INCREMENTAL_REPAIR`
(repair non-convergence on the RTL-bounded endpoints) and, on asap7, a DPL-0036
`PRE_CTS_TCL`. Only asap7 / nangate45 are in scope (no sky130hd port).

## Hermetic RTL sourcing (2026-07)

The cluster is assembled hermetically by Bazel — no `dev/repo` submodule, no bender, no `dev/setup.sh` venv:

- **Bender is bypassed** (the bazel-orfs/gallery cva6 idiom): `@snitch_cluster_src` (the cluster `hw/`) + **fourteen** PULP dependency `http_archive`s at their `Bender.lock` revisions — five reused from FlooNoC (apb/axi_stream/obi/tech_cells_generic/register_interface), the **`colluca/axi` fork** + a snitch-specific `common_cells` SHA (distinct `@snitch_*` names), and the six deps FlooNoC excludes but snitch uses (fpnew/idma/cluster_icache/axi_riscv_atomics/scm/fpu_div_sqrt_mvp). The exact source subset (377 files) is curated in **`srcs.bzl`** (the retired `bender script` flist). All PULP deps share `//designs/src/floonoc:pulp_dep.BUILD.bazel`.
- **clustergen runs under Bazel**: `:snitch_cluster_gen` (py_binary, clustergen bundled in `@snitch_cluster_src`) renders `snitch_cluster_wrapper.sv` + `_pkg.sv` from `dev/cluster_cfg.json` (two passes, one per template); its PyPI deps (json5/jsonref/jsonschema/mako) come from the **`pip_clustergen`** hub.
- **peakrdl is deliberately dropped**: the `snitch_cluster_peripheral_reg[_pkg].sv` files ship **pre-generated** in the upstream archive (setup.sh's peakrdl branch is `if [ ! -f ... ]`-guarded and never runs), so they are referenced from `@snitch_cluster_src` — avoiding peakrdl's systemrdl version fragility.
- `snitch_bootrom.sv` (combinational bootrom) and `tc_sram.sv` (fakeram-backed SRAM override) are committed HighTide files. The `*.svh` include trees (incl. iDMA's nested `src/include` + `target/rtl/include`) are staged via `:rtl_data` + the platform BUILDs' `stage_data`; `VERILOG_INCLUDE_DIRS` points at the `@*_src` include dirs.

**Verification**: clustergen output is **byte-identical** to the previously-committed wrapper/pkg (deterministic); the full hermetic 377-file RTL elaborates + synthesizes clean through yosys-slang (all 4 fakeram macros resolved); and the **asap7 `_final` netlist matches the `results.html` baseline exactly on logic** — seq **147658** and comb **1121472** identical, die/core/util/macros/ios identical — with P&R metrics within tool noise (bufinv −1.6%, WNS +174 ps *better*, Fmax +5%). Removed the submodule, `setup.sh`, `patches/`, and the `dev/generated/deps/` flattened snapshot; kept `dev/cluster_cfg.json` (clustergen input), `dev/generate_sram_mapping.py`, and the `dev/generated/sram/` fakeram macros + cfgs.

## SRAM macro rename to platform-neutral `fakeram_*` (2026-10)

The macro names in the shared `tc_sram.sv` mapping were `fakeram7_*` (asap7
naming) on every platform. Renamed to the platform-neutral `fakeram_*` prefix
suite-wide (tc_sram.sv + both cfgs + regenerated LEF/LIB), prompted by the gt2n
port (PR #240) inheriting the misleading `7`. In the same pass:

- **asap7 moved to the standard macro layout**: cfg now at
  `dev/generated/fakeram_asap7.cfg`, committed LEF/LIB at
  `designs/asap7/snitch_cluster/sram/{lef,lib}/` (was a hand-run
  `dev/generated/sram/fakeram.cfg` + tracked LEF/LIB under `dev/generated/sram/`,
  served via `//designs/src/snitch_cluster:sram_lefs`). `tools/regenerate_sram.sh
  snitch_cluster <platform>` now works for both platforms.
- **asap7 snap-grid key fix**: the old cfg used the buggy snake_case
  `snap_width_nm`/`snap_height_nm` keys (silently ignored → 1 nm grid; see the
  CLAUDE.md bug table). Now camelCase; macros land exactly on the 0.190/1.400 µm
  site grid. Size deltas are negligible (+0.06–0.5 % per side, e.g. 64x512
  138.240×43.200 → 138.320×43.400).
- **nangate45 LEF/LIB are byte-identical** apart from the names (cfg already had
  the correct camelCase keys).

The rename changes bazel inputs on both platforms, so cached `_final` results
invalidate and both rebuild (nangate45 ~14 h). gt2n (PR #240) must regenerate
its macros with the new names after this lands.

## asap7

**Status**: finishing on bazel-orfs 553c1c3.

- **2026-06 toolchain upgrade (bazel-orfs 553c1c3 / OpenROAD 299f3015 / yosys 0.64)**:
  closes clean — WNS +407 → **+387 ps** (−5 %, within tolerance), util 16.0 %, 1 537 838
  logic cells (≈ baseline 1 530 612, +0.5 %), Fmax 0.18 GHz unchanged. The 1.5M-cell global
  placement is very slow (several hours under shared-machine contention) but converges
  (overflow 0.63 → <0.10). Workarounds kept. No SDC/RTL/flow change.

- **2026-07 re-validation (bazel-orfs 6c1bbca / OpenROAD b65c274c)**: **PASS** — 1 538 886
  logic cells (+0.1 %), WNS **+253 ps** (met; base +387), Fmax 0.174 GHz (−3.3 %, within
  tolerance), power 1033 mW. Very slow on the new resizer: detail route needed 5 ripup-reroute
  optimization passes (337 k → 53 k → 30 k → 973 → 41 → 0 violations) and the report/STA
  stage took ~3 h; the whole flow ~16 h and briefly overran a 16 h wall-clock cap mid-report
  (re-run from the cached route to finish). Workarounds kept, no SDC/RTL/flow change.

## nangate45

**Status**: **PASS on bazel-orfs 6c1bbca / OpenROAD b65c274c** (the 553c1c3 GP hang is resolved).

- **2026-06 toolchain upgrade (bazel-orfs 553c1c3)**: synth + floorplan complete, but the
  OpenROAD global placer **hung** on the 1.5M-cell nangate45 design — ran ~8 h, dropped to
  0 % CPU at ~iter 472 / overflow 0.63 (deadlocked), killed. Stopped at `2_floorplan`.
- **2026-07 re-validation (bazel-orfs 6c1bbca / OpenROAD b65c274c)**: **PASS** — the newer
  OpenROAD no longer hangs; global placement converges (overflow → <0.10) though it is slow:
  the new timing-driven `place_gp` runs **two** timing-driven iterations, each a full
  `repair_design` over ~1.3M nets (~295 k nets/hr), so placement alone took ~8 h and the whole
  flow ~14 h. Detail route converged cleanly (0 violations in 4 passes). Result: 1 333 473
  logic cells (+2.1 %), WNS **+5801 ps** (met; base +6035), Fmax 0.082 GHz (+2.5 %),
  power 368 mW. No SDC/RTL/flow change.
