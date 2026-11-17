#!/usr/bin/env python3
"""Simulate the LiteEth ASIC clock models using the synthesis frontend.

The vendor stub has pre-existing duplicate declarations accepted by Yosys.
Normalize with that frontend before compiling the behavioral testbench.
"""
import argparse
from pathlib import Path
import subprocess

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--yosys',default='yosys')
p.add_argument('--iverilog',default='iverilog')
p.add_argument('--vvp',default='vvp')
p.add_argument('--ivl-base',type=Path)
p.add_argument('--output',type=Path,required=True)
a=p.parse_args()
a.output.mkdir(parents=True,exist_ok=False)
source=Path('designs/src/liteeth')
normalized=a.output/'gth-normalized.v'
script=a.output/'normalize.ys'
script.write_text(f'read_verilog -sv -D USE_ASAP7_CELLS {source}/libraries/xilinx/GTHE4_CHANNEL_DUMMY.v\nproc\nwrite_verilog {normalized}\n')
with (a.output/'normalize.log').open('w') as log:
 subprocess.run([a.yosys,'-Q','-T','-s',str(script)],stdout=log,stderr=subprocess.STDOUT,check=True)
command=[a.iverilog]
if a.ivl_base:command.extend(['-B',str(a.ivl_base)])
command.extend(['-g2012','-D','USE_ASAP7_CELLS','-s','clock_models_tb','-o',str(a.output/'test.vvp'),str(source/'tests/clock_models_tb.v'),str(normalized),str(source/'libraries/xilinx/BUFG_GT.v')])
with (a.output/'compile.log').open('w') as log:
 subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,check=True)
result=subprocess.run([a.vvp,str(a.output/'test.vvp')],text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,check=True)
(a.output/'simulation.log').write_text(result.stdout)
assert 'PASS: CPLL/QPLL clock selection' in result.stdout
print(result.stdout,end='')
