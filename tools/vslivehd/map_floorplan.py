#!/usr/bin/env python3
"""Rename the macros of an OpenROAD macro floorplan DEF to LiveHD's flat instance names.

usage: map_floorplan.py OPENROAD.def LHD_BASELINE.def OUT.def
LiveHD prefixes the flattened scope and turns '/' into '.'; the baseline LiveHD DEF (any run of the same
netlist) supplies the exact names. Soft placement blockages are renamed the same way."""
import re, sys
src, base, out = sys.argv[1:4]
def clean(n):
    n = re.sub(r'__flat___sub_\d+\.', '', n.replace('\\', ''))
    return re.sub(r'[^A-Za-z0-9]+', '_', n).strip('_')
lhd = {}
for l in open(base):
    m = re.match(r'\s*- (\S+) (fakeram\S+|\S+) \+ (?:FIXED|PLACED)', l)
    if m and 'fakeram' in m.group(2): lhd[m.group(1)] = 1
by_suffix = {}
for n in lhd: by_suffix.setdefault(clean(n), n)
lines = open(src).read().split('\n')
res, miss, names = [], 0, {}
def ren(n):
    global miss
    c = clean(n)
    if c in by_suffix: return by_suffix[c]
    miss += 1; return n
for l in lines:
    m = re.match(r'(\s*- )(\S+)( \S+ \+ (?:FIXED|PLACED).*)', l)
    if m and 'fakeram' in m.group(3):
        res.append(m.group(1) + ren(m.group(2)) + m.group(3)); continue
    m = re.match(r'(\s*- PLACEMENT \+ SOFT \+ COMPONENT )(\S+)(.*)', l)
    if m:
        res.append(m.group(1) + ren(m.group(2)) + m.group(3)); continue
    res.append(l)
open(out, 'w').write('\n'.join(res))
print('macros', len(lhd), 'unmapped', miss)
