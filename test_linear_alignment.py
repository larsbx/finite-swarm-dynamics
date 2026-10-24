"""Finite alignment and exact functional-graph census tests."""
import itertools
import unittest

from reference.extension_chromogeometry import ChromaticPlane, FiniteField
from reference.linear_alignment import (
    ConsensusOperator, Flock, exact_census,
)


class FiniteAlignmentTests(unittest.TestCase):
    def test_directed_chain_consensus_index(self):
        for f in (FiniteField(3), FiniteField(3, (1, 0, 1)), FiniteField(7)):
            z, o = f.zero, f.one
            op = ConsensusOperator(f, ((z, o, z), (z, z, o), (z, z, o)))
            self.assertEqual(op.consensus_index(), 2)
            elts = f.elements(max_size=50)
            for state in itertools.product(elts[:min(5,len(elts))], repeat=3):
                self.assertEqual(len(set(op.apply(op.apply(state)))), 1)

    def test_algebraic_row_stochastic_not_probabilistic(self):
        f = FiniteField(3)
        z, o, two = f.zero, f.one, f.element(2)
        op = ConsensusOperator(f, ((two, two), (z, o)))
        self.assertEqual(op.apply((o, o)), (o, o))
        self.assertIsNone(op.consensus_index())
        self.assertEqual(op.apply((z, o)), (two, o))
        with self.assertRaises(ValueError):
            ConsensusOperator(f, ((o, o), (z, o)))
        with self.assertRaises(ValueError):
            ConsensusOperator(f, ((o, z),))
        with self.assertRaises(TypeError):
            ConsensusOperator(f, ((FiniteField(5).one,),))

    def test_from_weights_and_derived_diagonal(self):
        f = FiniteField(7)
        z, o = f.zero, f.one
        weights = ((z, o, z), (z, z, o), (z, z, z))
        op = ConsensusOperator.from_weights(f, weights, o)
        expected = ((z, o, z), (z, z, o), (z, z, o))
        self.assertEqual(op.rows, expected)
        self.assertEqual(op.consensus_index(), 2)
        with self.assertRaises(ValueError):
            ConsensusOperator.from_weights(f, ((o,),), o)

    def test_flock_step_and_p_characteristic_translation(self):
        for f in (FiniteField(3, (1, 0, 1)), FiniteField(5)):
            p = ChromaticPlane(f)
            z, o = f.zero, f.one
            op = ConsensusOperator(f, ((z, o), (z, o)))
            common = p.v(1, 2)
            state = Flock(
                (p.v(0, 0), p.v(2, 1)),
                (p.v(2, 2), common),
            )
            after = op.apply_flock(state)
            self.assertEqual(after.velocities, (common, common))
            stabilized = after
            for _ in range(f.p):
                stabilized = op.apply_flock(stabilized)
            self.assertEqual(stabilized, after)
            self.assertEqual(op.consensus_index(), 1)

    def test_scalar_census_fixed_point_consensus(self):
        f = FiniteField(3)
        z, o = f.zero, f.one
        op = ConsensusOperator(f, ((z, o), (z, o)))
        census = op.scalar_census()
        self.assertEqual(census.state_count, 9)
        self.assertEqual(census.cycle_count, 3)
        self.assertEqual(sorted(c.period for c in census.cycles), [1, 1, 1])
        self.assertEqual(sorted(c.basin_size for c in census.cycles), [3, 3, 3])
        self.assertTrue(all(c.max_transient == 1 for c in census.cycles))

    def test_scalar_census_two_cycles(self):
        f = FiniteField(3)
        z, o = f.zero, f.one
        op = ConsensusOperator(f, ((z, o), (o, z)))
        self.assertIsNone(op.consensus_index())
        census = op.scalar_census()
        self.assertEqual(census.state_count, 9)
        self.assertEqual(census.cycle_count, 6)
        self.assertEqual(sorted(c.period for c in census.cycles), [1]*3 + [2]*3)
        self.assertTrue(all(c.basin_size == c.period for c in census.cycles))
        self.assertTrue(all(c.max_transient == 0 for c in census.cycles))

    def test_census_fails_closed(self):
        with self.assertRaises(ValueError):
            exact_census((0, 1, 1), lambda x: x)
        with self.assertRaises(ValueError):
            exact_census((0, 1), lambda x: x, max_states=1)
        with self.assertRaises(ValueError):
            exact_census((0, 1), lambda x: 2)
        with self.assertRaises(ValueError):
            exact_census((), lambda x: x)
        f = FiniteField(7)
        z, o = f.zero, f.one
        op = ConsensusOperator(f, ((o, z), (z, o)))
        with self.assertRaises(ValueError):
            op.scalar_census(max_states=30)

    def test_census_with_transient_and_period(self):
        # 0 -> 1 -> 2 -> 3 -> 2, with 4 -> 3.
        census = exact_census(tuple(range(5)), lambda x: (1,2,3,2,3)[x])
        self.assertEqual(census.cycle_count, 1)
        cycle = census.cycles[0]
        self.assertEqual(cycle.period, 2)
        self.assertEqual(cycle.basin_size, 5)
        self.assertEqual(cycle.max_transient, 2)


if __name__ == "__main__":
    unittest.main()
