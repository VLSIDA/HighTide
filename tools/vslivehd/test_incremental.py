"""Cache acceptance gates: a warm run must account for every mapped color."""
import copy
import unittest
import tempfile

from pathlib import Path

from lhdsweep import check_warm, output_base_for_bin


class IncrementalTest(unittest.TestCase):
    def setUp(self):
        self.result = {
            'status': 'pass',
            'incremental': {'abc': {
                'enabled': True, 'regions': 12, 'hits': 12,
                'misses': 0, 'store_failed': 0,
            }},
        }

    def test_all_colors_reused(self):
        proof = check_warm(self.result)
        self.assertEqual(proof['abc']['hits'], 12)

    def test_partial_or_missing_evidence_is_rejected(self):
        for update in ({'hits': 11}, {'misses': 1}, {'store_failed': 1},
                       {'hits': 0, 'regions': 0}, {'enabled': False}):
            with self.subTest(update=update):
                result = copy.deepcopy(self.result)
                result['incremental']['abc'].update(update)
                with self.assertRaises(RuntimeError):
                    check_warm(result)
        with self.assertRaises(RuntimeError):
            check_warm({'status': 'pass'})

    def test_failed_run_is_rejected(self):
        self.result['status'] = 'fail'
        with self.assertRaises(RuntimeError):
            check_warm(self.result)


class OutputPathTest(unittest.TestCase):
    def test_configuration_is_derived_from_the_selected_build(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            self.assertEqual(output_base_for_bin(root / 'execroot/_main/bazel-out/k8-fastbuild/bin'), root)

    def test_unbuilt_checkout_does_not_invent_an_output_base(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            self.assertIsNone(output_base_for_bin(root / 'HighTide/bazel-bin'))
            self.assertIsNone(output_base_for_bin(root / 'bin'))


if __name__ == '__main__':
    unittest.main()
