"""Regression checks for baseline provenance and failed/stale report handling."""

import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


COLLECTOR = Path(__file__).with_name("snapshot_qor.py").resolve()


class SnapshotTest(unittest.TestCase):
    def test_current_invocation_only_and_per_clock_metrics(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            (root / "MODULE.bazel").write_text('module(name = "fixture")\n')
            subprocess.run(["git", "add", "."], cwd=root, check=True)
            subprocess.run(["git", "-c", "user.name=Test", "-c", "user.email=test@example.invalid",
                            "commit", "-qm", "fixture"], cwd=root, check=True)
            labels = {name: f"//designs/asap7/{name}:{name}_final"
                      for name in ("good", "failed", "pending", "ambiguous")}
            events = []
            for name, label in labels.items():
                events.append({"id": {"targetConfigured": {"label": label}}})
                if name != "pending":
                    events.append({"id": {"targetCompleted": {"label": label}},
                                   "completed": {"success": name != "failed"}})
            gui = "//designs/asap7/good:good_gui_final"
            events.append({"id": {"targetCompleted": {"label": gui}}, "completed": {"success": True}})
            for name in labels:
                logs = root / "bin" / "designs/asap7" / name / "logs/asap7" / name / "base"
                logs.mkdir(parents=True)
                raw = {"finish__timing__setup__ws": -12,
                       "finish__timing__hold__ws": 1e42,
                       "finish__timing__fmax": 2e9,
                       "finish__timing__fmax__clock:slow": 0.5e9,
                       "finish__timing__fmax__clock:fast": 2e9,
                       "finish__design__instance__count__class:sequential_cell": 31,
                       "finish__design__instance__count__class:clock_buffer": 7,
                       "finish__design__instance__count__macros": 0,
                       "finish__power__total": 0.003}
                (logs / "6_report.json").write_text(json.dumps(raw))
                (logs / "5_2_route.json").write_text(json.dumps({"detailedroute__route__drc_errors": 2}))
            extra = root / "bin/designs/asap7/ambiguous/logs/asap7/other/base"
            extra.mkdir(parents=True)
            (extra / "6_report.json").write_text("{}")
            report = root / "bin/designs/asap7/good/reports/asap7/good/base/6_finish.rpt"
            report.parent.mkdir(parents=True)
            report.write_text("max slew violation count 3\nmax fanout violation count 0\n"
                              "max cap violation count 0\nfinish report_power\n"
                              "Clock 2e-6 3e-6 5e-6 1e-5 100%\n")
            results = root / "bin/designs/asap7/good/results/asap7/good/base"
            results.mkdir(parents=True)
            netlist = b"module good; endmodule\n"
            (results / "1_2_yosys.v").write_bytes(netlist)
            (results / "6_final.spef").write_text("*SPEF fixture\n")
            (results / "6_final.sdc").write_text(
                "create_clock -name slow -period 2500.0000 [get_ports {clk0}]\n"
                "create_clock -name fast -period 600.0000 [get_pins {pll/clk}]\n"
                "create_generated_clock -name divided -source [get_ports {clk0}] -divide_by 2 [get_ports {out}]\n")
            event_file = root / "events.json"
            event_file.write_text("\n".join(json.dumps(event) for event in events))
            audit = {"known_invalid": {labels["good"]: ["Fixture physical clock defect"]}}
            (root / "validity-audit.json").write_text(json.dumps(audit))
            subprocess.run([sys.executable, str(COLLECTOR), "--events", str(event_file),
                            "--bin", "bin", "--output", "snapshot"], cwd=root, check=True,
                           capture_output=True, text=True)
            rows = {row["target"]: row for row in json.loads((root / "snapshot/qor.json").read_text())}
            self.assertNotIn(gui, rows)
            good = rows[labels["good"]]
            self.assertEqual(good["setup_ws_ps"], -12)
            self.assertFalse(good["setup_met"])
            self.assertIsNone(good["hold_met"])
            self.assertEqual(good["clock_fmax_ghz"], {"slow": 0.5, "fast": 2})
            self.assertEqual(good["clock_min_period_ps"], {"slow": 2000, "fast": 500})
            self.assertEqual(good["power_mw"], 3)
            self.assertEqual(good["result_sha256"]["1_2_yosys.v"], hashlib.sha256(netlist).hexdigest())
            self.assertNotIn("6_final.v", good["result_sha256"])
            self.assertEqual(good["primary_clock_period_ps"], {"slow": 2500, "fast": 600})
            self.assertEqual(good["parasitics"], "extracted_spef")
            self.assertEqual(good["logic_cells"], 38)
            self.assertEqual(good["cell_counts"]["inverter"], 0)
            self.assertEqual(good["macros"], 0)
            self.assertEqual(good["max_slew_violations"], 3)
            self.assertFalse(good["electrical_limits_met"])
            self.assertEqual(good["clock_power_mw_by_corner"], {"default": 0.01})
            self.assertFalse(good["drc_clean"])
            self.assertEqual(good["known_invalid_reasons"], ["Fixture physical clock defect"])
            self.assertEqual(json.loads((root / "snapshot/validity-audit.json").read_text()), audit)
            self.assertEqual(rows[labels["failed"]], {"target": labels["failed"], "status": "failed"})
            self.assertEqual(rows[labels["pending"]]["status"], "not_completed")
            self.assertEqual(rows[labels["ambiguous"]]["status"], "missing_or_ambiguous_report")
            archived = root / "snapshot/reports/designs/asap7/good/good/logs/6_report.json"
            self.assertEqual(json.loads(archived.read_text())["finish__timing__setup__ws"], -12)
            self.assertIn("revision", json.loads((root / "snapshot/metadata.json").read_text()))
            # A later fix must not be attributed to an earlier in-flight run.
            original_module = (root / "MODULE.bazel").read_text()
            (root / "MODULE.bazel").write_text('module(name = "changed_after_build_started")\n')
            subprocess.run([sys.executable, str(COLLECTOR), "--events", str(event_file),
                            "--bin", "bin", "--output", "frozen-snapshot",
                            "--input-snapshot", "snapshot"], cwd=root, check=True,
                           capture_output=True, text=True)
            self.assertEqual((root / "frozen-snapshot/inputs/MODULE.bazel").read_text(), original_module)
            self.assertEqual((root / "frozen-snapshot/input-sha256.json").read_bytes(),
                             (root / "snapshot/input-sha256.json").read_bytes())


if __name__ == "__main__":
    unittest.main()
