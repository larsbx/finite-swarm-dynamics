"""Exact, fail-closed Python reference oracle for F_(p^k) chromogeometry.

This non-authoritative reference complements the canonical Mojo kernels in
larsbx/finite-math-kernels. It does not duplicate their production field API.
No floating point, real/complex scalars, or implicit field-element ordering.
"""
from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import isqrt


def _prime(p: int) -> bool:
    if p < 2:
        return False
    return all(p % d != 0 for d in range(2, isqrt(p) + 1))


def _trim(a: tuple[int, ...], p: int) -> tuple[int, ...]:
    v = [x % p for x in a]
    while len(v) > 1 and v[-1] == 0:
        v.pop()
    return tuple(v) if v else (0,)


def _sub(a: tuple[int, ...], b: tuple[int, ...], p: int) -> tuple[int, ...]:
    return _trim(tuple((a[i] if i < len(a) else 0) -
                       (b[i] if i < len(b) else 0)
                       for i in range(max(len(a), len(b)))), p)


def _mul(a: tuple[int, ...], b: tuple[int, ...], p: int) -> tuple[int, ...]:
    out = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            out[i+j] = (out[i+j] + ai*bj) % p
    return _trim(tuple(out), p)


def _rem(a: tuple[int, ...], m: tuple[int, ...], p: int) -> tuple[int, ...]:
    if m == (0,):
        raise ZeroDivisionError("polynomial modulus is zero")
    r = list(_trim(a, p))
    inv_lead = pow(m[-1], p-2, p)
    while len(r) >= len(m) and r != [0]:
        coeff = r[-1] * inv_lead % p
        shift = len(r) - len(m)
        for i, v in enumerate(m):
            r[i+shift] = (r[i+shift] - coeff*v) % p
        while len(r) > 1 and r[-1] == 0:
            r.pop()
    return tuple(r)


def _gcd(a: tuple[int, ...], b: tuple[int, ...], p: int) -> tuple[int, ...]:
    while b != (0,):
        a, b = b, _rem(a, b, p)
    if a == (0,):
        return a
    c = pow(a[-1], p-2, p)
    return _trim(tuple(x*c for x in a), p)


def _powmod(a: tuple[int, ...], n: int, m: tuple[int, ...], p: int) -> tuple[int, ...]:
    out = (1,)
    base = _rem(a, m, p)
    while n:
        if n & 1:
            out = _rem(_mul(out, base, p), m, p)
        base = _rem(_mul(base, base, p), m, p)
        n >>= 1
    return out


def _prime_factors(n: int) -> tuple[int, ...]:
    result: list[int] = []
    d = 2
    while d*d <= n:
        if n % d == 0:
            result.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        result.append(n)
    return tuple(result)


def _irreducible(f: tuple[int, ...], p: int) -> bool:
    """Rabin criterion; independent Python replay, not a proof certificate."""
    n = len(f) - 1
    if n < 1 or f[-1] != 1:
        return False
    x = _rem((0, 1), f, p)
    if _powmod(x, p**n, f, p) != x:
        return False
    for r in _prime_factors(n):
        a = _sub(_powmod(x, p**(n//r), f, p), x, p)
        if _gcd(f, a, p) != (1,):
            return False
    return True


@dataclass(frozen=True)
class FiniteField:
    """F_p[X]/(monic irreducible f). E.g. F_9=FiniteField(3,(1,0,1))."""

    p: int
    modulus: tuple[int, ...] = (0, 1)

    def __post_init__(self) -> None:
        if not isinstance(self.p, int) or not _prime(self.p) or self.p == 2:
            raise ValueError("characteristic must be an odd prime")
        if (len(self.modulus) < 2 or self.modulus[-1] != 1 or
            any(not isinstance(x, int) or not 0 <= x < self.p for x in self.modulus)):
            raise ValueError("modulus must be canonical, monic, and positive-degree")
        if not _irreducible(self.modulus, self.p):
            raise ValueError("quotient modulus must be irreducible")

    @property
    def degree(self) -> int:
        return len(self.modulus) - 1

    @property
    def size(self) -> int:
        return self.p ** self.degree

    def element(self, *coeffs: int) -> Element:
        if len(coeffs) == 1 and isinstance(coeffs[0], int):
            coeffs = (coeffs[0],)
        if len(coeffs) > self.degree or any(not isinstance(x, int) for x in coeffs):
            raise ValueError("element requires at most degree integer coefficients")
        return Element(self, tuple((coeffs[i] if i < len(coeffs) else 0) % self.p
                                   for i in range(self.degree)))

    @property
    def zero(self) -> Element:
        return self.element(0)

    @property
    def one(self) -> Element:
        return self.element(1)

    def elements(self, *, max_size: int = 4096) -> tuple[Element, ...]:
        """Exact enumeration, refusing oversized requests rather than truncating."""
        if self.size > max_size:
            raise ValueError("field enumeration exceeds explicitly permitted size")
        return tuple(self.element(*c) for c in product(range(self.p), repeat=self.degree))


@dataclass(frozen=True)
class Element:
    field: FiniteField
    coeffs: tuple[int, ...]

    def __post_init__(self) -> None:
        if (len(self.coeffs) != self.field.degree or
            any(not isinstance(x, int) or not 0 <= x < self.field.p for x in self.coeffs)):
            raise ValueError("noncanonical field element")

    def _check(self, b: Element) -> None:
        if not isinstance(b, Element) or b.field != self.field:
            raise TypeError("operations require elements from the same presented field")

    def __add__(self, b: Element) -> Element:
        self._check(b)
        return self.field.element(*(a+c for a, c in zip(self.coeffs, b.coeffs)))

    def __neg__(self) -> Element:
        return self.field.element(*(-a for a in self.coeffs))

    def __sub__(self, b: Element) -> Element:
        return self + (-b)

    def __mul__(self, b: Element) -> Element:
        self._check(b)
        r = _rem(_mul(self.coeffs, b.coeffs, self.field.p),
                 self.field.modulus, self.field.p)
        return self.field.element(*r)

    def __pow__(self, n: int) -> Element:
        if not isinstance(n, int):
            raise TypeError("power must be integer")
        if n < 0:
            return self.inverse() ** (-n)
        out = self.field.one
        base = self
        while n:
            if n & 1:
                out = out * base
            base = base * base
            n >>= 1
        return out

    def inverse(self) -> Element:
        if self == self.field.zero:
            raise ZeroDivisionError("inverse of zero is undefined")
        return self ** (self.field.size - 2)

    def __truediv__(self, b: Element) -> Element:
        self._check(b)
        return self * b.inverse()


@dataclass(frozen=True)
class Vec2:
    x: Element
    y: Element


@dataclass(frozen=True)
class Agent:
    position: Vec2
    heading: Vec2


@dataclass(frozen=True)
class Swarm:
    agents: tuple[Agent, ...]


class ChromaticPlane:
    """Planar geometry and deterministic finite-field swarm on any validated F_(p^k)."""

    def __init__(self, field: FiniteField):
        self.f = field

    def v(self, x: Element | int, y: Element | int) -> Vec2:
        f = self.f
        a = f.element(x) if isinstance(x, int) else x
        b = f.element(y) if isinstance(y, int) else y
        if a.field != f or b.field != f:
            raise TypeError("vector coordinates must share the plane field")
        return Vec2(a, b)

    def add(self, u: Vec2, v: Vec2) -> Vec2:
        return self.v(u.x + v.x, u.y + v.y)

    def sub(self, u: Vec2, v: Vec2) -> Vec2:
        return self.v(u.x - v.x, u.y - v.y)

    def scale(self, t: Element, u: Vec2) -> Vec2:
        return self.v(t*u.x, t*u.y)

    def det(self, u: Vec2, v: Vec2) -> Element:
        return u.x*v.y - u.y*v.x

    def q(self, u: Vec2, color: str) -> Element:
        x, y = u.x, u.y
        if color == "b":
            return x*x + y*y
        if color == "r":
            return x*x - y*y
        if color == "g":
            return self.f.element(2)*x*y
        raise ValueError("unknown chromatic form")

    def b(self, u: Vec2, v: Vec2, color: str) -> Element:
        x, y, a, b = u.x, u.y, v.x, v.y
        if color == "b":
            return x*a + y*b
        if color == "r":
            return x*a - y*b
        if color == "g":
            return x*b + y*a
        raise ValueError("unknown chromatic form")

    def spread(self, u: Vec2, v: Vec2, color: str) -> Element | None:
        den = self.q(u, color)*self.q(v, color)
        if den == self.f.zero:
            return None
        return self.f.one - self.b(u, v, color)**2/den

    def rotation(self, t: Element) -> tuple[Element, Element]:
        if t.field != self.f:
            raise TypeError("rotation parameter from another field")
        one = self.f.one
        den = one + t*t
        if den == self.f.zero:
            # Declared totalization, not analytic continuation.
            return -one, self.f.zero
        return (one-t*t)/den, (self.f.element(2)*t)/den

    def rotate(self, u: Vec2, t: Element) -> Vec2:
        c, s = self.rotation(t)
        return self.v(c*u.x-s*u.y, s*u.x+c*u.y)

    def step(
        self,
        state: Swarm,
        *,
        coupling: Element | None = None,
        speed: Element | None = None,
        allowed_quadrances: dict[str, frozenset[Element]] | None = None,
    ) -> Swarm:
        kappa = coupling if coupling is not None else self.f.one
        nu = speed if speed is not None else self.f.one
        if kappa.field != self.f or nu.field != self.f:
            raise TypeError("transition parameters must be in the plane field")
        guard = allowed_quadrances or {}
        if any(c not in ("b", "r", "g") or any(e.field != self.f for e in es)
               for c, es in guard.items()):
            raise ValueError("invalid chromatic neighborhood predicate")
        if any(self.q(a.heading, "b") != self.f.one for a in state.agents):
            raise ValueError("oriented headings must have blue quadrance 1")
        new_headings: list[Vec2] = []
        for i, a in enumerate(state.agents):
            t = self.f.zero
            for j, b in enumerate(state.agents):
                if i == j:
                    continue
                d = self.sub(b.position, a.position)
                if all(self.q(d, c) in admissible for c, admissible in guard.items()):
                    t = t + self.det(a.heading, b.heading)
            new_headings.append(self.rotate(a.heading, kappa*t))
        return Swarm(tuple(Agent(self.add(a.position, self.scale(nu, h)), h)
                           for a, h in zip(state.agents, new_headings)))

    def orbit(self, state: Swarm, **kwargs: object) -> tuple[int, int]:
        seen: dict[Swarm, int] = {}
        while state not in seen:
            seen[state] = len(seen)
            state = self.step(state, **kwargs)
        return seen[state], len(seen) - seen[state]
