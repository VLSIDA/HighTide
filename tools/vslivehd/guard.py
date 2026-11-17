from pathlib import Path
import os,subprocess,json,time,signal,sys,re
root=Path(__file__).resolve().parent
execroot=Path.cwd()
env=dict(os.environ)
def reserve_bytes():
    if sys.platform.startswith('linux'):
        fields = dict(re.findall(r'^(\w+):\s+(\d+) kB', Path('/proc/meminfo').read_text(), re.M))
        return int(fields['MemAvailable']) * 1024
    if sys.platform != 'darwin':
        raise RuntimeError('Memory guard supports Linux and macOS')
    text=subprocess.check_output(['vm_stat'],text=True)
    page=int(re.search(r'page size of (\d+)',text)[1])
    values={k:int(v) for k,v in re.findall(r'^(Pages [\w ]+):\s+(\d+)',text,re.M)}
    return page*sum(values.get(k,0) for k in ('Pages free','Pages inactive','Pages speculative'))
def run(name,command,*,cwd=execroot,extra_env=None,timeout=300):
    log=root/(name+'.log'); start=time.monotonic();peak=0;status='running';failure=None
    reserve=4*1024**3; minimum=reserve_bytes(); memory_limit_gib=float((extra_env or {}).get('GUARD_MEMORY_LIMIT_GIB','12'))
    (root/(name+'.command.json')).write_text(json.dumps({'argv':list(map(str,command)),'cwd':str(cwd),'timeout_s':timeout,'tree_memory_limit_gib':memory_limit_gib,'os_reclaimable_reserve_gib':4,'environment_overrides':extra_env or {}},indent=2)+'\n')
    if minimum<reserve:raise RuntimeError('Insufficient OS reserve before launch')
    with log.open('w') as f:
        p=subprocess.Popen(list(map(str,command)),cwd=cwd,env=dict(env,**(extra_env or {})),stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
        try:
            last_reserve=0
            while p.poll() is None:
                rows=[tuple(map(int,r.split())) for r in subprocess.check_output(['ps','-axo','pid=,ppid=,rss='],text=True).splitlines() if len(r.split())==3]
                owned={p.pid}|{int(value) for value in (extra_env or {}).get('GUARD_MONITOR_ROOT_PIDS','').split(',') if value}
                pid_file=(extra_env or {}).get('GUARD_BAZEL_SERVER_PID_FILE')
                if pid_file:
                    try:owned.add(int(Path(pid_file).read_text().strip()))
                    except (OSError,ValueError):pass
                while True:
                    after=owned|{pid for pid,parent,rss in rows if parent in owned}
                    if after==owned:break
                    owned=after
                peak=max(peak,sum(rss*1024 for pid,parent,rss in rows if pid in owned))
                if time.monotonic()-last_reserve>1:
                    available=reserve_bytes();minimum=min(minimum,available);last_reserve=time.monotonic()
                    if available<reserve:raise RuntimeError(name+' OS reserve limit')
                if peak>memory_limit_gib*1024**3:raise RuntimeError(name+' process-tree memory limit')
                if time.monotonic()-start>timeout:raise RuntimeError(name+' wall-time limit')
                time.sleep(.15)
            status='pass' if p.returncode==0 else 'failed'
        except BaseException as exc:
            status='guard-stopped';failure=str(exc)
            try:os.killpg(p.pid,signal.SIGTERM)
            except ProcessLookupError:pass
            try:p.wait(timeout=5)
            except subprocess.TimeoutExpired:
                os.killpg(p.pid,signal.SIGKILL);p.wait()
        finally:
            meta=dict(status=status,exit_code=p.returncode,wall_s=time.monotonic()-start,tree_peak_mib=peak/1024**2,minimum_os_reclaimable_gib=minimum/1024**3,failure=failure)
            (root/(name+'.run.json')).write_text(json.dumps(meta,indent=2)+'\n')
            print(name,meta,flush=True)
    if failure:raise RuntimeError(failure)
    if p.returncode:raise RuntimeError(str(log))

if __name__=='__main__':
    run(sys.argv[1],sys.argv[2:],timeout=1200,extra_env={k:v for k,v in os.environ.items() if k.startswith('GUARD_')})
