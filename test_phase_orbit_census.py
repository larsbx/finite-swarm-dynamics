"""Finite model evidence for an exact F7 phase orbit classification."""
import unittest

from tools.phase_orbit_census import (
    EXPECTED_SIGNATURE, PhaseOrbitReport, phase_orbit_report,
)
from tools.check_phase_conformance import GOLD


class PhaseOrbitCensusTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gold = GOLD.read_text(encoding="utf-8")

    def test_all_states_and_cycle_structure(self):
        report = phase_orbit_report(self.gold)
        self.assertEqual(report.state_count, 64)
        self.assertEqual(report.cycle_count, 32)
        self.assertEqual(report.fixed_points, 16)
        self.assertEqual(report.max_transient, 1)
        self.assertEqual(report.cycle_signature, EXPECTED_SIGNATURE)
        self.assertTrue(report.global_rotor_equivariance)
        self.assertEqual(sum(period * count for period, _, _, count in EXPECTED_SIGNATURE), 48)
        self.assertEqual(sum(basin * count for _, basin, _, count in EXPECTED_SIGNATURE), 64)

    def test_refuse_corrupted_output(self):
        lines = self.gold.splitlines()
        lines[7] = lines[8]
        with self.assertRaises(ValueError):
            phase_orbit_report("\n".join(lines) + "\n")

    def test_refuse_missing_states(self):
        with self.assertRaises(ValueError):
            phase_orbit_report("\n".join(self.gold.splitlines()[:-1])+"\n")


if __name__ == "__main__":
    unittest.main()
