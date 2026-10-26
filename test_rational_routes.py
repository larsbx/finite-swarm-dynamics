"""Exact independent replay of finite routed overlap certificates."""
from fractions import Fraction as Q
from itertools import product
import json
import unittest

from reference.rational_routes import RouteCertificate
from reference.rational_contraction import ContractionCertificate
from reference.rational_swarm import RationalConsensus
from tools.route_vectors import VECTORS, TARGET, render
from test_rational_contraction import independent_variance, advance


def cyclic(n, a):
    return tuple(tuple(a*int(i == j)+(1-a)*int(j == (i+1) % n)
                       for j in range(n)) for i in range(n))


class RationalRouteTests(unittest.TestCase):
    def check_routes_independently(self, cert):
        n = cert.operator.n
        for j, row in enumerate(cert.routes):
            for k, path in enumerate(row):
                self.assertEqual((path[0], path[-1]), (j, k))
                self.assertLessEqual(len(path)-1, cert.max_length)
                self.assertTrue(all(type(t) is int and 0 <= t < n for t in path))
                for a, b in zip(path, path[1:]):
                    columns = tuple(zip(*cert.operator.rows))
                    dot = sum((x*y for x, y in zip(columns[a], columns[b])), Q(0))
                    self.assertGreaterEqual(dot, cert.eta)

    def test_fixed_vectors(self):
        cases = json.loads(VECTORS.read_text())["cases"]
        for c in cases:
            with self.subTest(case=c["id"]):
                op = RationalConsensus(tuple(tuple(Q(x) for x in row) for row in c["matrix"]))
                cert = RouteCertificate(op)
                self.assertEqual((cert.eta, cert.max_length, cert.coefficient, cert.rate),
                                 (Q(c["eta"]), c["max_length"], Q(c["coefficient"]), Q(c["rate"])))
                quoted = RouteCertificate(op, Q(c["eta"]), c["max_length"], c["routes"])
                self.assertEqual(cert, quoted)
                self.check_routes_independently(quoted)
                self.assertEqual(ContractionCertificate(op).rate, Q(c["direct_rate"]))
                values = tuple(tuple(Q(x) for x in row) for row in c["velocities"])
                old = independent_variance(values)
                self.assertEqual(old, Q(c["initial_variance"]))
                self.assertTrue(0 <= cert.rate < 1)
                for k in range(c["steps"]+1):
                    now = independent_variance(values)
                    self.assertLessEqual(now, cert.variance_bound(old, k))
                    updated = advance(op.rows, values)
                    self.assertEqual(independent_variance(updated) < now, now > 0)
                    if k < c["steps"]:
                        values = updated
                self.assertEqual(now, Q(c["final_variance"]))
                self.assertEqual(cert.variance_bound(old, c["steps"]), Q(c["bound"]))
                if c["id"] in ("cycle4", "cycle4_thirds", "cycle5"):
                    self.assertEqual(Q(c["direct_rate"]), 1)
                    self.assertGreater(now, 0)  # no exact finite consensus at this horizon

    def test_finite_sparse_family(self):
        # 4 sizes × 3 rational weights × 16 states, with three finite horizons.
        for n, a in product(range(3, 7), (Q(1, 4), Q(1, 2), Q(2, 3))):
            op = RationalConsensus(cyclic(n, a))
            cert = RouteCertificate(op)
            self.check_routes_independently(cert)
            self.assertTrue(0 <= cert.rate < 1)
            for bits in product((Q(0), Q(1)), repeat=4):
                values = tuple((bits[i % 4], bits[(i+1) % 4]) for i in range(n))
                old = independent_variance(values)
                for k in range(3):
                    now = independent_variance(values)
                    self.assertLessEqual(now, cert.variance_bound(old, k))
                    updated = advance(op.rows, values)
                    self.assertEqual(independent_variance(updated) < now, now > 0)
                    values = updated

    def test_disconnected_and_invalid_witnesses(self):
        for rows in (
            ((Q(0), Q(1)), (Q(1), Q(0))),
            ((Q(1), Q(0)), (Q(0), Q(1))),
            tuple(tuple(Q(1, 2) if i//2 == j//2 else Q(0) for j in range(4)) for i in range(4)),
        ):
            with self.assertRaises(ValueError):
                RouteCertificate(RationalConsensus(rows))
        op = RationalConsensus(cyclic(4, Q(1, 2)))
        valid = RouteCertificate(op)
        for eta in (Q(0), Q(-1), Q(2), Q(1, 2)):
            with self.assertRaises(ValueError):
                RouteCertificate(op, eta)
        for eta in (0.25, 1, True):
            with self.assertRaises(TypeError):
                RouteCertificate(op, eta)
        for budget in (0, 1, -1, True, Q(2), 2.5):
            with self.assertRaises(ValueError):
                RouteCertificate(op, max_length=budget)
        for bad in ((), ((0,),), (0, 2), (0, 9, 2), (0, True, 2), (1, 2)):
            # Replace only 0→2, retaining otherwise valid complete routes.
            routes = [[list(path) for path in row] for row in valid.routes]
            routes[0][2] = bad
            with self.assertRaises(ValueError):
                RouteCertificate(op, valid.eta, valid.max_length, routes)
        with self.assertRaises(ValueError):
            RouteCertificate(op, routes=valid.routes[:-1])
        for operator in (
            RationalConsensus(((Q(-1, 2), Q(3, 2)), (Q(3, 2), Q(-1, 2)))),
            RationalConsensus(((Q(1), Q(0)), (Q(1), Q(0)))),
        ):
            with self.assertRaises(ValueError):
                RouteCertificate(operator)
        for steps in (-1, True, Q(2)):
            with self.assertRaises(ValueError):
                valid.variance_bound(Q(1), steps)
        with self.assertRaises(ValueError):
            valid.variance_bound(Q(-1), 1)
        with self.assertRaises(TypeError):
            valid.variance_bound(1.0, 1)

    def test_snapshots_and_looser_explicit_certificate(self):
        rows = [list(row) for row in cyclic(4, Q(1, 2))]
        paths = [[list(path) for path in row] for row in RouteCertificate(RationalConsensus(rows)).routes]
        cert = RouteCertificate(RationalConsensus(rows), Q(1, 8), 3, paths)
        rows[0][0] = Q(100)
        paths[0][2].append(100)
        self.assertEqual(cert.operator.rows[0][0], Q(1, 2))
        self.check_routes_independently(cert)
        self.assertEqual(cert.rate, Q(287, 288))

    def test_lean_vectors_current(self):
        self.assertEqual(TARGET.read_text(), render())


if __name__ == "__main__":
    unittest.main()
