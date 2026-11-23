#!/usr/bin/env python3
"""Import independently routed LiveHD chunks into a full DEF in common die coordinates.

Example: python3 stitch_chunk_routes.py design.def --worker left/detailed.def
         --worker right/detailed.def --output stitched.def
Use the original LEFs for all inputs. Run top-level global and detailed routing,
connectivity and DRC on the output. The input worker DEFs should already pass
their own connectivity and DRC checks.
"""
import argparse
import os
import re
import tempfile
from pathlib import Path

SECTION = re.compile(r"^(COMPONENTS|PINS|NETS|VIAS)\s+(\d+)\s*;$")
UNITS = re.compile(r"^UNITS\s+DISTANCE\s+MICRONS\s+(\d+)\s*;")
POSE = re.compile(r"\+\s+(?:FIXED|PLACED|COVER)\s+\(\s*(-?\d+)\s+(-?\d+)\s*\)\s+(\w+)")
WIRE = re.compile(r"(?<!\S)\+\s+(?:ROUTED|FIXED|COVER|NOSHIELD|SHIELD)\s+")
CLAUSE = re.compile(r"\s+\+\s+")
PIN = re.compile(r"\(\s*(\S+)\s+(\S+)\s*\)")


def records(path):
    """Read line-oriented DEF emitted by LiveHD and OpenROAD, retaining other sections."""
    section = None
    entity = []
    with path.open() as source:
        for line in source:
            s = line.strip()
            if section is None:
                start = SECTION.fullmatch(s)
                if start:
                    section = start[1]
                yield None, None, line
            elif entity or s.startswith("- "):
                entity.append(line)
                if s.endswith(";"):
                    record = "".join(entity)
                    yield section, record.split(None, 2)[1], record
                    entity.clear()
            else:
                if s == "END " + section:
                    section = None
                yield None, None, line
    if entity or section:
        raise ValueError(f"{path} ended inside a DEF section")


def component(body):
    pose = POSE.search(body)
    if not pose:
        return None
    return (body.split(None, 3)[2], int(pose[1]), int(pose[2]), pose[3])


def pins(body):
    return tuple(sorted(PIN.findall(CLAUSE.split(body, maxsplit=1)[0])))


def fixed_wires(body):
    clauses = CLAUSE.split(body.rstrip()[:-1])
    wires = []
    for clause in clauses[1:]:
        word, *rest = clause.split(None, 1)
        if word in ("ROUTED", "FIXED", "COVER"):
            wires.append("+ FIXED " + rest[0].rstrip())
        elif word in ("SHIELD", "NOSHIELD"):
            raise ValueError(f"unsupported shield clause {word} on local worker net")
    return "\n      ".join(wires) + " ;"


def stitch(design, workers, output):
    if output.resolve() in {p.resolve() for p in [design, *workers]}:
        raise ValueError("choose an output distinct from every input")
    pending = {}
    instances = {}
    worker_vias = {}
    dbu = set()
    for worker in workers:
        cells = {}
        unit = None
        for section, name, body in records(worker):
            if section == "COMPONENTS":
                cells[name] = component(body)
            elif section == "VIAS":
                if name in worker_vias and worker_vias[name].split() != body.split():
                    raise ValueError(f"worker via definitions differ for {name}")
                worker_vias[name] = body
            elif section == "NETS" and WIRE.search(body):
                if name in pending:
                    raise ValueError(f"two workers claim net {name}")
                endpoints = pins(body)
                if len(endpoints) < 2:
                    raise ValueError(f"incomplete worker net {name}")
                for inst, _ in endpoints:
                    if inst == "PIN":
                        raise ValueError(f"top-level IO on local worker net {name}")
                    pose = cells.get(inst)
                    if pose is None or instances.setdefault(inst, pose) != pose:
                        raise ValueError(f"missing or inconsistent worker pose for {inst}")
                pending[name] = (endpoints, fixed_wires(body))
            elif section is None and (match := UNITS.match(body.strip())):
                unit = int(match[1])
        if unit is None:
            raise ValueError(f"missing distance units in {worker}")
        dbu.add(unit)
    if len(dbu) != 1:
        raise ValueError("workers must have the same coordinate scale")
    if not pending:
        raise ValueError("workers contain no routed local nets")
    count = len(pending)
    # Match shared via definitions first so new definitions can be written at
    # their correct location, even when the original full DEF has no VIAS section.
    extra = dict(worker_vias)
    for section, name, body in records(design):
        if section == "VIAS" and name in extra:
            if body.split() != extra.pop(name).split():
                raise ValueError(f"worker and design via definitions differ for {name}")
        elif section is None and body.lstrip().startswith("COMPONENTS "):
            break
    same_units = False
    top_ports = {}
    with tempfile.NamedTemporaryFile(mode="w", dir=output.parent, delete=False) as dest:
        temp = Path(dest.name)
        try:
            for section, name, body in records(design):
                if section == "COMPONENTS" and name in instances:
                    if instances.pop(name) != component(body):
                        raise ValueError(f"worker and design master or placement differ for {name}")
                elif section == "PINS":
                    net = re.search(r"(?<!\S)\+\s+NET\s+(\S+)", body)
                    if net:
                        top_ports[name] = net[1]
                elif section == "NETS":
                    if "PIN " in body:
                        for inst, port in pins(body):
                            if inst == "PIN" and port in top_ports and top_ports[port] != name:
                                raise ValueError(f"port {port} binds to {top_ports[port]} in PINS and {name} in NETS")
                    if name in pending:
                        endpoints, wiring = pending.pop(name)
                        if WIRE.search(body) or pins(body) != endpoints:
                            raise ValueError(f"existing wiring or endpoint mismatch on {name}")
                        body = body.rstrip()[:-1].rstrip() + "\n      " + wiring + "\n"
                elif section is None:
                    s = body.strip()
                    if (unit := UNITS.match(s)):
                        same_units = int(unit[1]) in dbu
                    elif extra and s.startswith("VIAS "):
                        body = f"VIAS {int(s.split()[1]) + len(extra)} ;\n" + "".join(extra.values())
                        extra.clear()
                    elif extra and s.startswith("COMPONENTS "):
                        body = f"VIAS {len(extra)} ;\n" + "".join(extra.values()) + "END VIAS\n" + body
                        extra.clear()
                dest.write(body)
            if not same_units or instances or pending or extra:
                raise ValueError(f"incompatible design units or missing {len(instances)} instances, {len(pending)} nets, {len(extra)} vias")
            dest.close()
            os.replace(temp, output)
        finally:
            temp.unlink(missing_ok=True)
    return count


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("design", type=Path)
    parser.add_argument("--worker", action="append", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    count = stitch(args.design, args.worker, args.output)
    print(f"Imported {count:,} routed nets from {len(args.worker)} worker(s) into {args.output}")


if __name__ == "__main__":
    main()
