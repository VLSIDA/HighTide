"""Cache acceptance gates: a warm run must account for every mapped color."""
import copy
import unittest

from lhdsweep import check_warm


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


if __name__ == '__main__':
    unittest.main()
