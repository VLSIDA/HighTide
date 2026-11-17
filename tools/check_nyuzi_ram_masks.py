#!/usr/bin/env python3
"""Check whole-word Nyuzi wrapper writes against the pinned FakeRAM generator."""
import argparse
import hashlib
import importlib.util
import json
import math
from pathlib import Path
import subprocess
import sys
sys.dont_write_bytecode = True
from types import SimpleNamespace

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--unmasked',action='store_true',help='Check the legacy unmasked interface without the ASAP7 define')
p.add_argument('--iverilog',default='iverilog');p.add_argument('--vvp',default='vvp')
p.add_argument('--ivl-base',type=Path);p.add_argument('--output',type=Path,required=True)
p.add_argument('--wrappers',type=Path,default=Path('designs/src/NyuziProcessor/macros.v'))
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
source=Path('tools/bsg_fakeram/scripts/utils/generate_verilog.py')
spec=importlib.util.spec_from_file_location('fakeram_verilog',source);generator=importlib.util.module_from_spec(spec);spec.loader.exec_module(generator)
cfg=Path('designs/src/NyuziProcessor/dev/generated/fakeram_asap7.cfg')
memories=json.loads(cfg.read_text())['srams'];models=[];decl=[];drive_one=[];drive_zero=[];check_one=[];check_zero=[]
for i,mem in enumerate(memories):
 width,depth=mem['width'],mem['depth'];ports=mem['ports'];assert ports['w']==1 and ports['rw']==0
 assert mem['write_granularity']==1
 obj=SimpleNamespace(name=mem['name'],depth=depth,width_in_bits=width,r_ports=ports['r'],w_ports=1,rw_ports=0,write_mode='read_first',has_wmask=not a.unmasked,write_granularity=1,results_dir=str(a.output))
 generator.generate_verilog(obj);models.append(a.output/(obj.name+'.v'))
 addr=math.ceil(math.log2(depth));wrapper=f"fakeram_{ports['r']}r1w_{width}x{depth}"
 decl.append(f'reg [{width-1}:0] wd{i}=0; wire [{width-1}:0] q{i}a;')
 connections=[f'.clk(clk)',f'.write_en(we)',f'.write_addr({addr}\'d{depth-1})',f'.write_data(wd{i})']
 if ports['r']==1:connections += [f'.read_en(1\'b1)',f'.read_addr({addr}\'d{depth-1})',f'.read_data(q{i}a)']
 else:
  assert ports['r']==2
  decl.append(f'wire [{width-1}:0] q{i}b;')
  connections += [f'.read1_en(1\'b1)',f'.read1_addr({addr}\'d{depth-1})',f'.read1_data(q{i}a)',f'.read2_en(1\'b1)',f'.read2_addr({addr}\'d{depth-1})',f'.read2_data(q{i}b)']
 decl.append(f'{wrapper} dut{i}('+','.join(connections)+');')
 drive_one.append(f'wd{i}=\'1;');drive_zero.append(f'wd{i}=\'0;')
 for suffix in ('a','b') if ports['r']==2 else ('a',):
  check_one.append(f'if(q{i}{suffix} !== {{{width}{{1\'b1}}}})$fatal(1,"{wrapper}: whole-word one write failed");')
  check_zero.append(f'if(q{i}{suffix} !== {{{width}{{1\'b0}}}})$fatal(1,"{wrapper}: whole-word zero write failed");')
tb=a.output/'readback_tb.v'
tb.write_text('`timescale 1ns/1ps\nmodule readback_tb; reg clk=0,we=0; always #5 clk=~clk;\n'+'\n'.join(decl)+'\ninitial begin\n@(negedge clk); we=1;\n'+'\n'.join(drive_one)+'\n@(negedge clk); we=0;\n@(negedge clk);\n'+'\n'.join(check_one)+'\n'+'\n'.join(drive_zero)+'\n@(negedge clk);\n'+'\n'.join(check_one)+'\nwe=1;\n@(negedge clk); we=0;\n@(negedge clk);\n'+'\n'.join(check_zero)+f'\n$display("PASS: {len(memories)} Nyuzi SRAM wrappers write/read all bits, both read ports and disabled writes"); $finish;\nend\nendmodule\n')
cmd=[a.iverilog]
if a.ivl_base:cmd+=['-B',str(a.ivl_base)]
if not a.unmasked:cmd+=['-D','USE_ASAP7_CELLS']
cmd+=['-g2012','-s','readback_tb','-o',str(a.output/'test.vvp'),str(tb),str(a.wrappers),*map(str,models)]
with (a.output/'compile.log').open('w') as log:subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,check=True)
result=subprocess.run([a.vvp,str(a.output/'test.vvp')],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
(a.output/'simulation.log').write_text(result.stdout)
(a.output/'metadata.json').write_text(json.dumps({'exit_code':result.returncode,'macro_interface':'unmasked' if a.unmasked else 'asap7_masked','wrapper_sha256':hashlib.sha256(a.wrappers.read_bytes()).hexdigest(),'generator_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'cfg_sha256':hashlib.sha256(cfg.read_bytes()).hexdigest(),'compile_command':cmd,'memories':len(memories)},indent=2)+'\n')
print(result.stdout,end='');raise SystemExit(result.returncode)
