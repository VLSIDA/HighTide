#!/usr/bin/env python3
"""
Post-process sv2v-generated Black-Parrot Verilog to handle SRAM memories:

1. Remove bsg_mem_*_synth module definitions (they contain register-array
   implementations that blow up ABC synthesis)
2. These modules will be provided by macros.v with FakeRAM instantiations

Only modules with direct register arrays are stripped:
  - bsg_mem_1rw_sync_synth (simple 1RW)
  - bsg_mem_1rw_sync_mask_write_bit_synth (bit-mask 1RW)

NOT stripped:
  - bsg_mem_1rw_sync_mask_write_byte_synth (decomposes into byte-wide
    bsg_mem_1rw_sync instances, no direct register arrays)
  - Multi-port types (1r1w, 2r1w, 3r1w) are typically small register files

Usage: python3 patch_mem.py <input.v> <output.v>

This script is idempotent and produces reproducible output.
"""
import re
import sys


# Modules whose definitions should be removed from the Verilog
# (they'll be replaced by macros.v)
STRIP_MODULES = {
    "bsg_mem_1rw_sync_synth",
    "bsg_mem_1rw_sync_mask_write_bit_synth",
}

# Stub modules to append: modules referenced by the RTL but not included
# in sv2v output. These provide synthesizable stand-ins.
STUB_MODULES = {
    # bsg_fifo_1r1w_small_hardened is instantiated when harden_p != 0
    # in bsg_fifo_1r1w_small (used by the quad-core coherence network).
    # No actual hard macro exists for ASIC synthesis, so we delegate to
    # the unhardened implementation.
    "bsg_fifo_1r1w_small_hardened": """\
module bsg_fifo_1r1w_small_hardened (
\tclk_i,
\treset_i,
\tv_i,
\tready_param_o,
\tdata_i,
\tv_o,
\tdata_o,
\tyumi_i
);
\tparameter width_p = 0;
\tparameter els_p = 0;
\tparameter ready_THEN_valid_p = 0;
\tinput clk_i;
\tinput reset_i;
\tinput v_i;
\toutput wire ready_param_o;
\tinput [width_p - 1:0] data_i;
\toutput wire v_o;
\toutput wire [width_p - 1:0] data_o;
\tinput yumi_i;
\tbsg_fifo_1r1w_small_unhardened #(
\t\t.width_p(width_p),
\t\t.els_p(els_p),
\t\t.ready_THEN_valid_p(ready_THEN_valid_p)
\t) fifo (
\t\t.clk_i(clk_i),
\t\t.reset_i(reset_i),
\t\t.v_i(v_i),
\t\t.ready_param_o(ready_param_o),
\t\t.data_i(data_i),
\t\t.v_o(v_o),
\t\t.data_o(data_o),
\t\t.yumi_i(yumi_i)
\t);
endmodule
""",
}


def patch(input_path, output_path):
    with open(input_path, "r") as f:
        content = f.read()

    lines = content.split("\n")
    out_lines = []
    i = 0
    stripped = 0

    while i < len(lines):
        line = lines[i]

        # Check for module declaration
        match = re.match(r"^module\s+(\w+)\s*\(", line)
        if match and match.group(1) in STRIP_MODULES:
            mod_name = match.group(1)
            # Skip until endmodule
            while i < len(lines) and not lines[i].strip().startswith("endmodule"):
                i += 1
            if i < len(lines):
                i += 1  # skip the endmodule line
            stripped += 1
            print(f"  Stripped module: {mod_name}")
        else:
            out_lines.append(line)
            i += 1

    # Append stub modules for missing dependencies
    stubs_added = 0
    for mod_name, mod_code in STUB_MODULES.items():
        # Only add if module is not already defined
        if not re.search(rf"^module\s+{re.escape(mod_name)}\s*\(", "\n".join(out_lines), re.MULTILINE):
            out_lines.append("")
            out_lines.append(mod_code)
            stubs_added += 1
            print(f"  Added stub module: {mod_name}")

    with open(output_path, "w") as f:
        f.write("\n".join(out_lines))

    print(f"Stripped {stripped} module definitions, added {stubs_added} stub modules")
    return stripped


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.v> <output.v>")
        sys.exit(1)
    patch(sys.argv[1], sys.argv[2])
