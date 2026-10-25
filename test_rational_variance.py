"""All calculations use Fraction; no floats, limits or modular ordering."""
import unittest
from fractions import Fraction as Q

from reference.rational_swarm import RationalConsensus, vec
from reference.rational_variance import (
    RationalMarkov, pair_gap, rational_variance_certificate, variance,
)


def op(data):
    return RationalConsensus(tuple(tuple(Q(x) for x in row) for row in data))


class RationalVarianceTests(unittest.TestCase):
    def test_three_agent_exact_jensen(self):
        p = op(((Q(1,2),Q(1,2),0),
                (Q(1,2),Q(1,2),0),
                (0,0,1)))
        vectors = (vec(1,0),vec(0,1),vec(2,3))
        c = rational_variance_certificate(p,vectors)
        self.assertTrue(c.column_unital and c.row_unital and c.nonnegative)
        self.assertTrue(c.mean_preserved)
        self.assertTrue(c.equality_verified)
        self.assertTrue(c.nonincrease_certified)
        self.assertEqual(c.moment_gap, Q(1))
        self.assertEqual(c.pairwise_witness, Q(1))
        self.assertEqual(c.old_variance-c.new_variance, Q(1))

    def test_general_exact_rational_sweep(self):
        # 3x3 symmetric, positive, doubly unital family, all exact rationals.
        vectors=(vec(0,0),vec(Q(1,3),Q(2,7)),vec(Q(-5,9),Q(8,11)))
        for denominator in range(2,12):
            a=Q(1,denominator)
            p=op(((1-a,a,0),(a,1-a,0),(0,0,1)))
            c=rational_variance_certificate(p,vectors)
            self.assertTrue(c.equality_verified)
            self.assertTrue(c.nonincrease_certified)
            self.assertEqual(c.old_variance-c.new_variance,c.pairwise_witness)
            self.assertEqual(c.pairwise_witness,
                             2*a*(1-a)*Q(1)*(
                               (vectors[0].x-vectors[1].x)**2 +
                               (vectors[0].y-vectors[1].y)**2
                             ))

    def test_permutation_preserves_disagreement(self):
        p=op(((0,1,0),(0,0,1),(1,0,0)))
        values=(vec(1,0),vec(2,3),vec(0,-2))
        c=rational_variance_certificate(p,values)
        self.assertTrue(c.nonincrease_certified)
        self.assertEqual(c.old_variance,c.new_variance)
        self.assertEqual(c.pairwise_witness,0)

    def test_signed_row_unital_counterexample(self):
        p=op(((Q(-1,2),Q(3,2)),(Q(3,2),Q(-1,2))))
        values=(vec(1,0),vec(0,1))
        c=rational_variance_certificate(p,values)
        self.assertTrue(c.equality_verified and c.column_unital)
        self.assertFalse(c.nonnegative)
        self.assertFalse(c.nonincrease_certified)
        self.assertEqual(c.old_variance,Q(1))
        self.assertEqual(c.new_variance,Q(4))
        self.assertEqual(c.pairwise_witness,Q(-3))

    def test_column_unital_is_separate_hypothesis(self):
        p=op(((0,1),(0,1)))
        c=rational_variance_certificate(p,(vec(1,0),vec(0,1)))
        self.assertTrue(c.equality_verified)
        self.assertFalse(c.column_unital)
        self.assertFalse(c.mean_preserved)
        self.assertFalse(c.nonincrease_certified)
        self.assertEqual(c.pairwise_witness,Q(0))
        # An accidentally constant state still does not make P
        # universally column unital.
        constant=rational_variance_certificate(p,(vec(1,0),vec(1,0)))
        self.assertTrue(constant.mean_preserved)
        self.assertFalse(constant.nonincrease_certified)

    def test_rational_markov_kernel(self):
        p=RationalMarkov(((Q(3,4),Q(1,4)),(Q(1,3),Q(2,3))))
        self.assertEqual(p.advance((Q(1),Q(0))),(Q(3,4),Q(1,4)))
        self.assertEqual(p.advance((Q(1,2),Q(1,2))),(Q(13,24),Q(11,24)))
        for rows in (((Q(3,2),Q(-1,2)),(Q(0),Q(1))),
                     ((Q(1,4),Q(1,4)),(Q(1),Q(0))),()):
            with self.assertRaises(ValueError):
                RationalMarkov(rows)
        with self.assertRaises(ValueError):
            p.advance((Q(1),Q(1)))
        with self.assertRaises(ValueError):
            p.advance((Q(-1),Q(2)))

    def test_pair_gap_mismatch_refused(self):
        with self.assertRaises(ValueError):
            pair_gap((Q(1),), (vec(1,0),vec(0,1)))
        with self.assertRaises(ValueError):
            rational_variance_certificate(op(((Q(1),),)),(vec(1,0),vec(0,1)))
        with self.assertRaises(ValueError):
            variance(())


if __name__=="__main__":
    unittest.main()
