"""A cancelled sweep must stop after cleaning up its owned child processes."""
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest


class GuardCancellationTest(unittest.TestCase):
    def test_keyboard_interrupt_is_preserved_after_child_cleanup(self):
        tools = Path(__file__).resolve().parent
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            child = "import os,time; from pathlib import Path; Path('child.pid').write_text(str(os.getpid())); time.sleep(30)"
            worker = """import sys
from pathlib import Path
sys.path.insert(0, sys.argv[1])
import guard
guard.root = Path(sys.argv[2])
try:
    guard.run('cancelled', [sys.executable, '-c', sys.argv[3]], cwd=guard.root, timeout=30)
except KeyboardInterrupt:
    raise SystemExit(130)
except Exception:
    raise SystemExit(42)
"""
            child_pid = None
            with (root / 'worker.log').open('w') as log:
                process = subprocess.Popen([sys.executable, '-c', worker, str(tools), temp, child],
                                           stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
                try:
                    deadline = time.monotonic() + 10
                    while child_pid is None and time.monotonic() < deadline and process.poll() is None:
                        try:
                            child_pid = int((root / 'child.pid').read_text())
                        except (FileNotFoundError, ValueError):
                            time.sleep(.02)
                    self.assertIsNotNone(child_pid, (root / 'worker.log').read_text())
                    os.kill(process.pid, signal.SIGINT)
                    self.assertEqual(process.wait(timeout=10), 130, (root / 'worker.log').read_text())
                    result = json.loads((root / 'cancelled.run.json').read_text())
                    self.assertEqual(result['status'], 'guard-stopped')
                    self.assertEqual(result['failure'], 'KeyboardInterrupt')
                    with self.assertRaises(ProcessLookupError):
                        os.kill(child_pid, 0)
                finally:
                    if process.poll() is None:
                        process.kill()
                        process.wait()
                    if child_pid is not None:
                        try:
                            os.killpg(child_pid, signal.SIGKILL)
                        except ProcessLookupError:
                            pass


if __name__ == '__main__':
    unittest.main()
