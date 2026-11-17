#!/usr/bin/env python3
"""Tiny append-only job queue with a fixed number of concurrent slots (resize study).

  study_queue.py QUEUE.jsonl STATE_DIR [--slots 2]

QUEUE.jsonl lines: {"id": "...", "cmd": [...], "cwd": "...", "env": {...}} or {"stop": true}.
Jobs start in file order as slots free up; lines may be appended while it runs. Each job
writes STATE_DIR/<id>.{log,json}. The runner exits after a {"stop": true} line once every
earlier job has finished. Only PIDs it started are ever signalled (none, normally).
"""
import json, os, subprocess, sys, time
from pathlib import Path


def main():
    queue, state = Path(sys.argv[1]), Path(sys.argv[2])
    slots = int(sys.argv[sys.argv.index('--slots') + 1]) if '--slots' in sys.argv else 2
    state.mkdir(parents=True, exist_ok=True)
    running, started, stop = {}, set(), False
    while True:
        jobs = []
        for line in queue.read_text().splitlines() if queue.exists() else []:
            if not line.strip():
                continue
            j = json.loads(line)
            if j.get('stop'):
                stop = True
                break
            jobs.append(j)
        for jid, (p, t0, j) in list(running.items()):
            if p.poll() is not None:
                rec = dict(id=jid, cmd=j['cmd'], rc=p.returncode, wall_s=time.time() - t0,
                           started=time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime(t0)),
                           ended=time.strftime('%Y-%m-%dT%H:%M:%S'))
                (state / (jid + '.json')).write_text(json.dumps(rec, indent=1))
                del running[jid]
        for j in jobs:
            if len(running) >= slots:
                break
            if j['id'] in started or (state / (j['id'] + '.json')).exists():
                started.add(j['id'])
                continue
            env = dict(os.environ)
            env.update(j.get('env', {}))
            log = open(state / (j['id'] + '.log'), 'w')
            p = subprocess.Popen(j['cmd'], cwd=j.get('cwd'), env=env, stdout=log, stderr=subprocess.STDOUT,
                                 start_new_session=True)
            (state / (j['id'] + '.pid')).write_text(str(p.pid))
            running[j['id']] = (p, time.time(), j)
            started.add(j['id'])
        if stop and not running and all(j['id'] in started for j in jobs):
            return
        time.sleep(10)


if __name__ == '__main__':
    main()
