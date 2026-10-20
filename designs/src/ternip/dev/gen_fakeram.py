#!/usr/bin/env python3
"""Generate FakeRAM LEF/LIB files for ternip SRAM macros (1rw, no mask).

Ternip's pipelined memory uses a single read-write port interface
(rw0_clk/ce_in/we_in/addr_in/wd_in/rd_out) plus VDD/VSS power pins.
This generator computes geometry from the pin count and a
platform-specific area-per-bit estimate, targeting a ~2:1 aspect ratio.

Usage:
    python3 gen_fakeram.py --platform asap7 <sram_dir>
"""
import argparse
import math
import os

# (width, depth) pairs for ternip's banked pipelined memories.  Each
# pipelined_mem instance is split into multiple macros by the wrapper
# at designs/src/ternip/ternip_pipelined_mem_fakeram.v:
#
#   vector_registers.pipelined_mem (16 × 4096) → 8 × fakeram_512x16  (depth-banked)
#   tmatmul.exportvector           (16 × 1024) → 2 × fakeram_512x16  (depth-banked)
#   tmatmul.importvector           (1024 × 16) → flip-flops          (too small for a macro)
#
# fakeram_512x16 is shared between the two depth-banked memories.
SRAM_SIZES = [
    (16, 512),   # 8 Kb bank — depth-bank for the two 16-bit-wide memories
]

PLATFORM_PARAMS = {
    "asap7": {
        # Pin geometry matching bsg_fakeram asap7 output.
        # LRpinWidth = 0.024 (pin y-extent), protrusion = 3×LRpinWidth = 0.072
        # (pin x-extent into macro from the left/right edge).
        # LRpinPitch = 0.048; pins placed every 3 tracks = 0.144 µm.
        # First pin center at 6 × LRpinPitch = 0.288 µm from bottom.
        "pin_w": 0.024,
        "pin_protrusion": 0.072,
        "lr_pitch": 0.048,
        "pin_track_count": 3,
        "pin_start_tracks": 6,
        "snap_w": 0.054,
        "snap_h": 0.270,
        "area_per_bit": 0.5,
        "min_area": 100,
        "pin_layer": "M4",
        "supply_layer": "M4",
        # Match liteeth / NVDLA asap7 fakerams: alternating VDD/VSS rails at
        # 0.384 µm pitch (0.768 µm same-rail) with 0.096 µm rail width.  Our
        # earlier 0.048 µm / 0.024 µm values matched the M4 routing track grid
        # itself, leaving zero free M4 tracks between rails — every signal pin
        # escape collided with a rail edge and tripped Lef58EolKeepOut.
        "supply_track_offset": 0.480,
        "supply_track_pitch": 0.384,
        "supply_rail_w": 0.096,
        "obs_layers": ["M1", "M2", "M3"],
        "nom_voltage": 0.7,
        "op_cond_name": "tt_1.0_25.0",
    },
}


def fakeram_name(width, depth, platform):
    tech = {"asap7": "7", "nangate45": "45", "sky130hd": "130"}[platform]
    return f"fakeram{tech}_{depth}x{width}"


def gen_lef(name, width, depth, outdir, platform):
    addr_bits = max(1, math.ceil(math.log2(depth))) if depth > 1 else 1
    p = PLATFORM_PARAMS[platform]

    bits = width * depth
    area = max(bits * p["area_per_bit"], p["min_area"])
    h = math.sqrt(area / 2.0)
    w = area / h
    w = math.ceil(w / p["snap_w"]) * p["snap_w"]
    h = math.ceil(h / p["snap_h"]) * p["snap_h"]

    # 1rw port: data_in + data_out + addr + clk + ce + we = 2*W + A + 3
    total_pins = 2 * width + addr_bits + 3
    pin_pitch = p["lr_pitch"] * p["pin_track_count"]
    pins_per_side = math.ceil(total_pins / 2)
    first_center = p["lr_pitch"] * p["pin_start_tracks"]
    min_h = first_center + pins_per_side * pin_pitch + first_center
    if h < min_h:
        h = math.ceil(min_h / p["snap_h"]) * p["snap_h"]

    lines = [
        "VERSION 5.7 ;",
        'BUSBITCHARS "[]" ;',
        f"MACRO {name}",
        f"  FOREIGN {name} 0 0 ;",
        "  SYMMETRY X Y R90 ;",
        f"  SIZE {w:.3f} BY {h:.3f} ;",
        "  CLASS BLOCK ;",
    ]

    pw = p["pin_w"]
    protrusion = p["pin_protrusion"]
    pin_idx = [0]  # mutable counter for alternating left/right
    left_y = [first_center]
    right_y = [first_center]

    def add_pin(pname, direction):
        lines.extend([
            f"  PIN {pname}",
            f"    DIRECTION {direction} ;",
            "    USE SIGNAL ;",
            "    SHAPE ABUTMENT ;",
            "    PORT",
            f"      LAYER {p['pin_layer']} ;",
        ])
        if pin_idx[0] % 2 == 0:
            # Left edge
            cy = left_y[0]
            y0, y1 = cy - pw / 2, cy + pw / 2
            lines.append(f"      RECT 0.000 {y0:.3f} {protrusion:.3f} {y1:.3f} ;")
            left_y[0] += pin_pitch
        else:
            # Right edge
            cy = right_y[0]
            y0, y1 = cy - pw / 2, cy + pw / 2
            x0 = w - protrusion
            lines.append(f"      RECT {x0:.3f} {y0:.3f} {w:.3f} {y1:.3f} ;")
            right_y[0] += pin_pitch
        lines.extend([
            "    END",
            f"  END {pname}",
        ])
        pin_idx[0] += 1

    # Single read-write port
    add_pin("rw0_clk", "INPUT")
    add_pin("rw0_ce_in", "INPUT")
    add_pin("rw0_we_in", "INPUT")
    for i in range(addr_bits):
        add_pin(f"rw0_addr_in[{i}]", "INPUT")
    for i in range(width):
        add_pin(f"rw0_wd_in[{i}]", "INPUT")
    for i in range(width):
        add_pin(f"rw0_rd_out[{i}]", "OUTPUT")

    # VDD / VSS supply rails
    track_off = p["supply_track_offset"]
    track_pitch = p["supply_track_pitch"]
    rail_w = p.get("supply_rail_w", p["pin_w"])
    direction = p.get("supply_direction", "horizontal")
    span_axis = h if direction == "horizontal" else w
    track_centers = []
    n = 0
    while True:
        c = track_off + n * track_pitch
        if c + rail_w / 2 > span_axis:
            break
        if c - rail_w / 2 >= 0:
            track_centers.append(c)
        n += 1
    vdd_centers = track_centers[0::2]
    vss_centers = track_centers[1::2]

    # Supply rails must keep clear of the signal-pin protrusions at the macro
    # edges — they're on the same layer, so any overlap is a short.  Use a
    # one-track gap after the pin tip (matches liteeth: pin protrusion 0.048,
    # rail margin 0.096 → 0.048 µm gap).
    supply_margin_xy = p["pin_protrusion"] + p["lr_pitch"]

    def add_supply(net, use, centers):
        lines.extend([
            f"  PIN {net}",
            "    DIRECTION INOUT ;",
            f"    USE {use} ;",
            "    PORT",
            f"      LAYER {p['supply_layer']} ;",
        ])
        for c in sorted(centers):
            if direction == "horizontal":
                x0, x1 = supply_margin_xy, w - supply_margin_xy
                y0, y1 = c - rail_w / 2, c + rail_w / 2
            else:
                x0, x1 = c - rail_w / 2, c + rail_w / 2
                y0, y1 = supply_margin_xy, h - supply_margin_xy
            lines.append(f"      RECT {x0:.3f} {y0:.3f} {x1:.3f} {y1:.3f} ;")
        lines.extend([
            "    END",
            f"  END {net}",
        ])

    add_supply("VDD", "POWER", vdd_centers)
    add_supply("VSS", "GROUND", vss_centers)

    lines.append("  OBS")
    for layer in p["obs_layers"]:
        lines.extend([
            f"    LAYER {layer} ;",
            f"      RECT 0.000 0.000 {w:.3f} {h:.3f} ;",
        ])
    lines.extend([
        "  END",
        f"END {name}",
        "END LIBRARY",
    ])

    path = os.path.join(outdir, "lef", f"{name}.lef")
    with open(path, "w") as f:
        f.write("\n".join(lines) + "\n")
    return w, h


def gen_lib(name, width, depth, outdir, w_um, h_um, platform):
    addr_bits = max(1, math.ceil(math.log2(depth))) if depth > 1 else 1
    area = w_um * h_um
    p = PLATFORM_PARAMS[platform]
    voltage = p["nom_voltage"]
    op_cond = p["op_cond_name"]

    L = []
    L.append(f"library({name}) {{")
    L.append("    technology (cmos);")
    L.append("    delay_model : table_lookup;")
    L.append("    revision : 1.0;")
    L.append('    date : "2026-01-01 00:00:00Z";')
    L.append('    comment : "SRAM";')
    L.append('    time_unit : "1ns";')
    L.append('    voltage_unit : "1V";')
    L.append('    current_unit : "1uA";')
    L.append('    leakage_power_unit : "1uW";')
    L.append("    nom_process : 1;")
    L.append("    nom_temperature : 25.000;")
    L.append(f"    nom_voltage : {voltage};")
    L.append("    capacitive_load_unit (1,pf);")
    L.append('    pulling_resistance_unit : "1kohm";')
    L.append(f"    operating_conditions({op_cond}) {{")
    L.append("        process : 1;")
    L.append("        temperature : 25.000;")
    L.append(f"        voltage : {voltage};")
    L.append("        tree_type : balanced_tree;")
    L.append("    }")
    L.append("    default_cell_leakage_power : 0;")
    L.append("    default_fanout_load : 1;")
    L.append("    default_inout_pin_cap : 0.0;")
    L.append("    default_input_pin_cap : 0.0;")
    L.append("    default_output_pin_cap : 0.0;")
    L.append("    default_max_transition : 0.227;")
    L.append(f"    default_operating_conditions : {op_cond};")
    L.append("    default_leakage_power_density : 0.0;")
    L.append("    slew_derate_from_library : 1.000;")
    L.append("    slew_lower_threshold_pct_fall : 20.000;")
    L.append("    slew_upper_threshold_pct_fall : 80.000;")
    L.append("    slew_lower_threshold_pct_rise : 20.000;")
    L.append("    slew_upper_threshold_pct_rise : 80.000;")
    L.append("    input_threshold_pct_fall : 50.000;")
    L.append("    input_threshold_pct_rise : 50.000;")
    L.append("    output_threshold_pct_fall : 50.000;")
    L.append("    output_threshold_pct_rise : 50.000;")
    L.append(f"    lu_table_template({name}_delay) {{")
    L.append("        variable_1 : input_net_transition;")
    L.append("        variable_2 : total_output_net_capacitance;")
    L.append('            index_1 ("1000, 1001");')
    L.append('            index_2 ("1000, 1001");')
    L.append("    }")
    L.append(f"    lu_table_template({name}_slew) {{")
    L.append("        variable_1 : total_output_net_capacitance;")
    L.append('            index_1 ("1000, 1001");')
    L.append("    }")
    L.append(f"    lu_table_template({name}_constraint) {{")
    L.append("        variable_1 : related_pin_transition;")
    L.append("        variable_2 : constrained_pin_transition;")
    L.append('            index_1 ("1000, 1001");')
    L.append('            index_2 ("1000, 1001");')
    L.append("    }")
    L.append("    library_features(report_delay_calculation);")
    L.append(f"    type ({name}_DATA) {{")
    L.append("        base_type : array; data_type : bit;")
    L.append(f"        bit_width : {width}; bit_from : {width-1}; bit_to : 0; downto : true;")
    L.append("    }")
    L.append(f"    type ({name}_ADDR) {{")
    L.append("        base_type : array; data_type : bit;")
    L.append(f"        bit_width : {addr_bits}; bit_from : {addr_bits-1}; bit_to : 0; downto : true;")
    L.append("    }")
    L.append(f"    cell({name}) {{")
    L.append(f"        area : {area:.3f};")
    L.append("        interface_timing : true;")
    L.append("        dont_use : true;")
    L.append("        dont_touch : true;")

    def constraint_block(pin_name, direction, cap="0.0035", bus_type=None, extra_lines=None):
        b = []
        if bus_type:
            b.append(f"        bus({pin_name}) {{")
            b.append(f"            bus_type : {bus_type};")
        else:
            b.append(f"        pin({pin_name}) {{")
        b.append(f"            direction : {direction};")
        if direction == "input":
            b.append(f"            capacitance : {cap};")
        if extra_lines:
            b.extend(extra_lines)
        b.extend([
            "            timing() {",
            '                related_pin : "rw0_clk";',
            "                timing_type : setup_rising;",
            f"                rise_constraint({name}_constraint) {{",
            '                    index_1 ("0.010, 0.100"); index_2 ("0.010, 0.100");',
            '                    values("0.050, 0.050", "0.050, 0.050");',
            "                }",
            f"                fall_constraint({name}_constraint) {{",
            '                    index_1 ("0.010, 0.100"); index_2 ("0.010, 0.100");',
            '                    values("0.050, 0.050", "0.050, 0.050");',
            "                }",
            "            }",
            "            timing() {",
            '                related_pin : "rw0_clk";',
            "                timing_type : hold_rising;",
            f"                rise_constraint({name}_constraint) {{",
            '                    index_1 ("0.010, 0.100"); index_2 ("0.010, 0.100");',
            '                    values("0.005, 0.005", "0.005, 0.005");',
            "                }",
            f"                fall_constraint({name}_constraint) {{",
            '                    index_1 ("0.010, 0.100"); index_2 ("0.010, 0.100");',
            '                    values("0.005, 0.005", "0.005, 0.005");',
            "                }",
            "            }",
            "        }",
        ])
        return b

    # Single read-write port
    L.append('        pin(rw0_clk) { direction : input; capacitance : 0.0214; clock : true; }')
    L.extend(constraint_block("rw0_ce_in", "input"))
    L.extend(constraint_block("rw0_we_in", "input"))
    L.extend(constraint_block("rw0_addr_in", "input", bus_type=f"{name}_ADDR"))
    L.extend(constraint_block(
        "rw0_wd_in", "input", bus_type=f"{name}_DATA",
        extra_lines=[f'            memory_write() {{ address : rw0_addr_in; clocked_on : "rw0_clk"; }}'],
    ))

    L.extend([
        f"        bus(rw0_rd_out) {{",
        f"            bus_type : {name}_DATA;",
        "            direction : output;",
        "            max_capacitance : 0.500;",
        "            memory_read() { address : rw0_addr_in; }",
        "            timing() {",
        '                related_pin : "rw0_clk";',
        "                timing_type : rising_edge;",
        "                timing_sense : non_unate;",
        f"                cell_rise({name}_delay) {{",
        '                    index_1 ("0.010, 0.100"); index_2 ("0.0005, 0.500");',
        '                    values("0.200, 0.800", "0.250, 0.850");',
        "                }",
        f"                cell_fall({name}_delay) {{",
        '                    index_1 ("0.010, 0.100"); index_2 ("0.0005, 0.500");',
        '                    values("0.200, 0.800", "0.250, 0.850");',
        "                }",
        f"                rise_transition({name}_slew) {{",
        '                    index_1 ("0.0005, 0.500"); values("0.015, 0.300");',
        "                }",
        f"                fall_transition({name}_slew) {{",
        '                    index_1 ("0.0005, 0.500"); values("0.015, 0.300");',
        "                }",
        "            }",
        "        }",
        "    }",
        "}",
    ])

    path = os.path.join(outdir, "lib", f"{name}.lib")
    with open(path, "w") as f:
        f.write("\n".join(L) + "\n")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--platform", choices=list(PLATFORM_PARAMS), default="asap7")
    ap.add_argument("sram_dir")
    args = ap.parse_args()

    os.makedirs(os.path.join(args.sram_dir, "lef"), exist_ok=True)
    os.makedirs(os.path.join(args.sram_dir, "lib"), exist_ok=True)

    print(f"Generating {len(SRAM_SIZES)} ternip FakeRAM macros for {args.platform}:")
    for width, depth in SRAM_SIZES:
        name = fakeram_name(width, depth, args.platform)
        w, h = gen_lef(name, width, depth, args.sram_dir, args.platform)
        gen_lib(name, width, depth, args.sram_dir, w, h, args.platform)
        print(f"  {name}  {w:.3f} x {h:.3f} um")


if __name__ == "__main__":
    main()
