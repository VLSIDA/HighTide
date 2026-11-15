---
name: floorplan-design
description: Floorplan and macro-placement tuning for HighTide designs — RTLMP (rtl_macro_placer) knobs and their real ORFS plumbing, fixed-grid macro placement, halos/channels/blockages, and congestion-driven floorplan debugging. Use when a design fails with GRT congestion near macros, MPL annealing errors, or needs its macro arrangement tuned; also when deciding between RTLMP annealing and a fixed macro grid.
argument-hint: "[design] [platform]"
---

# Floorplan & Macro Placement (HighTide / ORFS)

Strategy layer for macro placement. For raw OpenROAD command syntax see the
`openroad-tcl` skill (`refs/mpl.md`); for SDC/timing see `sdc-sta`.

## THE TRAP: which knobs actually work (verified on the 2026-11 pin, ORFS 3f8ab4eb)

ORFS passes `arguments = {}` entries to make as env vars **without validation**
— misspelled or unplumbed vars are SILENT NO-OPS. Verified 2026-11-15:
`RTLMP_MIN_CHANNEL_SIZE` and `RTLMP_PIN_AWARE_CHANNELS` are NOT plumbed by
this pin's ORFS (`scripts/macro_place_util.tcl` maps only the list below), so
every BUILD that sets them is running RTLMP's internal defaults. Even
`MACRO_PLACE_HALO` only feeds the *blockage file* on this pin — it is NOT
passed to `rtl_macro_placer` as `-halo_width/-halo_height`.

Before trusting any floorplan env var, grep the pin:

    grep -n 'append_env_var' <output_base>/external/orfs+/flow/scripts/macro_place_util.tcl

## Env vars that ARE plumbed (safe in `arguments = {}`)

| env var | rtl_macro_placer arg | meaning (default) |
|---|---|---|
| `RTLMP_MAX_LEVEL` | `-max_num_level` | physical-hierarchy tree depth (2). Deeper = finer clustering, slower |
| `RTLMP_MAX_INST` / `RTLMP_MIN_INST` | `-max/min_num_inst` | std-cells per cluster bounds (auto) |
| `RTLMP_MAX_MACRO` / `RTLMP_MIN_MACRO` | `-max/min_num_macro` | macros per cluster bounds (auto). Lower max = more, smaller macro clusters |
| `RTLMP_MIN_AR` | `-min_ar` | min cluster aspect ratio height/width (0.33) |
| `RTLMP_AREA_WT` | `-area_weight` | annealing cost: floorplan area (0.1) |
| `RTLMP_WIRELENGTH_WT` | `-wirelength_weight` | annealing cost: HPWL (100) — dominant by default |
| `RTLMP_OUTLINE_WT` | `-outline_weight` | penalty for clusters escaping parent outline (100) |
| `RTLMP_BOUNDARY_WT` | `-boundary_weight` | pull hard-macro clusters toward die boundary (50). Raise to push macros to edges and keep the core open |
| `RTLMP_NOTCH_WT` | `-notch_weight` | penalty for unusable dead-space notches (50) |
| `RTLMP_FENCE_{LX,LY,UX,UY}` | `-fence_*` | global fence box (µm) all macros must stay inside |
| `RTLMP_RPT_DIR` | `-report_directory` | where partition/clustering reports go |
| `RTLMP_ARGS` | — | **replaces the ENTIRE generated arg list** (see below) |

ORFS always appends `-target_util` computed from place density
(`PLACE_DENSITY` + `PLACE_DENSITY_LB_ADDON`) — unless `RTLMP_ARGS` is set.

## Command-only options (reachable ONLY via `RTLMP_ARGS` on this pin)

| option | meaning |
|---|---|
| `-halo_width W` / `-halo_height H` | keep-out halo around each macro (µm) that annealing respects |
| `-min_channel_size C` | minimum spacing between macro clusters (µm) — the routing-channel guarantee |
| `-pin_aware_channels` | size channels accounting for macro pin-edge escape demand (the fix aimed at the sky130hd perimeter-pin problem — see CLAUDE.md "RTLMP macro clustering vs fakeram perimeter pins" row) |
| `-target_util U` | std-cell area utilization inside mixed clusters (MUST re-include when using RTLMP_ARGS; ORFS normally injects it) |
| `-tolerance T` | annealing acceptance tolerance |
| `-coarsening_ratio R` | clustering coarsening aggressiveness |
| `-large_net_threshold N` | nets above this fanout ignored in HPWL (default ~50) |
| `-guidance_weight` / `-fence_weight` | cost weights for guidance regions / fences |
| `-macro_blockage_weight` / `-soft_blockage_weight` | how strongly placement blockages repel macro clusters |
| `-write_macro_placement FILE` | **dump the annealed result as place_macro commands** — the bridge from a good annealing run to a frozen `MACRO_PLACEMENT_TCL` grid file |
| `-keep_clustering_data` | retain clustering for inspection |

### RTLMP_ARGS recipe (the only way to get channels/halos on this pin)

```python
arguments = {
    # REPLACES all generated args: re-state target_util (= PLACE_DENSITY
    # + addon you want annealing to assume) and any weights you still need.
    "RTLMP_ARGS": "-target_util 0.46 -halo_width 8 -halo_height 8 "
                  "-min_channel_size 24 -pin_aware_channels "
                  "-write_macro_placement <objects>/rtlmp/macro_place.tcl",
}
```

## Fixed-grid macro placement (when annealing can't win)

When RTLMP repeatedly fails (MPL-0040 annealing error) or its placements
congest no matter the knobs (sky130hd perimeter-pin designs), freeze the
macros:

1. `tools/dump_macros.tcl` on a floorplanned/placed DB → macro names + dims
   (or `-write_macro_placement` from a decent annealing run).
2. `tools/gen_macro_grid.py` → uniform FIRM rows with guaranteed channels
   (`--chan`; sky double-sided pin escapes needed 900 µm on bp_uno's 22
   wide macros — size for opposed escapes plus through-traffic).
3. Wire as `"MACRO_PLACEMENT_TCL": [":macro_placement.tcl"]`. Macros placed
   FIRM are left alone by the post-source `rtl_macro_placer`.

Instance names in the grid file are flattened ODB paths and BREAK when the
toolchain changes hierarchy flattening (2026-11 pin: the gt2n NVDLA ram
wrapper became a real hierarchy level, `…ram_Inst.sram` → `…ram_Inst/sram`,
MPL-0020 "Couldn't find a macro"). Re-verify names against a fresh
`1_synth.odb` dump after every toolchain bump; a separator-only change is a
sed, same coordinates.

## Diagnosing macro-region congestion

- Fetch the placed DB (stage `_place` from cache), then render:
  `read_db 3_place.odb` + `global_route -allow_congestion` +
  `gui::set_display_controls "Heat Maps/Routing Congestion" visible true` +
  `gui::save_image` under `xvfb-run -a openroad -gui`.
- Hot tiles hugging macro channels → channel/halo problem (`-min_channel_size`,
  `-pin_aware_channels`, or a wider grid), NOT utilization.
- Uniform core glow → genuine density problem: lower `CORE_UTILIZATION` or
  relax the clock (less repair buffering = less wire).
- Check macro LEF OBS layers: over-conservative obstructions block
  over-the-macro routing and funnel everything into channels.

## Platform notes

- **sky130hd**: coarse pitches + fakeram perimeter pins on all four edges →
  channels are double-sided; grids with huge channels have been the only
  reliable answer so far (cnn, partition_c, bp_uno). Retry
  `-pin_aware_channels` via RTLMP_ARGS each pin bump (CLAUDE.md row).
- **gt2n (BSPDN)**: backside power frees frontside tracks, so high
  `CORE_UTILIZATION` is the intended design point — treat congestion there
  as a channel/macro problem first, not a density problem.
- **asap7**: fine pitches tolerate small channels (partition_o passes at
  util 40 with ~14 µm intent) but watch the fakeram snap-grid cfg bug
  (CLAUDE.md) and Lef58EolKeepOut plateaus on macro-heavy designs.

## Known bugs that masquerade as floorplan problems

- **MPL-0040** annealing failure → hand-place / grid (CLAUDE.md row).
- **MPL-0020** "Couldn't find a macro" → stale instance names in a grid file
  (hierarchy flattening changed), not a placement problem.
- GRT `capacity:0` tiles hugging macros on sky → pin-escape collision
  (CLAUDE.md RTLMP row), no halo/density knob clears it.
