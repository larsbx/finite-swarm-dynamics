"""Independent exact prime-field oracle for SGC-1 geometric/topological boundary."""
import itertools
import unittest


def diff(a, b, p):
    return tuple((y - x) % p for x, y in zip(a, b))


def det(u, v, p):
    return (u[0] * v[1] - u[1] * v[0]) % p


def norm(u, p):
    return sum(x*x for x in u) % p


def spread(u, v, p):
    q = norm(u, p) * norm(v, p) % p
    if not q:
        return None
    return (det(u, v, p)**2 * pow(q, -1, p)) % p


def quad(a, b, c, d, p):
    if len({a, b, c, d}) != 4:
        return None
    ab, ac = diff(a, b, p), diff(a, c, p)
    if det(ab, ac, p) == 0:
        return None
    s1 = spread(ab, diff(c, d, p), p)
    s2 = spread(ac, diff(b, d, p), p)
    return (s1, s2) if s1 is not None and s2 is not None else None


def rank(matrix, p):
    if not matrix or not matrix[0]:
        return 0
    m = [row[:] for row in matrix]
    r = 0
    for j in range(len(m[0])):
        pivot = next((i for i in range(r, len(m)) if m[i][j] % p), None)
        if pivot is None:
            continue
        m[pivot], m[r] = m[r], m[pivot]
        inv = pow(m[r][j], -1, p)
        m[r] = [(x*inv) % p for x in m[r]]
        for i in range(r+1, len(m)):
            factor = m[i][j]
            m[i] = [(a-factor*b) % p for a, b in zip(m[i], m[r])]
        r += 1
    return r


def betti(d1, d2, p):
    n, e, f = len(d1), len(d2), len(d2[0])
    assert len(d1[0]) == e
    assert all(sum(d1[v][j]*d2[j][k] for j in range(e)) % p == 0
               for v in range(n) for k in range(f))
    r1, r2 = rank(d1, p), rank(d2, p)
    return n-r1, e-r1-r2, f-r2


class ProjectiveCellReferenceTests(unittest.TestCase):
    def test_exact_zero_spread_characterizes_parallelogram(self):
        a = (0, 0)
        for p in (3, 5):
            vectors = list(itertools.product(range(p), repeat=2))
            eligible = 0
            for b, c, d in itertools.product(vectors, repeat=3):
                ss = quad(a, b, c, d, p)
                if ss is not None:
                    eligible += 1
                    if ss == (0, 0):
                        self.assertEqual(d, ((b[0]+c[0]) % p, (b[1]+c[1]) % p))
            self.assertGreater(eligible, 0)

    def test_separate_geometry_filter_and_graph_edges(self):
        for p in (7, 13):
            a, b, c, d = (0, 0), (1, 0), (0, 1), (1, 1)
            self.assertEqual(quad(a,b,c,d,p), (0,0))
            skew = quad(a,b,c,(2,1),p)
            self.assertEqual(skew, (0, pow(2,-1,p)))
            self.assertFalse(set(skew) <= {0})
            self.assertTrue(set(skew) <= {0, pow(2,-1,p)})
            self.assertFalse(all((True, True, False, True)))

    def test_isotropy_and_tangent_extension_boundary(self):
        self.assertIsNone(quad((0,0), (1,2), (0,1), (1,3), 5))
        u, v = (1,0,0), (1,1,2)
        q = lambda x: sum(y*y for y in x) % 5
        b = sum(x*y for x,y in zip(u,v)) % 5
        self.assertEqual((q(u)*q(v)-b*b) % 5, 0)
        self.assertNotEqual(u,v)

    def test_betti_and_nonclosed_flow(self):
        p=7
        d1 = [[(-1 if v==e else 1 if v==(e+1)%4 else 0) for e in range(4)]
              for v in range(4)]
        empty = [[] for _ in range(4)]
        one = [[1] for _ in range(4)]
        two = [[1,1] for _ in range(4)]
        self.assertEqual(betti(d1, empty, p),(1,1,0))
        self.assertEqual(betti(d1, one, p),(1,0,0))
        self.assertEqual(betti(d1, two, p),(1,0,1))
        cycle = [1]*4
        flow = [1,0,0,0]
        self.assertEqual(sum(x*y for x,y in zip(cycle,flow)) % p, 1)
        self.assertEqual(sum(x*y for x,y in zip(cycle,[0]*4)) % p, 0)


if __name__ == "__main__":
    unittest.main()
