# Image Generation Reference

Shared reference for generating layout images and heatmaps from a HighTide
design's stage ODBs. Used by **debug-design** and **optimize-ppa**.

Everything runs through the Bazel flow — no Docker, no ORFS submodule.

## Prerequisites

Build the design through the stage you want to visualize:

```bash
bazel build //designs/<plat>/<des>:<des>_<stage>   # synth, floorplan, place, cts, grt, route, final
```

The stage ODB lands at:

```
bazel-bin/designs/<plat>/<des>/results/<plat>/<des>/base/<N>_<stage>.odb
```

Stage → file mapping:

| Stage     | ODB                              |
|-----------|----------------------------------|
| Floorplan | `2_floorplan.odb`                |
| Place     | `3_place.odb`                    |
| CTS       | `4_cts.odb`                      |
| GRT       | `5_1_grt.odb`                    |
| Route     | `5_2_route.odb`                  |
| Final     | `6_final.odb`                    |

## Final-stage gallery image (fastest path)

For a routed-design screenshot, every `hightide_design()` exposes a
built-in gallery target:

```bash
bazel build //designs/<plat>/<des>:<des>_gallery
# → bazel-bin/designs/<plat>/<des>/<des>_gallery.png
```

Internally this uses `tools/gallery/final_image.tcl` and `xvfb-run` so it
needs no display.

## Custom heatmaps on any stage

For routing congestion / placement density / RUDY / IR drop on a
specific stage, run OpenROAD directly with a heatmap Tcl script.

1. **Locate the OpenROAD binary.** It's built as a side effect of any
   design target and lives in the Bazel external repo cache:

   ```bash
   OPENROAD=$(find "$(bazel info output_base)"/external -path '*/openroad+/openroad' -type f -executable 2>/dev/null | head -1)
   ```

2. **Write the heatmap Tcl script** to a temp file (see variants below):

   ```bash
   cat > /tmp/ht_heatmap.tcl << 'TCLEOF'
   read_db $::env(ODB_FILE)
   gui::save_display_controls
   gui::set_display_controls "Heat Maps/Routing Congestion" visible true ;# 2026-11 pin renamed the control ("Heat Maps/Routing" errors GUI-0013 and hangs the GUI session)
   gui::set_heatmap Routing rebuild 1
   gui::set_heatmap Routing ShowLegend 1
   save_image -width 2048 $::env(OUTPUT_IMAGE)
   gui::restore_display_controls
   exit
   TCLEOF
   ```

3. **Run via `xvfb-run`** (no display required):

   ```bash
   ODB_FILE=$(realpath bazel-bin/designs/<plat>/<des>/results/<plat>/<des>/base/5_2_route.odb) \
   OUTPUT_IMAGE=/tmp/<des>_routing.webp \
       xvfb-run -a "$OPENROAD" -no_splash -gui /tmp/ht_heatmap.tcl
   ```

## Heatmap Tcl variants

Replace the body of `/tmp/ht_heatmap.tcl` with one of the following.

### Routing congestion
```tcl
read_db $::env(ODB_FILE)
gui::save_display_controls
gui::set_display_controls "Heat Maps/Routing Congestion" visible true ;# 2026-11 pin renamed the control ("Heat Maps/Routing" errors GUI-0013 and hangs the GUI session)
gui::set_heatmap Routing rebuild 1
gui::set_heatmap Routing ShowLegend 1
save_image -width 2048 $::env(OUTPUT_IMAGE)
gui::restore_display_controls
exit
```

### Placement density
```tcl
read_db $::env(ODB_FILE)
gui::save_display_controls
gui::set_display_controls "Heat Maps/Placement" visible true
gui::set_heatmap Placement rebuild 1
gui::set_heatmap Placement ShowLegend 1
save_image -width 2048 $::env(OUTPUT_IMAGE)
gui::restore_display_controls
exit
```

### RUDY (routing demand estimation)
```tcl
read_db $::env(ODB_FILE)
gui::save_display_controls
gui::set_display_controls "Heat Maps/RUDY" visible true
gui::set_heatmap RUDY rebuild 1
gui::set_heatmap RUDY ShowLegend 1
save_image -width 2048 $::env(OUTPUT_IMAGE)
gui::restore_display_controls
exit
```

### IR drop
```tcl
read_db $::env(ODB_FILE)
gui::save_display_controls
gui::set_display_controls "Heat Maps/IR Drop" visible true
gui::set_heatmap IRDrop rebuild 1
gui::set_heatmap IRDrop ShowLegend 1
save_image -width 2048 $::env(OUTPUT_IMAGE)
gui::restore_display_controls
exit
```

## Interactive GUI on a stage ODB

For interactive inspection (requires a display / X forwarding), every
`hightide_design()` also exposes per-stage GUI launchers:

```bash
bazel run //designs/<plat>/<des>:<des>_gui_<stage>
# e.g.
bazel run //designs/asap7/lfsr:lfsr_gui_route
```

The launcher (`tools/gui/launch_gui.sh`) loads the Liberty libs, the
ODB, the matching SDC, and the platform `setRC.tcl` before dropping into
the OpenROAD GUI shell.

---

After generating heatmap images, use the Read tool to display them and
analyze what they show — hotspots, macro placement issues, pin
congestion areas, power routing gaps, etc.
