"""Exact planar chromogeometry over odd prime fields and a finite swarm map.

No real/complex arithmetic, transcendentals, floating point, or ordered fields.
General extension fields are not implemented in this reference kernel.
"""
from __future__ import annotations

from dataclasses import dataclass
from math import isqrt
from typing import Literal

Color = Literal["b", "r", "g"]
COLORS: tuple[Color, ...] = ("b", "r", "g")


def prime(n: int) -> bool:
    if n < 2:
        return False
    for i in range(2, isqrt(n) + 1):
        if n % i == 0:
            return False
    return True


@dataclass(frozen=True)
class Vec:
    x: int
    y: int


@dataclass(frozen=True)
class HPoint:
    x: int
    y: int
    z: int


@dataclass(frozen=True)
class HLine:
    a: int
    b: int
    c: int


@dataclass(frozen=True)
class Agent:
    position: Vec
    heading: Vec  # Oriented blue unit-quadrance vector, not a projective ray.


@dataclass(frozen=True)
class Swarm:
    agents: tuple[Agent, ...]


class Chromo:
    def __init__(self, p: int):
        if p % 2 != 1 or not prime(p):
            raise ValueError("p must be an odd prime")
        self.p = p

    def v(self, x: int, y: int) -> Vec:
        return Vec(x % self.p, y % self.p)

    def add(self, u: Vec, v: Vec) -> Vec:
        return self.v(u.x + v.x, u.y + v.y)

    def sub(self, u: Vec, v: Vec) -> Vec:
        return self.v(u.x - v.x, u.y - v.y)

    def neg(self, u: Vec) -> Vec:
        return self.v(-u.x, -u.y)

    def scale(self, a: int, u: Vec) -> Vec:
        return self.v(a * u.x, a * u.y)

    def affine_lift(self, v: Vec) -> HPoint:
        return HPoint(v.x % self.p, v.y % self.p, 1)

    def _zero_point(self, x: HPoint) -> bool:
        return x.x % self.p == x.y % self.p == x.z % self.p == 0

    def _cross_triple(
        self, u: tuple[int, int, int], v: tuple[int, int, int]
    ) -> tuple[int, int, int]:
        a, b, c = u
        x, y, z = v
        return ((b*z-c*y) % self.p, (c*x-a*z) % self.p, (a*y-b*x) % self.p)

    def projective_equal(self, x: HPoint, y: HPoint) -> bool:
        if self._zero_point(x) or self._zero_point(y):
            raise ValueError("zero triple is not a projective point")
        return self._cross_triple((x.x, x.y, x.z), (y.x, y.y, y.z)) == (0, 0, 0)

    def join(self, x: HPoint, y: HPoint) -> HLine:
        if self._zero_point(x) or self._zero_point(y):
            raise ValueError("zero triple is not a projective point")
        a, b, c = self._cross_triple((x.x, x.y, x.z), (y.x, y.y, y.z))
        if a == b == c == 0:
            raise ValueError("joining identical projective points is not unique")
        return HLine(a, b, c)

    def meet(self, x: HLine, y: HLine) -> HPoint:
        if (x.a % self.p, x.b % self.p, x.c % self.p) == (0, 0, 0) or (
            y.a % self.p, y.b % self.p, y.c % self.p
        ) == (0, 0, 0):
            raise ValueError("zero triple is not a projective line")
        a, b, c = self._cross_triple((x.a, x.b, x.c), (y.a, y.b, y.c))
        if a == b == c == 0:
            raise ValueError("meeting identical projective lines is not unique")
        return HPoint(a, b, c)

    def incident(self, pt: HPoint, line: HLine) -> bool:
        if self._zero_point(pt) or (
            line.a % self.p, line.b % self.p, line.c % self.p
        ) == (0, 0, 0):
            raise ValueError("invalid homogeneous projective object")
        return (pt.x*line.a + pt.y*line.b + pt.z*line.c) % self.p == 0

    def collinear(self, x: HPoint, y: HPoint, z: HPoint) -> bool:
        if any(self._zero_point(pt) for pt in (x, y, z)):
            raise ValueError("invalid homogeneous projective point")
        a, b, c = self._cross_triple((x.x, x.y, x.z), (y.x, y.y, y.z))
        return (a*z.x + b*z.y + c*z.z) % self.p == 0

    def inv(self, a: int) -> int:
        a %= self.p
        if a == 0:
            raise ZeroDivisionError("field inverse requires nonzero operand")
        return pow(a, self.p - 2, self.p)

    def q(self, u: Vec, color: Color) -> int:
        x, y = u.x % self.p, u.y % self.p
        if color == "b":
            z = x*x + y*y
        elif color == "r":
            z = x*x - y*y
        elif color == "g":
            z = 2*x*y
        else:
            raise ValueError(color)
        return z % self.p

    def bilinear(self, u: Vec, v: Vec, color: Color) -> int:
        a, b, c, d = u.x, u.y, v.x, v.y
        if color == "b":
            z = a*c + b*d
        elif color == "r":
            z = a*c - b*d
        elif color == "g":
            z = a*d + b*c
        else:
            raise ValueError(color)
        return z % self.p

    def det(self, u: Vec, v: Vec) -> int:
        return (u.x*v.y - u.y*v.x) % self.p

    def spread(self, u: Vec, v: Vec, color: Color) -> int | None:
        """Undefined (None) if either color quadrance is zero."""
        den = self.q(u, color)*self.q(v, color) % self.p
        if den == 0:
            return None
        b = self.bilinear(u, v, color)
        return (1 - b*b*self.inv(den)) % self.p

    def quadrea(self, a: Vec, b: Vec, c: Vec, color: Color) -> int:
        q1 = self.q(self.sub(b, c), color)
        q2 = self.q(self.sub(a, c), color)
        q3 = self.q(self.sub(a, b), color)
        return ((q1 + q2 + q3)**2 - 2*(q1*q1 + q2*q2 + q3*q3)) % self.p

    def rotation(self, t: int) -> tuple[int, int]:
        """Cayley rotation; 1+t²=0 uses a declared policy branch R=-I."""
        t %= self.p
        den = (1 + t*t) % self.p
        if den == 0:
            return (-1 % self.p, 0)
        d = self.inv(den)
        return ((1 - t*t)*d % self.p, 2*t*d % self.p)

    def rotate(self, u: Vec, t: int) -> Vec:
        c, s = self.rotation(t)
        return self.v(c*u.x - s*u.y, s*u.x + c*u.y)

    def chromatic_observation(self, a: Agent, b: Agent) -> dict:
        return {
            "quadrances": {c: self.q(self.sub(b.position, a.position), c) for c in COLORS},
            "spreads": {c: self.spread(a.heading, b.heading, c) for c in COLORS},
            "orientation": self.det(a.heading, b.heading),
        }

    def step(
        self,
        state: Swarm,
        *,
        coupling: int = 1,
        speed: int = 1,
        allowed_quadrances: dict[Color, frozenset[int]] | None = None,
    ) -> Swarm:
        """Synchronous finite-field swarm map with selected color guards.

        Edge i-j is active iff all configured quadrance-membership tests pass.
        Every active edge has field weight 1. No finite-field order is used.
        """
        for a in state.agents:
            if self.q(a.heading, "b") != 1:
                raise ValueError("oriented heading must have blue quadrance 1")
        masks = allowed_quadrances or {}
        old = state.agents
        new_headings: list[Vec] = []
        for i, agent in enumerate(old):
            t = 0
            for j, other in enumerate(old):
                if i == j:
                    continue
                offset = self.sub(other.position, agent.position)
                if all(self.q(offset, c) in allowed for c, allowed in masks.items()):
                    t += self.det(agent.heading, other.heading)
            new_headings.append(self.rotate(agent.heading, coupling*t))
        new_agents = tuple(
            Agent(self.add(a.position, self.scale(speed, h)), h)
            for a, h in zip(old, new_headings)
        )
        return Swarm(new_agents)

    def orbit(self, state: Swarm, **kwargs) -> tuple[int, int]:
        """Return transient length and eventual cycle period."""
        seen: dict[Swarm, int] = {}
        i = 0
        while state not in seen:
            seen[state] = i
            i += 1
            state = self.step(state, **kwargs)
        return (seen[state], i - seen[state])
