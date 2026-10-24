"""Exhaustive small-prime checks. They are not universal formal proofs."""
import itertools
import unittest

from chromoswarm import Agent, Chromo, COLORS, Swarm


class ChromoTests(unittest.TestCase):
    def test_field_domains(self):
        for p in (3, 5, 7, 11):
            g = Chromo(p)
            with self.assertRaises(ZeroDivisionError):
                g.inv(0)
            with self.assertRaises(ZeroDivisionError):
                g.inv(p)
        for n in (2, 4, 9, 15):
            with self.assertRaises(ValueError):
                Chromo(n)

    def test_projective_incidence_and_joins(self):
        for p in (3, 5, 7):
            g = Chromo(p)
            vecs = [g.v(x, y) for x in range(p) for y in range(p)]
            points = [g.affine_lift(v) for v in vecs]
            for a in points:
                for b in points:
                    self.assertEqual(g.projective_equal(a, b), a == b)
                    if a == b:
                        with self.assertRaises(ValueError):
                            g.join(a, b)
                        continue
                    line = g.join(a, b)
                    self.assertTrue(g.incident(a, line))
                    self.assertTrue(g.incident(b, line))
                    for c in points:
                        self.assertEqual(g.incident(c, line), g.collinear(a, b, c))
            a = g.affine_lift(g.v(0, 0))
            b = g.affine_lift(g.v(0, 1))
            c = g.affine_lift(g.v(1, 0))
            self.assertTrue(g.projective_equal(g.meet(g.join(a, b), g.join(a, c)), a))

    def test_chromatic_quadrance_and_polarization(self):
        for p in (3, 5, 7, 11):
            g = Chromo(p)
            vecs = [g.v(x, y) for x in range(p) for y in range(p)]
            for u in vecs:
                self.assertEqual(g.q(u, "b")**2 % p,
                                 (g.q(u, "r")**2 + g.q(u, "g")**2) % p)
                for v in vecs:
                    for c in COLORS:
                        lhs = (g.q(g.add(u, v), c)-g.q(u, c)-g.q(v, c)) % p
                        self.assertEqual(lhs, 2*g.bilinear(u, v, c) % p)

    def test_spread_determinants_and_harmonic_law(self):
        for p in (3, 5, 7, 11):
            g = Chromo(p)
            vecs = [g.v(x, y) for x in range(p) for y in range(p)]
            sign = {"b": 1, "r": -1, "g": -1}
            for u in vecs:
                for v in vecs:
                    d2 = g.det(u, v)**2 % p
                    spreads = {}
                    for c in COLORS:
                        s = g.spread(u, v, c)
                        den = g.q(u, c)*g.q(v, c) % p
                        if not den:
                            self.assertIsNone(s)
                        else:
                            self.assertEqual((s*den) % p, sign[c]*d2 % p)
                        spreads[c] = s
                    if d2 and all(s is not None for s in spreads.values()):
                        self.assertEqual(sum(g.inv(s) for s in spreads.values()) % p, 2 % p)

    def test_quadrea(self):
        for p in (3, 5):
            g = Chromo(p)
            vecs = [g.v(x, y) for x in range(p) for y in range(p)]
            for a, b, c in itertools.product(vecs, repeat=3):
                d2 = g.det(g.sub(b, a), g.sub(c, a))**2 % p
                for color, sign in (("b", 1), ("r", -1), ("g", -1)):
                    self.assertEqual(g.quadrea(a, b, c, color), sign*4*d2 % p)

    def test_rotations_and_chromatic_mixing(self):
        for p in (3, 5, 7, 11):
            g = Chromo(p)
            vecs = [g.v(x, y) for x in range(p) for y in range(p)]
            for t in range(p):
                c, s = g.rotation(t)
                self.assertEqual((c*c+s*s) % p, 1)
                for u in vecs:
                    z = g.rotate(u, t)
                    self.assertEqual(g.q(z, "b"), g.q(u, "b"))
                    self.assertEqual(g.q(z, "r"),
                        ((c*c-s*s)*g.q(u, "r")-2*c*s*g.q(u, "g")) % p)
                    self.assertEqual(g.q(z, "g"),
                        (2*c*s*g.q(u, "r")+(c*c-s*s)*g.q(u, "g")) % p)

    def test_common_exact_stabilizer(self):
        for p in (3, 5, 7):
            g = Chromo(p)
            e1, e2 = g.v(1, 0), g.v(0, 1)
            common = []
            for a, b, c, d in itertools.product(range(p), repeat=4):
                if (a*d-b*c) % p == 0:
                    continue
                u, v = g.v(a, c), g.v(b, d)
                if all((
                    g.q(u, color) == g.q(e1, color)
                    and g.q(v, color) == g.q(e2, color)
                    and g.bilinear(u, v, color) == g.bilinear(e1, e2, color)
                ) for color in COLORS):
                    common.append((a, b, c, d))
            self.assertEqual(set(common), {(1, 0, 0, 1), (p-1, 0, 0, p-1)})

    def test_swarm_invariants(self):
        g = Chromo(7)
        state = Swarm((
            Agent(g.v(0, 0), g.v(1, 0)),
            Agent(g.v(1, 2), g.v(0, 1)),
            Agent(g.v(3, 1), g.v(2, 2)),
        ))
        nxt = g.step(state)
        self.assertTrue(all(g.q(a.heading, "b") == 1 for a in nxt.agents))
        shift = g.v(4, 6)
        shifted = Swarm(tuple(Agent(g.add(a.position, shift), a.heading) for a in state.agents))
        self.assertEqual(
            g.step(shifted),
            Swarm(tuple(Agent(g.add(a.position, shift), a.heading) for a in nxt.agents)),
        )
        negated = Swarm(tuple(Agent(g.neg(a.position), g.neg(a.heading)) for a in state.agents))
        self.assertEqual(
            g.step(negated),
            Swarm(tuple(Agent(g.neg(a.position), g.neg(a.heading)) for a in nxt.agents)),
        )
        agree = Swarm(tuple(Agent(a.position, g.v(1, 0)) for a in state.agents))
        agree_plus = g.step(agree)
        for a, b in zip(agree.agents, agree_plus.agents):
            self.assertEqual(b.heading, a.heading)
            self.assertEqual(g.sub(b.position, a.position), g.v(1, 0))
        for a, b in itertools.combinations(range(3), 2):
            self.assertEqual(g.sub(agree.agents[a].position, agree.agents[b].position),
                             g.sub(agree_plus.agents[a].position, agree_plus.agents[b].position))
        self.assertEqual(g.orbit(state), (1, 7))
        self.assertEqual([a.heading for a in nxt.agents], [g.v(2, 2)]*3)

    def test_worked_F7(self):
        g = Chromo(7)
        u, v = g.v(1, 2), g.v(2, 1)
        self.assertEqual([g.q(u, c) for c in COLORS], [5, 4, 4])
        self.assertEqual([g.q(v, c) for c in COLORS], [5, 3, 4])
        self.assertEqual(g.det(u, v), 4)
        self.assertEqual([g.spread(u, v, c) for c in COLORS], [4, 1, 6])
        self.assertEqual(sum(g.inv(g.spread(u, v, c)) for c in COLORS) % 7, 2)


if __name__ == "__main__":
    unittest.main(verbosity=2)
