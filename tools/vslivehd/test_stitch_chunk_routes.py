#!/usr/bin/env python3
"""Regression checks for wire ownership, pose validation and atomic output."""
import tempfile
import unittest
from pathlib import Path

from stitch_chunk_routes import stitch


HEADER = """VERSION 5.8 ;
DESIGN example ;
UNITS DISTANCE MICRONS 1000 ;
DIEAREA ( 0 0 ) ( 1000 1000 ) ;
"""
CELLS = """COMPONENTS 2 ;
- a INV + PLACED ( 10 20 ) N ;
- b BUF + PLACED ( 30 40 ) FS ;
END COMPONENTS
"""
VIA = """VIAS 1 ;
- custom + RECT M2 ( -1 -1 ) ( 1 1 ) ;
END VIAS
"""
FULL = HEADER + CELLS + """PINS 1 ;
- pad + NET top + DIRECTION INPUT ;
END PINS
NETS 2 ;
- local ( a Y ) ( b A ) + USE SIGNAL ;
- top ( PIN pad ) ( b Y ) + USE SIGNAL ;
END NETS
END DESIGN
"""
WORKER = HEADER + VIA + CELLS + """NETS 1 ;
- local ( b A ) ( a Y ) + USE SIGNAL
  + ROUTED M2 ( 10 20 ) ( * 40 ) custom
  + ROUTED M3 ( 10 40 ) ( 30 * ) + SOURCE DIST ;
END NETS
END DESIGN
"""


class StitchRoutesTest(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        root = Path(temp.name)
        self.design, self.worker, self.out = (root / n for n in ("full.def", "worker.def", "stitched.def"))
        self.design.write_text(FULL)
        self.worker.write_text(WORKER)

    def test_preserves_top_and_handles_multiple_wires_and_vias(self):
        self.assertEqual(stitch(self.design, [self.worker], self.out), 1)
        joined = self.out.read_text()
        self.assertIn("- top ( PIN pad ) ( b Y ) + USE SIGNAL ;", joined)
        self.assertEqual(joined.count("+ FIXED"), 2)
        self.assertEqual(joined.count(VIA), 1)
        self.assertNotIn("SOURCE DIST", joined)
        self.design.write_text(FULL.replace(CELLS, VIA + CELLS))
        stitch(self.design, [self.worker], self.out)
        self.assertEqual(joined, self.out.read_text())

    def test_rejects_changed_or_duplicate_inputs_without_overwriting_output(self):
        for wrong, workers in [
            (FULL.replace("( b A )", "( b B )"), [self.worker]),
            (FULL.replace("+ NET top ", "+ NET stale "), [self.worker]),
            (FULL.replace("30 40", "30 41"), [self.worker]),
            (FULL.replace("1000 ;", "2000 ;", 1), [self.worker]),
            (FULL.replace(CELLS, VIA.replace("M2", "M3") + CELLS), [self.worker]),
            (FULL, [self.worker, self.worker]),
        ]:
            with self.subTest(input=wrong, workers=len(workers)):
                self.design.write_text(wrong)
                self.out.write_text("previous")
                with self.assertRaises(ValueError):
                    stitch(self.design, workers, self.out)
                self.assertEqual(self.out.read_text(), "previous")


if __name__ == "__main__":
    unittest.main()
