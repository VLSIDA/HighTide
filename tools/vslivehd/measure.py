#!/usr/bin/env python3
"""Serialize a measured command with perf counters and process-tree limits.

GNU time accounts for CPU in waited-for descendants. Its RSS is the largest
individual process; tree_peak_rss_kb is a separate, sampled sum (shared pages
can be counted more than once). Scoring should be a separate invocation.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import signal
import subprocess
import time

EVENTS = "task-clock,cycles,instructions,branches,branch-misses,cache-references,cache-misses"


def process_group_rss(group: int) -> int:
    total = 0
    for directory in Path("/proc").iterdir():
        if not directory.name.isdigit():
            continue
        try:
            fields = (directory / "stat").read_text().rsplit(")", 1)[1].split()
            if int(fields[2]) == group:
                total += int(fields[21]) * os.sysconf("SC_PAGE_SIZE") // 1024
        except (OSError, ValueError, IndexError, ProcessLookupError):
            continue
    return total


def available_kb() -> int:
    for line in Path("/proc/meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            return int(line.split()[1])
    raise RuntimeError("No MemAvailable in /proc/meminfo")


def perf_values(path: Path) -> dict:
    values = {}
    if not path.exists():
        return values
    for line in path.read_text().splitlines():
        fields = line.split(";")
        if len(fields) < 3 or line.startswith("#"):
            continue
        try:
            values[fields[2]] = {"value": float(fields[0]), "unit": fields[1]}
        except ValueError:
            values[fields[2]] = {"unavailable": fields[0]}
    return values


def measure(argv: list[str], out: Path, *, cwd: Path, env: dict | None = None,
            timeout_s: float = 1800, memory_gib: float = 32, perf: bool = True) -> dict:
    out.mkdir(parents=True, exist_ok=False)
    out = out.resolve()
    overrides = env or {}
    command = ["/usr/bin/time", "-f", "%U\t%S\t%e\t%M\t%x", "-o",
               str(out / "time.tsv"), *map(str, argv)]
    if perf:
        command = ["/usr/bin/perf", "stat", "-x", ";", "-o", str(out / "perf.csv"),
                   "-e", EVENTS, "--", *command]
    metadata = {"argv": list(map(str, argv)), "cwd": str(cwd), "environment": overrides,
                "timeout_s": timeout_s, "memory_limit_gib": memory_gib,
                "os_reserve_gib": 4, "perf_events": EVENTS if perf else None}
    (out / "command.json").write_text(json.dumps(metadata, indent=2) + "\n")
    if available_kb() < 4 * 1024**2:
        raise RuntimeError("Less than 4 GiB OS reserve before launch")
    start = time.monotonic()
    peak = 0
    stopped = None
    interrupted = False
    with (out / "run.log").open("w") as log:
        process = subprocess.Popen(command, cwd=cwd, env={**os.environ, **overrides},
                                   stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        try:
            while process.poll() is None:
                peak = max(peak, process_group_rss(process.pid))
                if peak > memory_gib * 1024**2:
                    stopped = "process-tree memory limit"
                elif available_kb() < 4 * 1024**2:
                    stopped = "OS reserve limit"
                elif time.monotonic() - start > timeout_s:
                    stopped = "wall-time limit"
                if stopped:
                    break
                time.sleep(0.1)
        except KeyboardInterrupt:
            stopped = "interrupted"
            interrupted = True
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL)
            process.wait()
    result = {**metadata, "exit_code": process.returncode,
              "status": "guard-stopped" if stopped else "ok" if process.returncode == 0 else "failed",
              "stop_reason": stopped, "wall_s": time.monotonic() - start,
              "tree_peak_rss_kb": peak, "perf": perf_values(out / "perf.csv")}
    if (out / "time.tsv").exists():
        fields = (out / "time.tsv").read_text().splitlines()[-1].split("\t")
        if len(fields) == 5:
            result.update(user_s=float(fields[0]), sys_s=float(fields[1]),
                          command_wall_s=float(fields[2]), max_process_rss_kb=int(fields[3]))
            result["cpu_s"] = result["user_s"] + result["sys_s"]
    (out / "measurement.json").write_text(json.dumps(result, indent=2) + "\n")
    if interrupted:
        raise KeyboardInterrupt
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--cwd", type=Path, default=Path.cwd())
    parser.add_argument("--timeout", type=float, default=1800)
    parser.add_argument("--memory-gib", type=float, default=32)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command[1:] if args.command[:1] == ["--"] else args.command
    if not command:
        parser.error("a command is required")
    result = measure(command, args.out, cwd=args.cwd, timeout_s=args.timeout,
                     memory_gib=args.memory_gib)
    print(json.dumps(result, indent=2))
    raise SystemExit(result["status"] != "ok")
