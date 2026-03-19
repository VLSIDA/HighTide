#!/usr/bin/env python3
"""
Generate FakeRAM LEF/LIB files and macros.v for Black-Parrot SRAM memories.

The bsg_mem_*_synth modules in Black-Parrot use parameterized register arrays.
Large instances (>= THRESHOLD bits) are mapped to FakeRAM macros to prevent
ABC synthesis from running out of memory. Small instances fall back to
register-array implementations that synthesize to flip-flops.

Memory configurations are determined from Yosys memory analysis of the
bp_processor quad-core (e_bp_multicore_4_cfg) design.

Usage: python3 gen_fakeram.py <sram_dir> <macros.v>

This script generates:
  - sram_dir/lef/fakeram_DxW_1rw.lef for each large memory config
  - sram_dir/lib/fakeram_DxW_1rw.lib for each large memory config
  - macros.v with replacement bsg_mem_*_synth modules
"""
import math
import os
import sys

# ── Memory configurations ────────────────────────────────────────────────
# Threshold: memories with >= THRESHOLD bits get FakeRAM macros.
# Smaller memories synthesize as flip-flops (fine for ABC).
THRESHOLD_BITS = 1024

# Known large memory configurations from Yosys analysis of bp_processor
# quad-core. Format: (depth, width, count).
# These come from bsg_mem_1rw_sync_synth and bsg_mem_1rw_sync_mask_write_bit_synth.
# The byte-mask module (bsg_mem_1rw_sync_mask_write_byte_synth) decomposes into
# byte-wide bsg_mem_1rw_sync_synth instances (e.g., 512x64 byte-mask → 8x 512x8).
LARGE_CONFIGS = [
    (512, 64),    # 32768 bits - data cache, instruction cache
    (64,  184),   # 11776 bits - TLB/tag arrays
    (512, 8),     # 4096  bits - byte lanes from byte-mask memories
    (64,  50),    # 3200  bits - tag arrays
    (32,  66),    # 2112  bits - small tag arrays
    (32,  48),    # 1536  bits - small tag arrays
    (8,   174),   # 1392  bits - TLB entries
    (128, 8),     # 1024  bits - byte lanes from byte-mask memories
]


def fakeram_name(depth, width):
    return f"fakeram_{depth}x{width}_1rw"


# ── LEF generation ───────────────────────────────────────────────────────
def gen_lef(name, width, depth, outdir):
    addr_bits = max(1, math.ceil(math.log2(depth))) if depth > 1 else 1

    # ASAP7 grid constants
    pin_w = 0.024
    pin_pitch = 0.144
    snap_w = 0.054
    snap_h = 0.270

    # Estimate macro size from bit count
    bits = width * depth
    area = max(bits * 0.5, 100)
    h = math.sqrt(area / 2.0)
    w = area / h
    w = math.ceil(w / snap_w) * snap_w
    h = math.ceil(h / snap_h) * snap_h

    # Ensure enough height for all pins
    total_pins = width * 3 + addr_bits + 3  # wd_in, w_mask_in, rd_out, addr_in, clk, ce, we
    min_h = pin_pitch * (total_pins + 4)
    if h < min_h:
        h = math.ceil(min_h / snap_h) * snap_h

    lines = [
        "VERSION 5.7 ;",
        'BUSBITCHARS "[]" ;',
        f"MACRO {name}",
        f"  FOREIGN {name} 0 0 ;",
        "  SYMMETRY X Y R90 ;",
        f"  SIZE {w:.3f} BY {h:.3f} ;",
        "  CLASS BLOCK ;",
    ]

    y_pos = pin_pitch

    def add_pin(pname, direction):
        nonlocal y_pos
        lines.extend([
            f"  PIN {pname}",
            f"    DIRECTION {direction} ;",
            "    USE SIGNAL ;",
            "    SHAPE ABUTMENT ;",
            "    PORT",
            "      LAYER M4 ;",
            f"      RECT 0.000 {y_pos:.3f} {pin_w:.3f} {y_pos + pin_w:.3f} ;",
            "    END",
            f"  END {pname}",
        ])
        y_pos += pin_pitch

    for i in range(width):
        add_pin(f"wd_in[{i}]", "INPUT")
    for i in range(width):
        add_pin(f"w_mask_in[{i}]", "INPUT")
    for i in range(addr_bits):
        add_pin(f"addr_in[{i}]", "INPUT")
    for i in range(width):
        add_pin(f"rd_out[{i}]", "OUTPUT")
    add_pin("clk", "INPUT")
    add_pin("ce_in", "INPUT")
    add_pin("we_in", "INPUT")

    lines.extend([
        "  OBS",
        "    LAYER M1 ;",
        f"      RECT 0.000 0.000 {w:.3f} {h:.3f} ;",
        "    LAYER M2 ;",
        f"      RECT 0.000 0.000 {w:.3f} {h:.3f} ;",
        "    LAYER M3 ;",
        f"      RECT 0.000 0.000 {w:.3f} {h:.3f} ;",
        "  END",
        f"END {name}",
        "END LIBRARY",
    ])

    path = os.path.join(outdir, "lef", f"{name}.lef")
    with open(path, "w") as f:
        f.write("\n".join(lines) + "\n")
    return w, h


# ── LIB generation ───────────────────────────────────────────────────────
def gen_lib(name, width, depth, outdir, w_um, h_um):
    addr_bits = max(1, math.ceil(math.log2(depth))) if depth > 1 else 1
    area = w_um * h_um

    lines = [
        f"library({name}) {{",
        "    technology (cmos);",
        "    delay_model : table_lookup;",
        "    revision : 1.0;",
        '    date : "2025-01-01 00:00:00Z";',
        '    comment : "SRAM";',
        '    time_unit : "1ns";',
        '    voltage_unit : "1V";',
        '    current_unit : "1uA";',
        '    leakage_power_unit : "1uW";',
        "    nom_process : 1;",
        "    nom_temperature : 25.000;",
        "    nom_voltage : 0.7;",
        '    capacitive_load_unit (1,pf);',
        '    pulling_resistance_unit : "1kohm";',
        "    operating_conditions(tt_0.7_25.0) {",
        "        process : 1;",
        "        temperature : 25.000;",
        "        voltage : 0.7;",
        "        tree_type : balanced_tree;",
        "    }",
        "    default_cell_leakage_power : 0;",
        "    default_fanout_load : 1;",
        "    default_inout_pin_cap : 0.0;",
        "    default_input_pin_cap : 0.0;",
        "    default_output_pin_cap : 0.0;",
        "    default_max_transition : 0.227;",
        "    default_operating_conditions : tt_0.7_25.0;",
        "    default_leakage_power_density : 0.0;",
        "    slew_derate_from_library : 1.000;",
        "    slew_lower_threshold_pct_fall : 20.000;",
        "    slew_upper_threshold_pct_fall : 80.000;",
        "    slew_lower_threshold_pct_rise : 20.000;",
        "    slew_upper_threshold_pct_rise : 80.000;",
        "    input_threshold_pct_fall : 50.000;",
        "    input_threshold_pct_rise : 50.000;",
        "    output_threshold_pct_fall : 50.000;",
        "    output_threshold_pct_rise : 50.000;",
        f"    lu_table_template({name}_delay) {{",
        "        variable_1 : input_net_transition;",
        "        variable_2 : total_output_net_capacitance;",
        '            index_1 ("1000, 1001");',
        '            index_2 ("1000, 1001");',
        "    }",
        f"    lu_table_template({name}_slew) {{",
        "        variable_1 : total_output_net_capacitance;",
        '            index_1 ("1000, 1001");',
        "    }",
        f"    lu_table_template({name}_constraint) {{",
        "        variable_1 : related_pin_transition;",
        "        variable_2 : constrained_pin_transition;",
        '            index_1 ("1000, 1001");',
        '            index_2 ("1000, 1001");',
        "    }",
        "    library_features(report_delay_calculation);",
        f"    type ({name}_DATA) {{",
        "        base_type : array; data_type : bit;",
        f"        bit_width : {width}; bit_from : {width-1}; bit_to : 0; downto : true;",
        "    }",
        f"    type ({name}_ADDR) {{",
        "        base_type : array; data_type : bit;",
        f"        bit_width : {addr_bits}; bit_from : {addr_bits-1}; bit_to : 0; downto : true;",
        "    }",
        f"    cell({name}) {{",
        f"        area : {area:.3f};",
        "        interface_timing : true;",
        "        dont_use : true;",
        "        dont_touch : true;",
        "        pin(clk) { direction : input; capacitance : 0.0214; clock : true; }",
    ]

    def constraint_block(pin_name, direction, cap="0.0035", bus_type=None, extra=""):
        block = []
        if bus_type:
            block.append(f"        bus({pin_name}) {{")
            block.append(f"            bus_type : {bus_type};")
        else:
            block.append(f"        pin({pin_name}) {{")
        block.append(f"            direction : {direction};")
        if direction == "input":
            block.append(f"            capacitance : {cap};")
        if extra:
            block.append(extra)
        block.extend([
            "            timing() {",
            '                related_pin : "clk";',
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
            '                related_pin : "clk";',
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
        return block

    lines.extend(constraint_block("ce_in", "input"))
    lines.extend(constraint_block("we_in", "input"))
    lines.extend(constraint_block("addr_in", "input", bus_type=f"{name}_ADDR"))
    lines.extend(constraint_block("wd_in", "input", bus_type=f"{name}_DATA",
                                  extra=f'            memory_write() {{ address : addr_in; clocked_on : "clk"; }}'))
    lines.extend(constraint_block("w_mask_in", "input", bus_type=f"{name}_DATA"))

    lines.extend([
        f"        bus(rd_out) {{",
        f"            bus_type : {name}_DATA;",
        "            direction : output;",
        "            max_capacitance : 0.500;",
        "            memory_read() { address : addr_in; }",
        "            timing() {",
        '                related_pin : "clk";',
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
        f.write("\n".join(lines) + "\n")


# ── macros.v generation ──────────────────────────────────────────────────
def gen_macros(large_configs, macros_path):
    """Generate macros.v with replacement bsg_mem_*_synth module definitions.

    Each module uses generate if/else to select between FakeRAM instantiation
    (for large configs) and register-array fallback (for small configs).
    """
    lines = [
        "// Auto-generated FakeRAM-backed bsg_mem_*_synth replacements.",
        "// Large memories (>= %d bits) use FakeRAM macros." % THRESHOLD_BITS,
        "// Small memories fall back to register-array implementation.",
        "//",
        "// Generated by gen_fakeram.py — do not edit manually.",
        "",
    ]

    # ── bsg_mem_1rw_sync_synth ────────────────────────────────────────
    lines.extend([
        "module bsg_mem_1rw_sync_synth (",
        "\tclk_i,",
        "\tv_i,",
        "\treset_i,",
        "\tdata_i,",
        "\taddr_i,",
        "\tw_i,",
        "\tdata_o",
        ");",
        "\tparameter width_p = 0;",
        "\tparameter els_p = 0;",
        "\tparameter latch_last_read_p = 0;",
        "\tparameter addr_width_lp = ((els_p == 1) || (els_p == 0) ? 1 : $clog2(els_p));",
        "\tparameter verbose_p = 1;",
        "\tinput clk_i;",
        "\tinput v_i;",
        "\tinput reset_i;",
        "\tinput [(width_p < 1 ? 0 : width_p - 1):0] data_i;",
        "\tinput [addr_width_lp - 1:0] addr_i;",
        "\tinput w_i;",
        "\toutput wire [(width_p < 1 ? 0 : width_p - 1):0] data_o;",
        "\twire unused = reset_i;",
        "\tgenerate",
        "\t\tif ((width_p == 0) || (els_p == 0)) begin : z",
        "\t\t\twire unused0 = &{clk_i, v_i, data_i, addr_i, w_i};",
        "\t\t\tassign data_o = 1'sb0;",
        "\t\tend",
    ])

    # FakeRAM branches for each large config
    for depth, width in large_configs:
        fname = fakeram_name(depth, width)
        addr_bits = max(1, math.ceil(math.log2(depth))) if depth > 1 else 1
        lines.extend([
            f"\t\telse if ((els_p == {depth}) && (width_p == {width})) begin : fakeram_{depth}x{width}",
            f"\t\t\t{fname} mem (",
            "\t\t\t\t.clk(clk_i),",
            "\t\t\t\t.ce_in(v_i),",
            "\t\t\t\t.we_in(w_i),",
            f"\t\t\t\t.w_mask_in({{{width}{{w_i}}}}),",
            "\t\t\t\t.addr_in(addr_i),",
            "\t\t\t\t.wd_in(data_i),",
            "\t\t\t\t.rd_out(data_o)",
            "\t\t\t);",
            "\t\tend",
        ])

    # Register-array fallback for small memories
    lines.extend([
        "\t\telse begin : nz",
        "\t\t\treg [addr_width_lp - 1:0] addr_r;",
        "\t\t\treg [width_p - 1:0] mem [els_p - 1:0];",
        "\t\t\twire read_en;",
        "\t\t\twire [width_p - 1:0] data_out;",
        "\t\t\twire [addr_width_lp - 1:0] addr_li = (els_p > 0 ? addr_i : {addr_width_lp {1'sb0}});",
        "\t\t\tassign read_en = v_i & ~w_i;",
        "\t\t\tassign data_out = mem[addr_r];",
        "\t\t\talways @(posedge clk_i)",
        "\t\t\t\tif (read_en)",
        "\t\t\t\t\taddr_r <= addr_li;",
        "\t\t\t\telse",
        "\t\t\t\t\taddr_r <= 1'sbx;",
        "\t\t\tif (latch_last_read_p) begin : llr",
        "\t\t\t\twire read_en_r;",
        "\t\t\t\tbsg_dff #(.width_p(1)) read_en_dff(",
        "\t\t\t\t\t.clk_i(clk_i),",
        "\t\t\t\t\t.data_i(read_en),",
        "\t\t\t\t\t.data_o(read_en_r)",
        "\t\t\t\t);",
        "\t\t\t\tbsg_dff_en_bypass #(.width_p(width_p)) dff_bypass(",
        "\t\t\t\t\t.clk_i(clk_i),",
        "\t\t\t\t\t.en_i(read_en_r),",
        "\t\t\t\t\t.data_i(data_out),",
        "\t\t\t\t\t.data_o(data_o)",
        "\t\t\t\t);",
        "\t\t\tend",
        "\t\t\telse begin : no_llr",
        "\t\t\t\tassign data_o = data_out;",
        "\t\t\tend",
        "\t\t\talways @(posedge clk_i)",
        "\t\t\t\tif (v_i & w_i)",
        "\t\t\t\t\tmem[addr_li] <= data_i;",
        "\t\tend",
        "\tendgenerate",
        "endmodule",
        "",
    ])

    # ── bsg_mem_1rw_sync_mask_write_bit_synth ─────────────────────────
    lines.extend([
        "module bsg_mem_1rw_sync_mask_write_bit_synth (",
        "\tclk_i,",
        "\treset_i,",
        "\tdata_i,",
        "\taddr_i,",
        "\tv_i,",
        "\tw_mask_i,",
        "\tw_i,",
        "\tdata_o",
        ");",
        "\tparameter width_p = 0;",
        "\tparameter els_p = 0;",
        "\tparameter latch_last_read_p = 0;",
        "\tparameter addr_width_lp = ((els_p == 1) || (els_p == 0) ? 1 : $clog2(els_p));",
        "\tinput clk_i;",
        "\tinput reset_i;",
        "\tinput [(width_p < 1 ? 0 : width_p - 1):0] data_i;",
        "\tinput [addr_width_lp - 1:0] addr_i;",
        "\tinput v_i;",
        "\tinput [(width_p < 1 ? 0 : width_p - 1):0] w_mask_i;",
        "\tinput w_i;",
        "\toutput wire [(width_p < 1 ? 0 : width_p - 1):0] data_o;",
        "\twire unused = reset_i;",
        "\tgenerate",
        "\t\tif ((width_p == 0) || (els_p == 0)) begin : z",
        "\t\t\twire unused0 = &{clk_i, data_i, addr_i, v_i, w_mask_i, w_i};",
        "\t\t\tassign data_o = 1'sb0;",
        "\t\tend",
    ])

    # FakeRAM branches for each large config
    for depth, width in large_configs:
        fname = fakeram_name(depth, width)
        lines.extend([
            f"\t\telse if ((els_p == {depth}) && (width_p == {width})) begin : fakeram_{depth}x{width}",
            f"\t\t\t{fname} mem (",
            "\t\t\t\t.clk(clk_i),",
            "\t\t\t\t.ce_in(v_i),",
            "\t\t\t\t.we_in(w_i),",
            "\t\t\t\t.w_mask_in(w_mask_i),",
            "\t\t\t\t.addr_in(addr_i),",
            "\t\t\t\t.wd_in(data_i),",
            "\t\t\t\t.rd_out(data_o)",
            "\t\t\t);",
            "\t\tend",
        ])

    # Register-array fallback for small memories
    lines.extend([
        "\t\telse begin : nz",
        "\t\t\treg [addr_width_lp - 1:0] addr_r;",
        "\t\t\treg [width_p - 1:0] mem [els_p - 1:0];",
        "\t\t\twire read_en;",
        "\t\t\twire [addr_width_lp - 1:0] addr_li = (els_p > 1 ? addr_i : {addr_width_lp {1'sb0}});",
        "\t\t\tassign read_en = v_i & ~w_i;",
        "\t\t\talways @(posedge clk_i)",
        "\t\t\t\tif (read_en)",
        "\t\t\t\t\taddr_r <= addr_li;",
        "\t\t\t\telse",
        "\t\t\t\t\taddr_r <= 1'sbx;",
        "\t\t\twire [width_p - 1:0] data_out;",
        "\t\t\tassign data_out = mem[addr_r];",
        "\t\t\tif (latch_last_read_p) begin : llr",
        "\t\t\t\twire read_en_r;",
        "\t\t\t\tbsg_dff #(.width_p(1)) read_en_dff(",
        "\t\t\t\t\t.clk_i(clk_i),",
        "\t\t\t\t\t.data_i(read_en),",
        "\t\t\t\t\t.data_o(read_en_r)",
        "\t\t\t\t);",
        "\t\t\t\tbsg_dff_en_bypass #(.width_p(width_p)) dff_bypass(",
        "\t\t\t\t\t.clk_i(clk_i),",
        "\t\t\t\t\t.en_i(read_en_r),",
        "\t\t\t\t\t.data_i(data_out),",
        "\t\t\t\t\t.data_o(data_o)",
        "\t\t\t\t);",
        "\t\t\tend",
        "\t\t\telse begin : no_llr",
        "\t\t\t\tassign data_o = data_out;",
        "\t\t\tend",
        "\t\t\talways @(posedge clk_i)",
        "\t\t\t\tif (v_i & w_i) begin : sv2v_autoblock_1",
        "\t\t\t\t\tinteger i;",
        "\t\t\t\t\tfor (i = 0; i < width_p; i = i + 1)",
        "\t\t\t\t\t\tif (w_mask_i[i])",
        "\t\t\t\t\t\t\tmem[addr_li][i] <= data_i[i];",
        "\t\t\t\tend",
        "\t\tend",
        "\tendgenerate",
        "endmodule",
        "",
    ])

    with open(macros_path, "w") as f:
        f.write("\n".join(lines) + "\n")


# ── Main ─────────────────────────────────────────────────────────────────
def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <sram_dir> <macros.v>")
        sys.exit(1)

    sram_dir = sys.argv[1]
    macros_path = sys.argv[2]

    os.makedirs(os.path.join(sram_dir, "lef"), exist_ok=True)
    os.makedirs(os.path.join(sram_dir, "lib"), exist_ok=True)

    # Clean old FakeRAM files
    for subdir in ("lef", "lib"):
        d = os.path.join(sram_dir, subdir)
        for f in os.listdir(d):
            if f.startswith("fakeram_"):
                os.remove(os.path.join(d, f))

    print(f"Generating FakeRAM files for {len(LARGE_CONFIGS)} large memory configs:")
    for depth, width in LARGE_CONFIGS:
        bits = depth * width
        name = fakeram_name(depth, width)
        print(f"  {name} ({bits} bits)")
        w, h = gen_lef(name, width, depth, sram_dir)
        gen_lib(name, width, depth, sram_dir, w, h)

    print(f"\nGenerating {macros_path}...")
    gen_macros(LARGE_CONFIGS, macros_path)

    # Print config.mk snippet
    print("\n# config.mk ADDITIONAL_LEFS entries:")
    for depth, width in sorted(LARGE_CONFIGS):
        name = fakeram_name(depth, width)
        print(f"#   ...sram/lef/{name}.lef")

    print("\n# config.mk ADDITIONAL_LIBS entries:")
    for depth, width in sorted(LARGE_CONFIGS):
        name = fakeram_name(depth, width)
        print(f"#   ...sram/lib/{name}.lib")


if __name__ == "__main__":
    main()
