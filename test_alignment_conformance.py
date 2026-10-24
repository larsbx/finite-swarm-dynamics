"""Mutation/refusal regressions for exhaustive alignment verification."""
import unittest

from tools.check_alignment_conformance import FIXTURE, verify_rows


class AlignmentConformanceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gold = FIXTURE.read_text(encoding="utf-8")

    def test_full_reference_corpus(self):
        verify_rows(self.gold, self.gold)

    def test_refuse_truncation(self):
        with self.assertRaises(ValueError):
            verify_rows("\n".join(self.gold.splitlines()[:-1])+"\n", self.gold)

    def test_refuse_mutation(self):
        lines = self.gold.splitlines()
        lines[0] = "ALIGN7v1 0 0 0 1 0 0"
        with self.assertRaises(ValueError):
            verify_rows("\n".join(lines)+"\n", self.gold)

    def test_refuse_duplicate_or_out_of_order(self):
        lines = self.gold.splitlines()
        lines[0], lines[1] = lines[1], lines[0]
        with self.assertRaises(ValueError):
            verify_rows("\n".join(lines)+"\n", self.gold)

    def test_refuse_noncanonical_newline(self):
        with self.assertRaises(ValueError):
            verify_rows(self.gold.rstrip("\n"), self.gold)


if __name__ == "__main__":
    unittest.main()
