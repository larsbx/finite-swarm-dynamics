"""Independent exact checks: pairwise variance versus the centered oracle.

The general Lean theorem is the proof. These fixed vectors and a finite grid
catch indexing, normalization, missing-coordinate and hypothesis regressions.
"""
from fractions import Fraction as Q
from itertools import product
import json
import unittest

from reference.rational_swarm import RationalConsensus, vec
from reference.rational_variance import rational_variance_certificate
from tools.strict_variance_vectors import VECTORS, TARGET, render


def distance(u, v):
    return sum(((a - b) ** 2 for a, b in zip(u, v)), Q(0))


def pairwise_variance(values):
    # Independent of the centered-mean implementation in the reference oracle.
    return sum((distance(values[j], values[k])
                for j in range(len(values)) for k in range(j)), Q(0)) / len(values)


def evaluate(matrix, values):
    n = len(values)
    updated = tuple(tuple(sum((matrix[i][j] * values[j][d]
                              for j in range(n)), Q(0))
                          for d in range(2)) for i in range(n))
    loss = sum((matrix[i][j] * matrix[i][k] * distance(values[j], values[k])
                for i in range(n) for j in range(n) for k in range(j)), Q(0))
    mixing = any(matrix[i][j] > 0 and matrix[i][k] > 0 and values[j] != values[k]
                 for i in range(n) for j in range(n) for k in range(j))
    return pairwise_variance(values), pairwise_variance(updated), loss, mixing


class StrictVarianceTests(unittest.TestCase):
    def test_fixed_vectors(self):
        cases = json.loads(VECTORS.read_text())["cases"]
        self.assertEqual(len({c["id"] for c in cases}), len(cases))
        for c in cases:
            with self.subTest(case=c["id"]):
                matrix = tuple(tuple(Q(x) for x in row) for row in c["matrix"])
                values = tuple(tuple(Q(x) for x in row) for row in c["velocities"])
                n = len(matrix)
                row = all(sum(r) == 1 for r in matrix)
                col = all(sum(matrix[i][j] for i in range(n)) == 1 for j in range(n))
                positive = all(x >= 0 for r in matrix for x in r)
                old, new, loss, mixing = evaluate(matrix, values)
                self.assertEqual((old, new, loss), tuple(Q(c[k]) for k in
                                 ("old_variance", "new_variance", "pair_loss")))
                self.assertEqual((row, col, positive, mixing), tuple(c[k] for k in
                                 ("row_unital", "column_unital", "nonnegative", "mixes_distinct")))
                if row:
                    cert = rational_variance_certificate(RationalConsensus(matrix), tuple(vec(*v) for v in values))
                    self.assertEqual((old, new, loss), (cert.old_variance, cert.new_variance,
                                                      cert.pairwise_witness))
                if row and col:
                    self.assertEqual(old - new, loss)  # also signed weights
                    if positive:
                        self.assertEqual(new < old, mixing)
                        self.assertEqual(new == old, not mixing)
                if c["kind"].startswith("invalid"):
                    self.assertFalse(row and col and positive)
                    self.assertGreater(new, old)
                if c["id"] == "missing_column":
                    self.assertTrue(mixing)
                    self.assertNotEqual(old - new, loss)

    def test_small_rational_grid(self):
        # 9 weights × 81 planar states, including signed boundary refutations.
        states = tuple(product((Q(-1), Q(0), Q(1)), repeat=2))
        for a in (Q(k, 4) for k in range(-2, 7)):
            matrix = ((a, 1-a), (1-a, a))
            for values in product(states, repeat=2):
                old, new, loss, mixing = evaluate(matrix, values)
                self.assertEqual(old - new, loss)
                if 0 <= a <= 1:
                    self.assertEqual(new < old, mixing)
                    self.assertEqual(new == old, not mixing)

    def test_lean_vectors_are_current(self):
        self.assertEqual(TARGET.read_text(), render())


if __name__ == "__main__":
    unittest.main()
