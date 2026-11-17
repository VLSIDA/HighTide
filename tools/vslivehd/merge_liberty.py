#!/usr/bin/env python3
"""Merge Liberty files that share units into ONE library group.

LiveHD's `synth.liberty` is a single path (`lhd synth`, `lhd pass abc` and the
OpenTimer pass all read it), while the ORFS flow reads several standard-cell
libraries plus per-design macro libraries.  This script keeps the header
attributes of the first library, appends every `cell` group of the others and
adds any table template they define that the first library lacks.  It refuses
libraries whose unit attributes differ and templates/cells that are defined
twice with different bodies, so a unit or definition mismatch is an error
rather than a silently wrong timing number.

`--dont-use PATTERN` (repeatable, fnmatch on the cell name) adds `dont_use : true`
to matching cells, the Liberty spelling of ORFS's DONT_USE_CELLS, so a reader
that honours the attribute (OpenROAD's `set_dont_use` equivalent, ABC's
read_lib) sees the same allowed cell set as the reference flow.

Usage: merge_liberty.py [--dont-use PATTERN]... OUT.lib IN1.lib[.gz] IN2.lib[.gz] ...
"""
import fnmatch
import gzip
import re
import sys

UNIT_KEYS = ('time_unit', 'capacitive_load_unit', 'voltage_unit', 'current_unit',
             'leakage_power_unit', 'pulling_resistance_unit')


def read(path):
    opener = gzip.open if path.endswith('.gz') else open
    with opener(path, 'rt', errors='replace') as f:
        return f.read()


def match_brace(text, start):
    """Index just past the '}' that closes the '{' at text[start]."""
    depth = 0
    i = start
    n = len(text)
    while i < n:
        c = text[i]
        if c == '"':
            i += 1
            while i < n and text[i] != '"':
                i += 2 if text[i] == '\\' else 1
        elif c == '/' and text.startswith('/*', i):
            i = text.index('*/', i) + 1
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    raise ValueError('unbalanced braces')


TEMPLATE_KINDS = ('lu_table_template', 'power_lut_template')
GROUP = re.compile(r'(?m)^[ \t]*([A-Za-z_]\w*)\s*\(([^)]*)\)\s*\{')


def parse_library(text):
    """-> (name, header_text_without_groups, [(kind, name, body_text)])."""
    m = re.search(r'(?m)^\s*library\s*\(([^)]*)\)\s*\{', text)
    if not m:
        raise ValueError('no library group')
    lib_name = m.group(1).strip().strip('"')
    body_start = m.end()
    body_end = match_brace(text, m.end() - 1) - 1
    body = text[body_start:body_end]
    pos = 0
    header = []
    groups = []
    while True:
        g = GROUP.search(body, pos)
        if not g:
            header.append(body[pos:])
            break
        header.append(body[pos:g.start()])
        end = match_brace(body, g.end() - 1)
        groups.append((g.group(1), g.group(2).strip().strip('"'), body[g.start():end]))
        pos = end
    return lib_name, ''.join(header), groups


def units(header):
    found = {}
    for key in UNIT_KEYS:
        m = re.search(r'(?m)^\s*%s\s*(?:\(|:)\s*([^;)\n]*)' % key, header)
        found[key] = re.sub(r'\s+', '', m.group(1)) if m else None
    return found


def norm(s):
    return re.sub(r'\s+', ' ', s).strip()


def main():
    args = sys.argv[1:]
    dont_use = []
    while args and args[0] == '--dont-use':
        dont_use.append(args[1])
        args = args[2:]
    if len(args) < 2:
        sys.exit(__doc__)
    out, inputs = args[0], args[1:]
    base_name, base_header, base_groups = parse_library(read(inputs[0]))
    base_units = units(base_header)
    # Several groups may legitimately share one name (normalized_driver_waveform
    # repeats it with different bodies), so identity is (kind, name, body); only
    # a `cell` or a table template redefined with a DIFFERENT body is an error.
    bodies = {}
    ordered = []

    def add(path, kind, name, text):
        key = (kind, name)
        body = norm(text)
        known = bodies.setdefault(key, [])
        if body in known:
            return
        if known and (kind == 'cell' or kind in TEMPLATE_KINDS):
            raise SystemExit('%s: %s %s differs from the earlier definition' % (path, kind, name))
        known.append(body)
        ordered.append(text)

    for kind, name, text in base_groups:
        add(inputs[0], kind, name, text)
    for index, path in enumerate(inputs[1:], start=1):
        lib_name, header, groups = parse_library(read(path))
        u = units(header)
        if u != base_units:
            raise SystemExit('unit mismatch in %s: %s vs %s' % (path, u, base_units))
        # A table template of the same name but another body (the asap7 SEQ and
        # SIMPLE libraries redefine delay_template_7x7 with different index_2
        # axes) is renamed for this library and its references rewritten, so
        # each table keeps the axes its own library defined.
        renames = {}
        for kind, name, text in groups:
            known = bodies.get((kind, name))
            if known and kind in TEMPLATE_KINDS and norm(text) not in known:
                renames[name] = '%s__lib%d' % (name, index)
        for kind, name, text in groups:
            for old_name, new_name in renames.items():
                text = re.sub(r'\(\s*"?%s"?\s*\)' % re.escape(old_name), '(%s)' % new_name, text)
            if kind in TEMPLATE_KINDS and name in renames:
                name = renames[name]
            add(path, kind, name, text)
    with open(out, 'w') as f:
        f.write('library (%s_merged) {\n' % base_name)
        f.write(base_header.rstrip() + '\n')
        marked = 0
        for text in ordered:
            m = re.match(r'(\s*cell\s*\(\s*"?([^")]*)"?\s*\)\s*\{)', text)
            if m and any(fnmatch.fnmatchcase(m.group(2), pat) for pat in dont_use) \
                    and not re.search(r'(?m)^\s*dont_use\s*:', text):
                text = m.group(1) + '\n    dont_use : true;' + text[m.end():]
                marked += 1
            f.write(text.rstrip() + '\n')
        f.write('}\n')
    cells = sum(len(v) for k, v in bodies.items() if k[0] == 'cell')
    print('merged %d libraries into %s (%d cells, %d marked dont_use)' % (len(inputs), out, cells, marked))


if __name__ == '__main__':
    main()
