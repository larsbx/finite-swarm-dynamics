"""Tests for first-class Q beside Z and finite fields (exact, ordered)."""
from fractions import Fraction as Q
from itertools import product
import unittest

from reference.rational_swarm import (
    FlockQ, RationalConsensus, add, bilinear, blue_ball, color_interval, det,
    disagreement_two, exact_probability, half_turn, projectively_equal, q,
    quadrea, rational, rational_mean, rational_rotation, reduce_mod_prime,
    reduce_vec_mod_prime, rotate, scale, spread, sub,
    symmetric_contraction_factor, symmetric_two_agent_consensus, vec,
)


class RationalFoundationTests(unittest.TestCase):
    def test_no_float_in_exact_domain(self):
        for input_value in (0.5, True, "1/2", complex(1, 2)):
            with self.subTest(input_value=input_value), self.assertRaises(TypeError):
                rational(input_value)
        with self.assertRaises(TypeError):
            vec(0.25, 0)
        self.assertEqual(vec(2, Q(1, 3)), vec(Q(2), Q(1, 3)))

    def test_chromatic_identities_exact(self):
        u, v = vec(1, 2), vec(2, 1)
        self.assertEqual([q(u, c) for c in ("b", "r", "g")], [Q(5), Q(-3), Q(4)])
        self.assertEqual([q(v, c) for c in ("b", "r", "g")], [Q(5), Q(3), Q(4)])
        self.assertEqual(det(u, v), Q(-3))
        self.assertEqual([spread(u, v, c) for c in ("b", "r", "g")],
                         [Q(9, 25), Q(1), Q(-9, 16)])
        self.assertEqual(sum((1/spread(u,v,c) for c in ("b","r","g")),Q(0)), Q(2))
        self.assertEqual(q(u,"b")**2, q(u,"r")**2 + q(u,"g")**2)
        for c,epsilon in (("b",1),("r",-1),("g",-1)):
            lhs=q(u,c)*q(v,c)-bilinear(u,v,c)**2
            self.assertEqual(lhs,epsilon*det(u,v)**2)
            self.assertEqual(quadrea(vec(0,0),u,v,c),epsilon*4*det(u,v)**2)
        self.assertIsNone(spread(u,vec(1,0),"g"))
        self.assertIsNone(spread(u,vec(1,1),"r"))
        self.assertEqual(spread(u,u,"b"),0)

    def test_projective_vs_oriented(self):
        self.assertTrue(projectively_equal(vec(1,2),vec(3,6)))
        self.assertTrue(projectively_equal(vec(1,2),vec(-1,-2)))
        self.assertNotEqual(vec(1,2),vec(-1,-2))
        self.assertFalse(projectively_equal(vec(1,2),vec(2,1)))
        with self.assertRaises(ValueError):
            projectively_equal(vec(0,0),vec(1,0))

    def test_rational_rotation_and_exceptional_half_turn(self):
        self.assertEqual(rational_rotation(Q(1,2)),(Q(3,5),Q(4,5)))
        u=vec(1,0)
        self.assertEqual(rotate(u,Q(1,2)),vec(Q(3,5),Q(4,5)))
        self.assertEqual(q(rotate(u,Q(1,2)),"b"),Q(1))
        self.assertEqual(half_turn(u),vec(-1,0))
        for t in (Q(-37,19),Q(0),Q(1,3),Q(999)):
            c,s=rational_rotation(t)
            self.assertEqual(c*c+s*s,1)
        with self.assertRaises(TypeError):
            rotate(u,0.5)

    def test_exact_ordered_neighborhoods(self):
        u,v=vec(0,0),vec(Q(1,2),Q(1,2))
        self.assertEqual(q(sub(v,u),"b"),Q(1,2))
        self.assertTrue(blue_ball(u,v,Q(1,2)))
        self.assertFalse(blue_ball(u,v,Q(1,3)))
        self.assertTrue(color_interval(u,v,"r",0,0))
        self.assertTrue(color_interval(u,v,"g",Q(1,2),Q(1,2)))
        self.assertTrue(color_interval(vec(0,0),vec(2,1),"r",3,3))
        self.assertFalse(color_interval(vec(0,0),vec(1,2),"r",0,3))
        with self.assertRaises(ValueError):
            blue_ball(u,v,-1)
        with self.assertRaises(ValueError):
            color_interval(u,v,"b",1,0)

    def test_exact_counting_probabilities(self):
        self.assertEqual(exact_probability(2,6),Q(1,3))
        self.assertEqual(exact_probability(0,7),Q(0))
        self.assertEqual(exact_probability(7,7),Q(1))
        for x,y in ((2,0),(3,2),(-1,2)):
            with self.assertRaises(ValueError):
                exact_probability(x,y)
        with self.assertRaises(TypeError):
            exact_probability(0.5,1)

    def test_partial_modular_reduction_and_failure(self):
        u,v=vec(1,2),vec(2,1)
        self.assertEqual(reduce_vec_mod_prime(u,7),(1,2))
        self.assertEqual(tuple(reduce_mod_prime(spread(u,v,c),7)
                               for c in ("b","r","g")),(4,1,6))
        self.assertEqual(reduce_mod_prime(Q(3,4),7),6)
        for a,p in ((Q(1,7),7),(Q(4,9),3)):
            with self.assertRaises(ZeroDivisionError):
                reduce_mod_prime(a,p)
        for p in (0,2,4,9):
            with self.assertRaises(ValueError):
                reduce_mod_prime(1,p)
        # Rational inequalities do NOT survive modular reduction.
        self.assertTrue(Q(1,2)<Q(2,3))
        self.assertGreater(reduce_mod_prime(Q(1,2),7),
                           reduce_mod_prime(Q(2,3),7))

    def test_rational_ordered_consensus_and_lyapunov(self):
        op=symmetric_two_agent_consensus(Q(1,4))
        self.assertTrue(op.convex)
        self.assertTrue(op.doubly_stochastic)
        state=FlockQ((vec(0,0),vec(1,1)),(vec(1,0),vec(0,1)))
        start=disagreement_two(state.velocities)
        self.assertEqual(start,Q(2))
        mean=rational_mean(state.velocities)
        self.assertEqual(mean,vec(Q(1,2),Q(1,2)))
        for step in range(1,7):
            state=op.step(state,speed=Q(1,2))
            self.assertEqual(rational_mean(state.velocities),mean)
            self.assertEqual(disagreement_two(state.velocities),start*Q(1,4)**step)
        self.assertEqual(symmetric_contraction_factor(Q(1,4)),Q(1,4))
        self.assertEqual(symmetric_contraction_factor(Q(1,2)),0)

    def test_signed_row_unital_does_not_imply_decay(self):
        op=symmetric_two_agent_consensus(Q(3,2))
        self.assertFalse(op.convex)
        self.assertFalse(op.doubly_stochastic)
        vel=(vec(1,0),vec(0,1))
        new=op.update_velocities(vel)
        self.assertEqual(disagreement_two(new),4*disagreement_two(vel))
        self.assertEqual(symmetric_contraction_factor(Q(3,2)),Q(4))
        with self.assertRaises(ValueError):
            RationalConsensus(((Q(1,2),Q(1,3)),(Q(1,2),Q(1,2))))
        with self.assertRaises(TypeError):
            RationalConsensus(((Q(1),0), (Q(0),Q(1))))
        with self.assertRaises(ValueError):
            RationalConsensus(((Q(1),),)).update_velocities((vec(1,0),vec(0,1)))

    def test_basic_algebra_uses_exact_rationals(self):
        u,v=vec(Q(2,3),Q(-3,4)),vec(Q(1,3),Q(5,4))
        self.assertEqual(add(u,v),vec(1,Q(1,2)))
        self.assertEqual(sub(u,v),vec(Q(1,3),-2))
        self.assertEqual(scale(Q(3,2),u),vec(1,Q(-9,8)))
        self.assertEqual(rational_mean((u,v)),vec(Q(1,2),Q(1,4)))
        with self.assertRaises(ValueError):
            rational_mean(())


if __name__=="__main__":
    unittest.main()
