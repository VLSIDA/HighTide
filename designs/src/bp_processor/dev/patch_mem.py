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

    with open(output_path, "w") as f:
        f.write("\n".join(out_lines))

    print(f"Stripped {stripped} module definitions")
    return stripped


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.v> <output.v>")
        sys.exit(1)
    patch(sys.argv[1], sys.argv[2])
