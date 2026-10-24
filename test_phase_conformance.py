import unittest
from tools.check_phase_conformance import GOLD, TOTAL, oracle_rows, verify


class PhaseConformanceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gold = GOLD.read_text()

    def test_reference_fixture_exhaustive(self):
        self.assertEqual(len(oracle_rows()), TOTAL)
        verify(self.gold, self.gold)

    def test_refuse_truncation(self):
        with self.assertRaises(ValueError):
            verify("\n".join(self.gold.splitlines()[:-1])+"\n", self.gold)

    def test_refuse_mutation(self):
        x = self.gold.splitlines()
        x[1] = x[0]
        with self.assertRaises(ValueError):
            verify("\n".join(x)+"\n", self.gold)

    def test_refuse_reordering(self):
        x = self.gold.splitlines()
        x[10], x[11] = x[11], x[10]
        with self.assertRaises(ValueError):
            verify("\n".join(x)+"\n", self.gold)

    def test_refuse_missing_final_newline(self):
        with self.assertRaises(ValueError):
            verify(self.gold[:-1], self.gold)


if __name__ == "__main__":
    unittest.main()
