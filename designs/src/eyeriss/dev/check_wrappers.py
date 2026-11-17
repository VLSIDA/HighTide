"""Check all Eyeriss platform banks against LEF/LIB and synchronous SRAM models.

Run: python3 designs/src/eyeriss/dev/check_wrappers.py --iverilog /path/to/iverilog \
     --vvp /path/to/vvp --yosys /path/to/yosys
The behavioral models hold read outputs when disabled/on 1rw writes. They deliberately
exclude same-address simultaneous read/write: Liberty does not specify its value.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import subprocess
import tempfile

from generate_rtl import wrappers

BASE = Path(__file__).resolve().parents[1]
DESIGNS = BASE.parents[1]
MODULES = ["IP_Iact_Addr_SRAM_BRAM", "IP_Iact_Data_SRAM_BRAM",
           "IP_Psum_Data_SRAM_BRAM", "IP_Iact_DATA_Spad_BRAM",
           "IP_Weight_DATA_Spad_BRAM", "IP_Psum_DATA_Spad_BRAM", "IP_Psum_Rearrange_BRAM"]


def run(argv):
    result = subprocess.run(list(map(str, argv)), text=True, capture_output=True, timeout=30)
    if result.returncode:
        raise RuntimeError(f"{argv}:\n{result.stdout}\n{result.stderr}")
    return result.stdout + result.stderr


def model(m):
    name, w, d = m["name"], m["width"], m["depth"] // m["banks"]
    a = d.bit_length()-1
    if m["ports"]["rw"]:
        return f"""module {name}(input rw0_clk, rw0_ce_in, rw0_we_in,
input [{a-1}:0] rw0_addr_in, input [{w-1}:0] rw0_wd_in, output reg [{w-1}:0] rw0_rd_out);
reg [{w-1}:0] mem[0:{d-1}];
always @(posedge rw0_clk) if (rw0_ce_in) begin
 if (rw0_we_in) mem[rw0_addr_in] <= rw0_wd_in;
 else rw0_rd_out <= mem[rw0_addr_in];
end
endmodule
"""
    return f"""module {name}(input w0_clk, w0_ce_in, w0_we_in,
input [{a-1}:0] w0_addr_in, input [{w-1}:0] w0_wd_in, input r0_clk, r0_ce_in,
input [{a-1}:0] r0_addr_in, output reg [{w-1}:0] r0_rd_out);
reg [{w-1}:0] mem[0:{d-1}];
always @(posedge w0_clk) if (w0_ce_in && w0_we_in) mem[w0_addr_in] <= w0_wd_in;
always @(posedge r0_clk) if (r0_ce_in) r0_rd_out <= mem[r0_addr_in];
endmodule
"""


def testbench(m, module):
    w, d, rw = m["width"], m["depth"], m["ports"]["rw"]
    a = d.bit_length()-1
    pins = ".clka(wclk), .wea(we), .addra(wa), .dina(wd), "
    pins += ".rsta(1'b0), .douta(q)" if rw else ".clkb(rclk), .rstb(1'b0), .addrb(ra), .doutb(q)"
    return f"""module tb;
reg wclk=0, rclk=0, we=0;
reg [{a-1}:0] wa=0, ra=0;
reg [{w-1}:0] wd=0;
wire [{w-1}:0] q;
reg [{w-1}:0] held;
integer i;
{module} dut({pins});
function [{w-1}:0] value(input integer address);
 value = (address * 1103515245) ^ (address >> 3) ^ 32'h5a5a5a5a;
endfunction
task write_word(input integer address);
begin
 we=1; wa=address; wd=value(address); #2; wclk=1; #2; wclk=0; #2;
end endtask
task read_word(input integer address);
begin
 held=q; we=0; {'wa' if rw else 'ra'}=address; #2;
 if (q !== held) $fatal(1, "Output changed before read edge, address %d", address);
 {'wclk' if rw else 'rclk'}=1; #2;
 if (q !== value(address)) $fatal(1, "Bank alias/latency at %d: got %h expected %h", address, q, value(address));
 {'wclk' if rw else 'rclk'}=0; #2;
end endtask
initial begin
 for (i=0; i<{d}; i=i+1) write_word(i);
 for (i={d-1}; i>=0; i=i-1) read_word(i);
 // Writes use only the write clock and must retain the last synchronous read.
 held=q;
 for (i=0; i<{d}; i=i+1) begin
  write_word(i);
  if (q !== held) $fatal(1, "Write changed held read output at %d", i);
 end
 // Permute reads across banks rather than walking adjacent local addresses.
 for (i=0; i<{d}; i=i+1) read_word((i*53) % {d});
 $display("PASS {module}: {d} addresses, independent clocks, one-cycle read, write hold");
 $finish;
end
endmodule
"""


def check_interfaces(m, lib, lef):
    text = lib.read_text()
    expected = (m["depth"] // m["banks"]).bit_length()-1
    for port in (["rw0"] if m["ports"]["rw"] else ["w0", "r0"]):
        bus = re.search(r"bus\s*\(\s*" + port + r"_addr_in\s*\)\s*\{\s*bus_type\s*:\s*(\w+)", text)
        assert bus, (lib, port)
        typ = re.search(r"type\s*\(\s*" + bus[1] + r"\s*\)\s*\{([^}]+)", text)
        width = int(re.search(r"bit_width\s*:\s*(\d+)", typ[1])[1])
        assert width == expected, (lib, port, width, expected)
        pins = re.findall(r"^\s*PIN\s+" + port + r"_addr_in\[(\d+)\]", lef.read_text(), re.M)
        assert sorted(map(int, pins)) == list(range(expected)), (lef, port, pins)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iverilog", required=True)
    parser.add_argument("--vvp", required=True)
    parser.add_argument("--yosys", required=True)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="eyeriss-banks-") as temp:
        work = Path(temp)
        for platform in ("asap7", "nangate45", "sky130hd"):
            cfg = json.loads((BASE / f"dev/generated/fakeram_{platform}.cfg").read_text())
            rendered = work / "wrappers.v"
            rendered.write_text(wrappers((BASE / "dev/macros_template.v").read_text(), cfg))
            for m, module in zip(cfg["srams"], MODULES, strict=True):
                lib = DESIGNS / platform / "eyeriss/sram/lib" / (m["name"] + ".lib")
                lef = DESIGNS / platform / "eyeriss/sram/lef" / (m["name"] + ".lef")
                check_interfaces(m, lib, lef)
                (work / "model.v").write_text(model(m))
                (work / "tb.v").write_text(testbench(m, module))
                run([args.iverilog, "-g2012", "-s", "tb", "-o", work / "sim", rendered, work / "model.v", work / "tb.v"])
                print(platform, run([args.vvp, work / "sim"]).strip(), flush=True)
                script = work / "check.ys"
                script.write_text(f'read_liberty -lib {lib}\nread_verilog {rendered}\nhierarchy -check -top {module}\nproc\nflatten\nopt_clean\nwrite_json {work / "net.json"}\n')
                log = run([args.yosys, "-Q", "-T", "-s", script])
                assert "Resizing cell port" not in log, log
                top = json.loads((work / "net.json").read_text())["modules"][module]
                counts = Counter(c["type"] for c in top["cells"].values())
                assert counts[m["name"]] == m["banks"], counts
                assert not top.get("memories"), top.get("memories")
    print("PASS: 21 wrapper/platform combinations; LEF/LIB widths, bank counts and full address-space simulation")


if __name__ == "__main__":
    main()
