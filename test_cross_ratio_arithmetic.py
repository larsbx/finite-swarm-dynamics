"""Independent exact witness replay for Cayley–Klein root-ratio bridge.

No float, ordered finite-field comparison, complex plane or symbolic
substitution from the Lean implementation. Exercises split, tangent
and nonsplit quadratic cases with declared guards.
"""
import unittest


def inv(x, p):
    assert x % p != 0
    return pow(x, -1, p)


def expression(a, b, c, r, s, p):
    assert all(x % p != 0 for x in (a, c, r, s))
    assert p % 2
    rho = r * inv(s, p) % p
    symmetric = (rho + inv(rho, p)) % p
    ck = (2 - symmetric) * inv(4, p) % p
    spread = (1 - b * b * inv(a*c, p)) % p
    return ck, spread


def mul9(x, y):
    # F9 = F3[z]/(z²+1), where -1 is nonsquare over F3.
    return ((x[0]*y[0] - x[1]*y[1]) % 3,
            (x[0]*y[1] + x[1]*y[0]) % 3)


def pow9(x, k):
    out = (1, 0)
    while k:
        if k % 2:
            out = mul9(out, x)
        x = mul9(x, x)
        k //= 2
    return out


def add9(x, y):
    return ((x[0]+y[0]) % 3, (x[1]+y[1]) % 3)


class CrossRatioArithmeticTests(unittest.TestCase):
    def test_blue_plane_gram_and_regular_locus(self):
        # Independent exhaustive check in the canonical planar blue form.
        for p in (3, 5, 7, 11, 13):
            independent_nonisotropic = 0
            for ux in range(p):
                for uy in range(p):
                    for vx in range(p):
                        for vy in range(p):
                            a = (ux*ux + uy*uy) % p
                            b = (ux*vx + uy*vy) % p
                            c = (vx*vx + vy*vy) % p
                            wedge = (ux*vy - uy*vx) % p
                            discriminant = (b*b - a*c) % p
                            self.assertEqual(discriminant, (-wedge*wedge) % p)
                            if wedge:
                                self.assertNotEqual(discriminant, 0)
                            if a and c and wedge:
                                independent_nonisotropic += 1
            self.assertGreater(independent_nonisotropic, 0)

    def test_blue_planar_cross_ratio_composition(self):
        # Independent composition: exhaust ordered blue-plane vector pairs.
        # Nonisotropic independent directions have two distinct roots over
        # a splitting field; they need not split over the prime base field.
        # In these primes, -1 is square exactly for p = 5 and 13.
        split_counts = {3: 0, 5: 192, 7: 0, 11: 0, 13: 19008}
        for p in (3, 5, 7, 11, 13):
            tested = 0
            for ux in range(p):
                for uy in range(p):
                    for vx in range(p):
                        for vy in range(p):
                            a = (ux*ux + uy*uy) % p
                            b = (ux*vx + uy*vy) % p
                            c = (vx*vx + vy*vy) % p
                            wedge = (ux*vy - uy*vx) % p
                            if not (a and c and wedge):
                                continue
                            roots = [t for t in range(p)
                                     if (a + 2*b*t + c*t*t) % p == 0]
                            self.assertIn(len(roots), (0, 2))
                            if not roots:
                                continue  # Nonsplit; no invented base-field roots.
                            r, s = roots
                            self.assertNotEqual(r, s)
                            ck, bilinear_spread = expression(a, b, c, r, s, p)
                            wedge_spread = wedge*wedge*inv(a*c, p) % p
                            self.assertEqual(ck, wedge_spread)
                            self.assertEqual(bilinear_spread, wedge_spread)
                            tested += 1
            self.assertEqual(tested, split_counts[p])

    def test_all_distinct_split_nonzero_roots(self):
        for p in (3, 5, 7, 11, 13):
            total = 0
            for c in range(1, p):
                for r in range(1, p):
                    for s in range(1, p):
                        if r == s:
                            continue
                        a = c*r*s % p
                        b = (-c*(r+s)*inv(2, p)) % p
                        self.assertEqual((a + 2*b*r + c*r*r) % p, 0)
                        self.assertEqual((a + 2*b*s + c*s*s) % p, 0)
                        ck, spread = expression(a, b, c, r, s, p)
                        self.assertEqual(ck, spread)
                        ck_reverse, _ = expression(a, b, c, s, r, p)
                        self.assertEqual(ck_reverse, ck)
                        total += 1
            self.assertEqual(total, (p-1)*(p-1)*(p-2))

    def test_repeated_root_extension_not_ordinary_cross_ratio(self):
        for p in (3, 5, 7, 11):
            r = (p-1)
            s = r
            c = 1
            a = r*r % p
            b = (-r) % p
            ck, spread = expression(a, b, c, r, s, p)
            self.assertEqual((ck, spread), (0, 0))
            # Roots repeat, so this is an algebraic evaluation of the
            # symmetric expression, not an ordinary distinct-point ratio.

    def test_nonsplit_f9_galois_swap(self):
        # t²+1=0 has no root in F3, but splits at ±z in F9.
        z, minus_z = (0, 1), (0, 2)
        self.assertEqual(mul9(z, z), (2, 0))
        self.assertEqual(add9(z, minus_z), (0, 0))
        self.assertEqual(mul9(z, minus_z), (1, 0))
        # The nontrivial F9/F3 Frobenius automorphism exchanges the roots.
        self.assertEqual(pow9(z, 3), minus_z)
        self.assertEqual(pow9(minus_z, 3), z)
        rho = mul9(z, pow9(minus_z, 7))
        inverse_rho = pow9(rho, 7)
        self.assertEqual(rho, (2, 0))
        self.assertEqual(inverse_rho, (2, 0))
        # (2-(rho+rho^-1))/4 equals 1 in the base field F3.
        numerator = add9((2, 0), mul9((2, 0), add9(rho, inverse_rho)))
        # Because -1 = 2, numerator is exactly 2 - (rho + rho^-1).
        self.assertEqual(numerator, (1, 0))
        self.assertEqual(mul9(numerator, pow9((1, 0), 7)), (1, 0))

    def test_nonzero_denominator_guard(self):
        for p in (3, 5, 7):
            with self.assertRaises(AssertionError):
                expression(0, 1, 1, 1, 1, p)
            with self.assertRaises(AssertionError):
                expression(1, 0, 1, 0, 1, p)


if __name__ == "__main__":
    unittest.main()
