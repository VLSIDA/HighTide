#!/usr/bin/env python3
"""Check the upstream Eyeriss partial-sum router's full-width data and handshake."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--rtl', type=Path, required=True)
p.add_argument('--iverilog', default='iverilog')
p.add_argument('--vvp', default='vvp')
p.add_argument('--ivl-base', type=Path)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
a.output.mkdir(parents=True, exist_ok=False)
tb = a.output / 'router_tb.v'
tb.write_text('''`timescale 1ns/1ps
module router_tb;
reg signed [20:0] pe, glb, north;
reg pv, gv, nv, pr, gr, sr, insel, outsel;
wire pir, gir, nir, pov, gov, sov;
wire signed [20:0] po, go, so;
integer i, j, k, b;
reg [20:0] expected;
Psum_Router dut(.PE_in(pe), .GLB_in(glb), .north_in(north),
 .PE_in_valid(pv), .GLB_in_valid(gv), .north_in_valid(nv),
 .PE_in_ready(pir), .GLB_in_ready(gir), .north_in_ready(nir),
 .PE_out_ready(pr), .GLB_out_ready(gr), .south_out_ready(sr),
 .PE_out_valid(pov), .GLB_out_valid(gov), .south_out_valid(sov),
 .PE_out(po), .GLB_out(go), .south_out(so),
 .data_in_sel(insel), .data_out_sel(outsel));
initial begin
 for (i=0;i<2;i=i+1) for (j=0;j<2;j=j+1)
 for (b=0;b<23;b=b+1) for (k=0;k<64;k=k+1) begin
  insel=i; outsel=j;
  glb = b<21 ? (21'b1<<b) : (b==21 ? 21'h1fffff : 21'h155555);
  north=~glb; pe=glb ^ 21'h1aaaaa;
  {pv,gv,nv,pr,gr,sr}=k;
  expected=insel ? glb : north;
  #1;
  if (po !== expected || so !== expected || go !== pe)
   $fatal(1,"21-bit data mismatch: sel=%d bit=%d expected=%h got=%h",i,b,expected,po);
  if (pir !== gr || gir !== (insel & (outsel ? pr : sr)) ||
      nir !== (~insel & (outsel ? pr : sr)) || gov !== pv ||
      pov !== (outsel & (insel ? gv : nv)) ||
      sov !== (~outsel & (insel ? gv : nv)))
   $fatal(1,"Handshake mismatch");
 end
 $display("PASS: 5888 full-width routing and handshake cases"); $finish;
end
endmodule
''')
cmd = [a.iverilog]
if a.ivl_base:
    cmd += ['-B', str(a.ivl_base)]
cmd += ['-g2012', '-s', 'router_tb', '-o', str(a.output / 'test.vvp'), str(tb), str(a.rtl)]
with (a.output / 'compile.log').open('w') as log:
    subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, check=True)
result = subprocess.run([a.vvp, str(a.output / 'test.vvp')], capture_output=True, text=True)
(a.output / 'simulation.log').write_text(result.stdout + result.stderr)
(a.output / 'metadata.json').write_text(json.dumps({
    'passed': result.returncode == 0,
    'rtl_sha256': hashlib.sha256(a.rtl.read_bytes()).hexdigest(),
    'testbench_sha256': hashlib.sha256(tb.read_bytes()).hexdigest(),
    'compile_command': cmd,
    'cases': 5888,
}, indent=2) + '\n')
print(result.stdout + result.stderr, end='')
raise SystemExit(result.returncode)
