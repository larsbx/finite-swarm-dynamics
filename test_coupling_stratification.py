"""Exact finite coupling-stratum acceptance and rejection tests."""
import unittest
from tools.coupling_stratification import (
    GOLD, ROW_COUNT, SIGNATURES, STATES, independent_rows, verify_strata,
)

class CouplingStratificationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gold=GOLD.read_text(encoding="utf-8")

    def test_complete(self):
        self.assertEqual(len(STATES),64)
        self.assertEqual(len(independent_rows()),ROW_COUNT)
        strata=verify_strata(self.gold)
        self.assertEqual(len(strata),7)
        self.assertEqual([s.cycle_count for s in strata],[64,32,24,32,32,24,32])
        self.assertEqual([s.fixed_points for s in strata],[64,16,16,16,16,16,16])
        self.assertEqual([s.transient_states for s in strata],[0,16,24,16,16,24,16])
        for k,s in enumerate(strata):
            self.assertEqual(s.signature,SIGNATURES[k])
            self.assertEqual(sum(b*n for _,b,_,n in s.signature),64)
            self.assertEqual(sum(p*n for p,_,_,n in s.signature)+s.transient_states,64)

    def test_reject_truncated(self):
        with self.assertRaises(ValueError):
            verify_strata("\n".join(self.gold.splitlines()[:-1])+"\n")

    def test_reject_modified(self):
        lines=self.gold.splitlines()
        lines[70]=lines[69]
        with self.assertRaises(ValueError):
            verify_strata("\n".join(lines)+"\n")

    def test_reject_reordered(self):
        lines=self.gold.splitlines()
        lines[1],lines[2]=lines[2],lines[1]
        with self.assertRaises(ValueError):
            verify_strata("\n".join(lines)+"\n")

    def test_reject_newline(self):
        with self.assertRaises(ValueError):
            verify_strata(self.gold.rstrip("\n"))

if __name__=="__main__":
    unittest.main()
