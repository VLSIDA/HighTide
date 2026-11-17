"""Assemble Eyeriss RTL and expand physical depth banks for one platform."""
import argparse
import json
from pathlib import Path
import re


def macro_body(m):
    name, width, depth, banks = m["name"], m["width"], m["depth"], m["banks"]
    if any(not isinstance(n, int) or n <= 0 or n & (n - 1) for n in (depth, banks)):
        raise ValueError(f"{name}: depth and banks must be positive powers of two")
    if banks > depth or (banks > 1 and m.get("banking_technique") != "depth"):
        raise ValueError(f"{name}: only depth banking is supported")
    if name != f"fakeram_{width}x{depth}_" + ("1rw" if m["ports"] == {"r": 0, "w": 0, "rw": 1} else "1r1w"):
        raise ValueError(f"{name}: unsupported macro configuration")
    rw = m["ports"] == {"r": 0, "w": 0, "rw": 1}
    if not rw and m["ports"] != {"r": 1, "w": 1, "rw": 0}:
        raise ValueError(f"{name}: unsupported ports")
    if width <= 0 or str(m.get("no_wmask")).lower() != "true":
        raise ValueError(f"{name}: wrappers require positive width and unmasked writes")
    addr_bits = depth.bit_length() - 1
    bank_bits = banks.bit_length() - 1
    low_bits = addr_bits - bank_bits
    if low_bits < 1:
        raise ValueError(f"{name}: bank must contain at least two words")
    def address(port):
        return port if banks == 1 else f"{port}[{low_bits-1}:0]"
    def select(port):
        return "1'b1" if banks == 1 else f"({port}[{addr_bits-1}:{low_bits}] == BANK_ID)"
    lines = []
    if banks > 1:
        lines += [f"    wire [{width-1}:0] bank_q [0:{banks-1}];",
                  f"    reg [{bank_bits-1}:0] read_bank;",
                  f"    always @(posedge {'clka' if rw else 'clkb'})" +
                  (" if (!wea)" if rw else "") +
                  f" read_bank <= {'addra' if rw else 'addrb'}[{addr_bits-1}:{low_bits}];",
                  f"    assign {'douta' if rw else 'doutb'} = bank_q[read_bank];",
                  "    genvar bank;",
                  f"    generate for (bank = 0; bank < {banks}; bank = bank + 1) begin: banks",
                  f"        localparam [{bank_bits-1}:0] BANK_ID = bank;"]
    out = "bank_q[bank]" if banks > 1 else ("douta" if rw else "doutb")
    if rw:
        ports = [("rw0_clk", "clka"), ("rw0_ce_in", select("addra")),
                 ("rw0_we_in", "wea"), ("rw0_addr_in", address("addra")),
                 ("rw0_wd_in", "dina"), ("rw0_rd_out", out)]
    else:
        ce = "wea" if banks == 1 else f"wea && {select('addra')}"
        ports = [("w0_clk", "clka"), ("w0_ce_in", ce), ("w0_we_in", "wea"),
                 ("w0_addr_in", address("addra")), ("w0_wd_in", "dina"),
                 ("r0_clk", "clkb"), ("r0_ce_in", select("addrb")),
                 ("r0_addr_in", address("addrb")), ("r0_rd_out", out)]
    lines += [f"        {name} u_mem ("]
    lines += [f"            .{pin}({value})" + ("," if i+1 < len(ports) else "")
              for i, (pin, value) in enumerate(ports)]
    lines += ["        );"]
    if banks > 1:
        lines += ["    end endgenerate"]
    return "\n".join(lines)


def wrappers(template, cfg):
    macros = {m["name"]: m for m in cfg["srams"]}
    used = set()
    def replace(match):
        name = match[1]
        used.add(name)
        return macro_body(macros[name])
    result = re.sub(r"@(fakeram_\w+)@", replace, template)
    if used != set(macros):
        raise ValueError("wrapper template and SRAM configuration differ")
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cfg", type=Path, required=True)
    parser.add_argument("--template", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("sources", nargs="*", type=Path)
    args = parser.parse_args()
    text = ""
    for source in sorted(args.sources, key=lambda p: str(p).split("FPGA_design/src/", 1)[-1]):
        rel = "FPGA_design/src/" + str(source).split("FPGA_design/src/", 1)[-1]
        text += f"// ===== {rel} =====\n" + source.read_text() + "\n"
    text += wrappers(args.template.read_text(), json.loads(args.cfg.read_text()))
    args.out.write_text(text)


if __name__ == "__main__":
    main()
