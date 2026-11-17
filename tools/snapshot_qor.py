#!/usr/bin/env python3
"""Archive the successfully built final targets from one Bazel BEP invocation.

Usage: python3 tools/snapshot_qor.py --events artifacts/RUN/build-events.json \
    --output artifacts/RUN/qor [--platform asap7]

Missing and failed results stay explicit. Never substitute a prior build's
report for a failed target. Raw reports retain per-clock/corner information.
"""

import argparse
import csv
import datetime
import hashlib
import json
import math
from pathlib import Path
import re
import shutil
import subprocess


def git(*args):
    return subprocess.check_output(["git", *args], text=True).strip()


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def number(metrics, key, scale=1):
    value = metrics.get(key)
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        # OpenSTA's no-path slack sentinel is finite (1e42 in ASAP7 ps).
        # It must not turn an unconstrained analysis into a timing pass.
        if key.endswith(("__ws", "__tns")) and abs(value) >= 1e30:
            return None
        return value * scale if math.isfinite(value) else None
    return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--events", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--platform", choices=("asap7", "nangate45", "sky130hd"), default="asap7")
    parser.add_argument("--targets", type=Path, help="Expected final labels, including targets never configured")
    parser.add_argument("--input-snapshot", type=Path, help="Reuse input provenance frozen for this invocation")
    parser.add_argument("--bin", type=Path, default=Path("bazel-bin"))
    args = parser.parse_args()
    if args.targets is None:
        inventory = args.events.parent / "final-targets.txt"
        args.targets = inventory if inventory.is_file() else None
    if args.input_snapshot is None:
        frozen = args.events.parent / "input-snapshot"
        if frozen.is_dir() and frozen.resolve() != args.output.resolve():
            args.input_snapshot = frozen
    # A snapshot is immutable: use another directory for the next invocation.
    args.output.mkdir(parents=True, exist_ok=False)
    events = [json.loads(line) for line in args.events.read_text().splitlines() if line]
    labels = set(args.targets.read_text().splitlines()) if args.targets else set()
    completed = {}
    for event in events:
        for key in ("targetConfigured", "targetCompleted"):
            label = event.get("id", {}).get(key, {}).get("label", "")
            if (label.startswith(f"//designs/{args.platform}/") and label.endswith("_final")
                    and "_gui_" not in label):
                labels.add(label)
                if key == "targetCompleted":
                    completed[label] = event.get("completed", {}).get("success", False)
    metadata = {
        "schema_version": 1,
        "captured_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "revision": git("rev-parse", "HEAD"),
        "submodules": git("submodule", "status", "--recursive"),
        "worktree_status": git("status", "--short"),
        "platform": args.platform,
        "bep_started": next((e["started"] for e in events if "started" in e), None),
        "bep_finished": next((e["finished"] for e in events if "finished" in e), None),
        "units": {"timing": "ps", "area": "um^2", "power": "mW", "frequency": "GHz",
                  "utilization": "fraction", "wirelength": "um"},
        "notes": [
            "QoR is for the pinned flow and interface constraints, including FakeRAM models.",
            "Power uses the flow's default activity assumptions; these runs do not supply workload SAIF/VCD activity.",
            "Raw JSON/report files preserve per-clock and per-corner details.",
            "ORFS aggregate Fmax selects the FASTEST clock; compare clock_fmax_ghz and clock_min_period_ps per clock.",
            "The pinned OpenSTA Fmax routine considers same-clock, same-edge max check/output-delay paths without multicycle exceptions. Opposite-edge and other path checks can limit closure separately. clock_min_period_ps is the inverse of this reported metric, not an all-path closure guarantee.",
            "unknown validity checks are not passes; negative slack is retained.",
            "OpenSTA no-path slack sentinels are unknown, not timing passes; original values remain in raw metrics.",
            "Cached results are valid outputs for the same Bazel action; wall time is not implementation runtime.",
        ],
    }
    collector = Path(__file__).resolve()
    metadata["collector_sha256"] = sha256(collector)
    shutil.copy2(collector, args.output / "collector.py")
    if args.input_snapshot:
        frozen_metadata = json.loads((args.input_snapshot / "metadata.json").read_text())
        for key in ("revision", "submodules", "worktree_status"):
            metadata[key] = frozen_metadata[key]
        metadata["inputs_captured_utc"] = frozen_metadata.get("inputs_captured_utc", frozen_metadata["captured_utc"])
        metadata["input_snapshot"] = str(args.input_snapshot)
        for name in ("changes.patch", "input-sha256.json"):
            shutil.copy2(args.input_snapshot / name, args.output / name)
        shutil.copytree(args.input_snapshot / "inputs", args.output / "inputs")
    else:
        metadata["inputs_captured_utc"] = metadata["captured_utc"]
        (args.output / "changes.patch").write_text(git("diff", "HEAD", "--binary") + "\n")
        # Include untracked tooling too, with exact contents and hashes.
        files = git("ls-files", "--cached", "--others", "--exclude-standard", "-z").split("\0")
        hashes = {}
        for name in files:
            path = Path(name)
            if not path.is_file() or path.resolve().is_relative_to(args.output.resolve()):
                continue
            hashes[name] = sha256(path)
            if (path.suffix in (".sdc", ".tcl", ".bzl", ".cfg") or
                    path.name in ("BUILD.bazel", "MODULE.bazel", ".bazelrc", ".bazelversion",
                                  "snapshot_qor.py", "test_snapshot_qor.py", "setup_linux_runtime.sh")):
                dest = args.output / "inputs" / path
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, dest)
        (args.output / "input-sha256.json").write_text(json.dumps(hashes, indent=2) + "\n")
    shutil.copy2(args.events, args.output / "build-events.json")
    # Physical/model audits supplement numerical timing; a disconnected clock
    # can otherwise produce an apparently positive setup result.
    audit_path = args.events.parent / "validity-audit.json"
    audit = json.loads(audit_path.read_text()) if audit_path.is_file() else {}
    if audit_path.is_file():
        shutil.copy2(audit_path, args.output / audit_path.name)
        metadata["validity_audit_sha256"] = sha256(audit_path)
    rows = []
    for label in sorted(label for label in labels if "_gui_" not in label):
        package, target = label[2:].split(":")
        base_name = target.removesuffix("_final")
        row = {"target": label, "status": "not_completed"}
        if label in completed:
            row["status"] = "built" if completed[label] else "failed"
        # orfs_flow names its output subdirectory after the flow name (variants
        # can share a package). Restrict to this flow to avoid mixing variants.
        root = args.bin / package
        reports = list(root.glob(f"{base_name}/logs/{args.platform}/*/*/6_report.json"))
        if not reports:
            reports = list(root.glob(f"logs/{args.platform}/*/{base_name}/6_report.json"))
        if not reports:
            # Common single-flow package layout: logs/<pdk>/<top>/base/...
            reports = list(root.glob(f"logs/{args.platform}/*/base/6_report.json"))
        if completed.get(label) and len(reports) == 1:
            path = reports[0]
            flow_root = path.parents[3].parent
            flow_relative = Path(*path.parts[-4:-1])
            raw = json.loads(path.read_text())
            finish = "finish__"
            scale = 1 if args.platform == "asap7" else 1000
            fields = {
                "setup_ws_ps": ("timing__setup__ws", scale),
                "hold_ws_ps": ("timing__hold__ws", scale),
                "setup_tns_ps": ("timing__setup__tns", scale),
                "hold_tns_ps": ("timing__hold__tns", scale),
                "reported_fastest_fmax_ghz": ("timing__fmax", 1e-9),
                "die_area_um2": ("design__die__area", 1),
                "core_area_um2": ("design__core__area", 1),
                "stdcell_area_um2": ("design__instance__area__stdcell", 1),
                "utilization": ("design__instance__utilization", 1),
                "power_mw": ("power__total", 1000),
                "setup_violations": ("timing__drv__setup_violation_count", 1),
                "hold_violations": ("timing__drv__hold_violation_count", 1),
                "clock_skew_ps": ("clock__skew__setup", scale),
                "stdcell_instances": ("design__instance__count__stdcell", 1),
            }
            row.update({name: number(raw, finish + key, factor) for name, (key, factor) in fields.items()})
            row["clock_fmax_ghz"] = {
                key.split("__clock:", 1)[1]: number(raw, key, 1e-9)
                for key in raw if key.startswith("finish__timing__fmax__clock:")
            }
            row["clock_min_period_ps"] = {
                clock: 1000 / value if value is not None and value > 0 else None
                for clock, value in row["clock_fmax_ghz"].items()
            }
            classes = ("sequential_cell", "multi_input_combinational_cell", "inverter",
                       "clock_buffer", "clock_inverter", "timing_repair_buffer", "timing_repair_inverter")
            # report_cell_usage emits only classes present in the design.
            has_classes = any(key.startswith("finish__design__instance__count__class:")
                              and "__in_module:" not in key for key in raw)
            row["cell_counts"] = {
                cls: (number(raw, f"finish__design__instance__count__class:{cls}")
                      if f"finish__design__instance__count__class:{cls}" in raw
                      else 0 if has_classes else None)
                for cls in classes
            }
            counts = list(row["cell_counts"].values())
            row["logic_cells"] = sum(counts) if all(value is not None for value in counts) else None
            row["macros"] = number(raw, "finish__design__instance__count__class:macro")
            if row["macros"] is None:
                row["macros"] = number(raw, "finish__design__instance__count__macros")
            report = flow_root / "reports" / flow_relative / "6_finish.rpt"
            report_text = report.read_text(errors="replace") if report.exists() else ""
            electrical = {}
            for name, limit in (("max_slew_violations", "slew"),
                                ("max_cap_violations", "cap"),
                                ("max_fanout_violations", "fanout")):
                match = re.search(r"^max " + limit + r" violation count (\d+)\s*$", report_text, re.MULTILINE)
                electrical[name] = int(match.group(1)) if match else None
            row.update(electrical)
            row["electrical_limits_met"] = (all(value == 0 for value in electrical.values())
                                             if all(value is not None for value in electrical.values()) else None)
            clock_power = {}
            corner = "default"
            power_section = report_text.partition("finish report_power")[2]
            for line in power_section.splitlines():
                if line.startswith("Corner: "):
                    corner = line.removeprefix("Corner: ").strip()
                fields = line.split()
                if len(fields) >= 5 and fields[0] == "Clock":
                    try:
                        clock_power[corner] = float(fields[4]) * 1000
                    except ValueError:
                        pass
            row["clock_power_mw_by_corner"] = clock_power
            row["unconstrained_path_examples"] = report_text.count("(Path is unconstrained)") if report.exists() else None
            # This is a sampled timing report, not exhaustive check_setup coverage.
            row["constraint_coverage"] = "unconstrained_paths_reported" if row["unconstrained_path_examples"] else "not_verified"
            spef = flow_root / "results" / flow_relative / "6_final.spef"
            row["parasitics"] = ("extracted_spef" if spef.stat().st_size else "global_route_estimate") if spef.exists() else "unknown"
            result_root = flow_root / "results" / flow_relative
            final_sdc = result_root / "6_final.sdc"
            # The pinned write_sdc serializes primary clocks with constant
            # periods in this order. Generated-clock definitions remain in
            # the archived SDC; do not guess their inherited periods here.
            row["primary_clock_period_ps"] = {
                match.group(1): float(match.group(2)) * scale
                for match in re.finditer(
                    r"^create_clock -name (\S+) -period ([0-9.eE+-]+)\s",
                    final_sdc.read_text() if final_sdc.is_file() else "",
                    re.MULTILINE,
                )
            }
            row["result_sha256"] = {
                name: sha256(result_root / name)
                for name in ("1_2_yosys.v", "1_synth.sdc", "6_final.v", "6_final.sdc", "6_final.spef")
                if (result_root / name).is_file()
            }
            row["report"] = str(path)
            destination = args.output / "reports" / package / base_name
            destination.mkdir(parents=True)
            row["archived_metrics"] = str((destination / "logs/6_report.json").relative_to(args.output))
            # Preserve stage metrics, timing reports, and effective SDC/config.
            for category in ("logs", "reports", "results"):
                source = flow_root / category / flow_relative
                for item in source.glob("*"):
                    if item.suffix in (".json", ".rpt", ".sdc", ".mk") or item.name.endswith(".log"):
                        dest = destination / category / item.name
                        dest.parent.mkdir(exist_ok=True)
                        shutil.copy2(item, dest)
            drc_values = []
            wirelength_values = []
            for metric_file in sorted((destination / "logs").glob("*.json")):
                for key, value in json.loads(metric_file.read_text()).items():
                    if key == "detailedroute__route__drc_errors":
                        drc_values.append(value)
                    if key == "detailedroute__route__wirelength":
                        wirelength_values.append(value)
            row["route_drc_errors"] = drc_values[-1] if drc_values else None
            row["route_wirelength_um"] = wirelength_values[-1] if wirelength_values else None
            warnings = set()
            warnings.update(key.removeprefix("finish__flow__warnings__count:") for key in raw
                            if key.startswith("finish__flow__warnings__count:"))
            for log in (destination / "logs").glob("*.log"):
                warnings.update(re.findall(r"\[(?:WARNING|ERROR|CRITICAL) ([A-Z]+-\d+)\]", log.read_text(errors="replace")))
            row["warning_codes"] = sorted(warnings)
            row["setup_met"] = None if row["setup_ws_ps"] is None else row["setup_ws_ps"] >= 0
            row["hold_met"] = None if row["hold_ws_ps"] is None else row["hold_ws_ps"] >= 0
            row["drc_clean"] = None if row["route_drc_errors"] is None else row["route_drc_errors"] == 0
            row["known_invalid_reasons"] = audit.get("known_invalid", {}).get(label, [])
            row["raw_metrics"] = raw
        elif completed.get(label):
            row["status"] = "missing_or_ambiguous_report"
        rows.append(row)
    metadata["final_targets"] = len(rows)
    metadata["status_counts"] = {status: sum(r["status"] == status for r in rows) for status in sorted({r["status"] for r in rows})}
    (args.output / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n")
    (args.output / "qor.json").write_text(json.dumps(rows, indent=2) + "\n")
    columns = sorted({key for row in rows for key in row if key != "raw_metrics"}) or ["target", "status"]
    with (args.output / "qor.csv").open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=columns, extrasaction="ignore")
        writer.writeheader()
        writer.writerows({key: json.dumps(value, sort_keys=True) if isinstance(value, (dict, list)) else value
                         for key, value in row.items() if key != "raw_metrics"} for row in rows)
    print(json.dumps(metadata["status_counts"], sort_keys=True))
    print(f"Saved baseline snapshot to {args.output}")


if __name__ == "__main__":
    main()
