"""Exhaustive and bounded exact checks of the extension-field reference oracle.

Finite tests are NOT general mathematical proofs or Mojo conformance claims.
"""
import itertools
import unittest

from chromoswarm import Chromo
from reference.extension_chromogeometry import (
    Agent, ChromaticPlane, FiniteField, Swarm,
)


class ExtensionFieldTests(unittest.TestCase):
    def test_reject_bad_fields(self):
        for p, m in (
            (2, (1, 1, 1)), (4, (1, 0, 1)), (5, (1, 0, 1)),
            (3, (2, 0, 1)), (3, (1, 0, 0)), (3, (1, 0, 2)),
        ):
            with self.subTest(p=p, m=m), self.assertRaises(ValueError):
                FiniteField(p, m)

    def test_arithmetic_and_inverses(self):
        for f in (FiniteField(3), FiniteField(3, (1, 0, 1)),
                  FiniteField(5, (2, 0, 1)), FiniteField(3, (1, 2, 0, 1))):
            elts = f.elements()
            self.assertEqual(len(elts), f.size)
            self.assertEqual(len(set(elts)), f.size)
            self.assertEqual(f.one * f.one, f.one)
            for a in elts:
                self.assertEqual(a ** f.size, a)
                self.assertEqual(a + (-a), f.zero)
                if a == f.zero:
                    with self.assertRaises(ZeroDivisionError):
                        a.inverse()
                    continue
                self.assertEqual(a * a.inverse(), f.one)
                self.assertEqual(a / a, f.one)
            sample = elts if f.size <= 9 else elts[:10]
            for a, b, c in itertools.product(sample, repeat=3):
                self.assertEqual(a*(b+c), a*b+a*c)
                self.assertEqual((a+b)+c, a+(b+c))

    def test_cross_field_guards(self):
        f = FiniteField(3, (1, 0, 1))
        g = FiniteField(5, (2, 0, 1))
        with self.assertRaises(TypeError):
            _ = f.one + g.one
        with self.assertRaises(TypeError):
            _ = f.one / g.one
        with self.assertRaises(TypeError):
            ChromaticPlane(f).v(f.one, g.one)
        with self.assertRaises(ValueError):
            f.elements(max_size=5)

    def test_extension_chromatic_identities(self):
        for f in (FiniteField(3, (1, 0, 1)), FiniteField(5, (2, 0, 1))):
            p = ChromaticPlane(f)
            zero, one, two = f.zero, f.one, f.element(2)
            # F_9: exhaustive vector-pair checks. F_25: a bounded domain,
            # chosen explicitly rather than sampling arbitrarily.
            elts = f.elements() if f.size == 9 else f.elements()[:5]
            vectors = [p.v(x, y) for x, y in itertools.product(elts, repeat=2)]
            for u in vectors:
                self.assertEqual(p.q(u, "b")**2, p.q(u, "r")**2 + p.q(u, "g")**2)
                for v in vectors:
                    det2 = p.det(u, v)**2
                    self.assertEqual(
                        p.q(u, "b")*p.q(v, "b") - p.q(u, "r")*p.q(v, "r")
                        - p.q(u, "g")*p.q(v, "g"), two*det2)
                    spreads = []
                    for c, sign in (("b", one), ("r", -one), ("g", -one)):
                        pol = p.q(p.add(u, v), c) - p.q(u, c) - p.q(v, c)
                        self.assertEqual(pol, two*p.b(u, v, c))
                        s = p.spread(u, v, c)
                        den = p.q(u, c)*p.q(v, c)
                        if den == zero:
                            self.assertIsNone(s)
                        else:
                            self.assertEqual(s*den, sign*det2)
                        spreads.append(s)
                    if det2 != zero and all(s is not None for s in spreads):
                        self.assertEqual(sum((s.inverse() for s in spreads), zero), two)

    def test_extension_has_blue_nulls(self):
        f = FiniteField(3, (1, 0, 1))
        p = ChromaticPlane(f)
        alpha = f.element(0, 1)
        self.assertEqual(alpha*alpha, -f.one)
        u = p.v(alpha, f.one)
        self.assertEqual(p.q(u, "b"), f.zero)
        self.assertNotEqual(u, p.v(0, 0))
        self.assertIsNone(p.spread(u, p.v(1, 0), "b"))

    def test_rotations_covariance(self):
        for f in (FiniteField(3, (1, 0, 1)), FiniteField(5, (2, 0, 1))):
            p = ChromaticPlane(f)
            elts = f.elements()
            vectors = [p.v(x, y) for x, y in itertools.product(elts[:5], repeat=2)]
            for t in elts:
                c, s = p.rotation(t)
                self.assertEqual(c*c+s*s, f.one)
                for u in vectors:
                    z = p.rotate(u, t)
                    self.assertEqual(p.q(z, "b"), p.q(u, "b"))
                    self.assertEqual(
                        p.q(z, "r"),
                        (c*c-s*s)*p.q(u, "r") - f.element(2)*c*s*p.q(u, "g"))
                    self.assertEqual(
                        p.q(z, "g"),
                        f.element(2)*c*s*p.q(u, "r") + (c*c-s*s)*p.q(u, "g"))

    def test_swarm_conservation_and_period(self):
        for f in (FiniteField(3, (1, 0, 1)), FiniteField(5, (2, 0, 1))):
            p = ChromaticPlane(f)
            unit = p.v(1, 0)
            initial = Swarm((
                Agent(p.v(0, 0), unit),
                Agent(p.v(1, 2), unit),
                Agent(p.v(2, 1), unit),
            ))
            after = p.step(initial)
            self.assertTrue(all(a.heading == unit for a in after.agents))
            self.assertTrue(all(
                p.sub(a.position, b.position) == unit
                for a, b in zip(after.agents, initial.agents)))
            self.assertEqual(p.orbit(initial), (0, f.p))
            with self.assertRaises(ValueError):
                p.step(Swarm((Agent(p.v(0, 0), p.v(0, 0)),)))

    def test_legacy_prime_field_equivalence(self):
        f = FiniteField(7)
        p = ChromaticPlane(f)
        old = Chromo(7)
        for a, b, c, d in itertools.product(range(7), repeat=4):
            u, v = p.v(a, b), p.v(c, d)
            uu, vv = old.v(a, b), old.v(c, d)
            self.assertEqual(p.det(u, v).coeffs[0], old.det(uu, vv))
            for color in ("b", "r", "g"):
                self.assertEqual(p.q(u, color).coeffs[0], old.q(uu, color))
                s, ss = p.spread(u, v, color), old.spread(uu, vv, color)
                self.assertEqual(None if s is None else s.coeffs[0], ss)


if __name__ == "__main__":
    unittest.main()
