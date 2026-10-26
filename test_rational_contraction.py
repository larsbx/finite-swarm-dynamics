"""Independent rational replay and rejection tests for overlap certificates."""
from fractions import Fraction as Q
from itertools import permutations, product
import json
import unittest

from reference.rational_contraction import ContractionCertificate, column_overlap
from reference.rational_swarm import RationalConsensus, vec
from reference.rational_variance import variance
from tools.contraction_vectors import VECTORS, TARGET, render


def independent_variance(values):
    # Pairwise representation, independent of the centered reference variance.
    return sum((sum(((a-b)**2 for a, b in zip(values[j], values[k])), Q(0))
                for j in range(len(values)) for k in range(j)), Q(0)) / len(values)


def advance(matrix, values):
    return tuple(tuple(sum((matrix[i][j]*values[j][d] for j in range(len(values))), Q(0))
                       for d in range(2)) for i in range(len(values)))


class RationalContractionTests(unittest.TestCase):
    def test_fixed_vectors(self):
        data = json.loads(VECTORS.read_text())
        self.assertEqual(data["schema"], "rational_contraction_Q_v1")
        for c in data["cases"]:
            with self.subTest(case=c["id"]):
                matrix = tuple(tuple(Q(x) for x in row) for row in c["matrix"])
                values = tuple(tuple(Q(x) for x in row) for row in c["velocities"])
                operator = RationalConsensus(matrix)
                cert = ContractionCertificate(operator)
                self.assertEqual((cert.eta, cert.rate), (Q(c["eta"]), Q(c["rate"])))
                self.assertEqual(cert, ContractionCertificate(operator, Q(c["eta"])))
                old = independent_variance(values)
                self.assertEqual(old, Q(c["initial_variance"]))
                for k in range(c["steps"] + 1):
                    current = independent_variance(values)
                    self.assertEqual(current, variance(tuple(vec(*v) for v in values)))
                    self.assertLessEqual(current, cert.variance_bound(old, k))
                    if k < c["steps"]:
                        values = advance(matrix, values)
                self.assertEqual(current, Q(c["final_variance"]))
                self.assertEqual(cert.variance_bound(old, c["steps"]), Q(c["bound"]))
                if "overlap_0_1" in c:
                    self.assertEqual(column_overlap(operator, 0, 1), Q(c["overlap_0_1"]))
                    row_dot = sum((a*b for a, b in zip(matrix[0], matrix[1])), Q(0))
                    self.assertEqual(row_dot, Q(c["row_dot_0_1"]))
                    self.assertNotEqual(row_dot, column_overlap(operator, 0, 1))
                if c["id"] == "thirds":
                    # A small certified finite-time variance is not exact consensus.
                    self.assertGreater(current, 0)
                if c["id"] == "zero_overlap_descent":
                    self.assertEqual(cert.rate, 1)
                    self.assertLess(current, old)

    def test_small_doubly_stochastic_family(self):
        # 180 exact convex combinations of 3x3 permutations; five planar states.
        # Covers directed/asymmetric matrices, zeros, reducible supports and ties.
        perms = tuple(permutations(range(3)))
        states = tuple(tuple((Q(x), Q(y)) for x, y in state) for state in (
            ((0, 0), (0, 0), (0, 0)), ((0, 1), (1, 0), (2, -1)),
            ((0, 0), (1, 0), (0, 1)), ((1, 1), (1, 1), (1, 1)),
            ((-2, 1), (3, 4), (1, -1)),
        ))
        for left, right, k in product(perms, perms, range(5)):
            a = Q(k, 4)
            matrix = tuple(tuple(a*int(left[i] == j) + (1-a)*int(right[i] == j)
                                 for j in range(3)) for i in range(3))
            cert = ContractionCertificate(RationalConsensus(matrix))
            # Direct, differently indexed column-dot-product calculation.
            columns = tuple(zip(*matrix))
            lower = min(sum((x*y for x, y in zip(columns[j], columns[l])), Q(0))
                        for j in range(3) for l in range(j))
            self.assertEqual(cert.eta, min(lower, Q(1, 3)))
            self.assertTrue(0 <= cert.rate <= 1)
            for initial in states:
                values = initial
                old = independent_variance(values)
                for step in range(4):
                    self.assertLessEqual(independent_variance(values), cert.variance_bound(old, step))
                    values = advance(matrix, values)

    def test_reject_invalid_certificates(self):
        thirds = RationalConsensus(((Q(2, 3), Q(1, 3)), (Q(1, 3), Q(2, 3))))
        with self.assertRaises(ValueError):
            ContractionCertificate(thirds, Q(1, 2))  # rate range OK; overlap false
        for eta in (Q(-1), Q(2)):
            with self.assertRaises(ValueError):
                ContractionCertificate(thirds, eta)
        with self.assertRaises(ValueError):
            ContractionCertificate(RationalConsensus(((Q(1),),)), Q(2))
        for eta in (0.1, 0, True):
            with self.assertRaises(TypeError):
                ContractionCertificate(thirds, eta)
        signed = RationalConsensus(((Q(-1, 2), Q(3, 2)), (Q(3, 2), Q(-1, 2))))
        no_column = RationalConsensus(((Q(1), Q(0)), (Q(1), Q(0))))
        for operator in (signed, no_column):
            with self.assertRaises(ValueError):
                ContractionCertificate(operator)
        for rows in ((), ((Q(2),),), ((Q(1), Q(0)),)):
            with self.assertRaises(ValueError):
                ContractionCertificate(RationalConsensus(rows))
        with self.assertRaises(TypeError):
            ContractionCertificate(RationalConsensus(((1.0,),)))
        cert = ContractionCertificate(thirds)
        for steps in (-1, Q(1), True, 1.5):
            with self.assertRaises(ValueError):
                cert.variance_bound(Q(1), steps)
        with self.assertRaises(ValueError):
            cert.variance_bound(Q(-1), 1)
        with self.assertRaises(TypeError):
            cert.variance_bound(1.0, 1)
        with self.assertRaises(IndexError):
            column_overlap(thirds, -1, 0)

    def test_certificate_snapshots_rows(self):
        rows = [[Q(1, 2), Q(1, 2)], [Q(1, 2), Q(1, 2)]]
        cert = ContractionCertificate(RationalConsensus(rows))
        rows[0][0] = Q(100)
        self.assertEqual(cert.operator.rows[0][0], Q(1, 2))
        self.assertEqual(cert.rate, 0)

    def test_lean_vectors_current(self):
        self.assertEqual(TARGET.read_text(), render())


if __name__ == "__main__":
    unittest.main()
