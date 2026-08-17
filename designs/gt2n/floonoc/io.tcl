# Explicit IO pin placement for floonoc_mesh_top (gt2n)
# This file is invoked via FOOTPRINT_TCL, which makes ORFS skip the default
# place_pins annealer (see flow/scripts/io_placement.tcl). All 6395 pins
# are placed by this script — the annealer never runs.
#
# Banking strategy (~1599 pins/edge): bits walk clockwise around the perimeter
# so every corner connects numerically-adjacent bits of the same bus. Starting
# at top-left and walking clockwise the index strictly decreases:
#
#   TOP    (1599): hbm_wide_out_req_o    [2987] @ top-left → [1389] @ top-right
#   RIGHT  (1599): hbm_wide_out_req_o    [1388] @ top-right → [0] mid-right,
#                  hbm_narrow_out_req_o  [979]  → [770] @ bottom-right
#   BOTTOM (1598): hbm_narrow_out_req_o  [769]  @ bottom-right → [0] mid-bottom,
#                  hbm_wide_out_rsp_i    [2103] → [1276] @ bottom-left
#   LEFT   (1599): hbm_wide_out_rsp_i    [1275] @ bottom-left → [0] mid-left,
#                  hbm_narrow_out_rsp_i  [319]  → [0],
#                  clk_i, rst_ni, test_enable_i (wraparound; not bus-continuous
#                  with top-left corner — unavoidable since bus indices terminate)
#
# Pins are placed 5 um INSIDE the die boundary (not exactly on it) so the
# pin shape is fully contained — earlier attempts with -force_to_die_boundary
# triggered GRT-0209 "pin completely outside die" on bigger-pin platforms.

# ── gt2n layer config (from platforms/gt2n/config.mk + lef/gt2_tech.lef) ──
#
# IO_PLACER_H = M2 (HORIZONTAL layer → left/right edge pins)
#   M2: WIDTH 0.012 um, PITCH 0.024 um
#   hor_offset = WIDTH/2 = 0.006 um  (center of first y-track)
#   hor_pitch  = 0.024 um
#
# IO_PLACER_V = M3 (VERTICAL layer → top/bottom edge pins)
#   M3: WIDTH 0.014 um, PITCH 0.028 um
#   ver_offset = WIDTH/2 = 0.007 um  (center of first x-track)
#   ver_pitch  = 0.028 um
#
# Pin-fit check (129×129 die, end_margin 5.0 um each side → 119 um effective edge):
#   top/bottom (M3 vertical, 1598 gaps): 1598 × 0.028 = 44.744 um < 119 um  ✓
#   left/right (M2 horizontal, 1598 gaps): 1598 × 0.024 = 38.352 um < 119 um  ✓
#
# PSM-0069 note: edge_margin is kept at 5.0 um (no sky130hd-style reduction needed).
# The gt2n PDN is entirely backside: BPR followpins → BM1 → BM2, with only
# BPR↔BM1 and BM1↔BM2 vias — all on the backside stack. There are no frontside
# power stripes or vias on M1-M13. The PSM-0069 mechanism requires frontside PDN
# vias passing through intermediate frontside layers where IO pin DRC halos land;
# that path does not exist in gt2n, so the obstruction risk is absent.

set hor_layer  M2    ;# IO_PLACER_H — pins on left/right edges
set ver_layer  M3    ;# IO_PLACER_V — pins on top/bottom edges
set hor_offset 0.006 ;# M2 y_offset = M2_width/2 = 0.012/2
set hor_pitch  0.024 ;# M2 y_pitch
set ver_offset 0.007 ;# M3 x_offset = M3_width/2 = 0.014/2
set ver_pitch  0.028 ;# M3 x_pitch

set edge_margin 5.0  ;# distance from die edge — safe; see PSM-0069 note above
set end_margin  5.0  ;# distance from corner along the edge

proc bus_pins {name high {low 0}} {
    set pins {}
    for {set i $low} {$i <= $high} {incr i} {
        lappend pins "${name}\[${i}\]"
    }
    return $pins
}

proc snap {val offset pitch} {
    set k [expr {round(($val - $offset) / $pitch)}]
    return [expr {$offset + $k * $pitch}]
}

proc place_pins_on_edge {edge layer pins} {
    upvar edge_margin em end_margin sm
    upvar hor_offset ho hor_pitch hp ver_offset vo ver_pitch vp

    set n [llength $pins]
    if {$n == 0} return
    lassign [ord::get_die_area] lx ly ux uy

    switch $edge {
        left - right {
            set fixed_x [expr {$edge eq "left" ? $lx + $em : $ux - $em}]
            set lo [expr {$ly + $sm}]
            set hi [expr {$uy - $sm}]
            for {set i 0} {$i < $n} {incr i} {
                set frac [expr {($i + 0.5) / double($n)}]
                set raw_y [expr {$lo + $frac * ($hi - $lo)}]
                set y [snap $raw_y $ho $hp]
                place_pin -pin_name [lindex $pins $i] -layer $layer \
                    -location [list $fixed_x $y]
            }
        }
        top - bottom {
            set fixed_y [expr {$edge eq "top" ? $uy - $em : $ly + $em}]
            set lo [expr {$lx + $sm}]
            set hi [expr {$ux - $sm}]
            for {set i 0} {$i < $n} {incr i} {
                set frac [expr {($i + 0.5) / double($n)}]
                set raw_x [expr {$lo + $frac * ($hi - $lo)}]
                set x [snap $raw_x $vo $vp]
                place_pin -pin_name [lindex $pins $i] -layer $layer \
                    -location [list $x $fixed_y]
            }
        }
    }
}

# ── Per-edge pin lists ──
# place_pins_on_edge places list[0] at the LOW-coord end (left for top/bottom,
# bottom for left/right) and list[n-1] at the HIGH end. We construct each list
# so the perimeter walk reads in clockwise order with corners aligned.
#
# TOP (left → right): index 2987 down to 1389
set top_pins [lreverse [bus_pins hbm_wide_out_req_o 2987 1389]]
# RIGHT (bottom → top): narrow_req[770..979] then wide_req[0..1388]
# (puts [770] at bottom-right corner adjacent to [769] on bottom edge,
#  and [1388] at top-right corner adjacent to [1389] on top edge)
set right_pins [concat \
    [bus_pins hbm_narrow_out_req_o 979 770] \
    [bus_pins hbm_wide_out_req_o 1388 0]]
# BOTTOM (left → right): wide_rsp[1276..2103] then narrow_req[0..769]
# ([1276] at bottom-left adjacent to [1275] on left edge,
#  [769] at bottom-right adjacent to [770] on right edge)
set bottom_pins [concat \
    [bus_pins hbm_wide_out_rsp_i 2103 1276] \
    [bus_pins hbm_narrow_out_req_o 769 0]]
# LEFT (bottom → top): wide_rsp[1275..0] then narrow_rsp[319..0] then ctrl
# ([1275] at bottom-left adjacent to [1276] on bottom edge)
set left_pins [concat \
    [lreverse [bus_pins hbm_wide_out_rsp_i 1275 0]] \
    [lreverse [bus_pins hbm_narrow_out_rsp_i 319 0]] \
    {clk_i rst_ni test_enable_i}]

place_pins_on_edge top    $ver_layer $top_pins
place_pins_on_edge right  $hor_layer $right_pins
place_pins_on_edge bottom $ver_layer $bottom_pins
place_pins_on_edge left   $hor_layer $left_pins
