"""First-class exact rational geometry, ordered interactions and consensus.

Independent, non-authoritative Python reference semantics. Canonical Mojo
rational implementation is QField and Q in larsbx/finite-math-kernels.
No floats, implicit approximations, analytic limits or unguarded inverses.
"""
from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import isqrt
from typing import Literal

Color = Literal["b", "r", "g"]
COLORS: tuple[Color, ...] = ("b", "r", "g")


def rational(value: int | Fraction) -> Fraction:
    """Exact public constructor: refuse floats and bools."""
    if type(value) is int:
        return Fraction(value)
    if isinstance(value, Fraction):
        return value
    raise TypeError("scalar must be an integer or exact Fraction; floats forbidden")


@dataclass(frozen=True)
class VecQ:
    x: Fraction
    y: Fraction

    def __post_init__(self) -> None:
        if not isinstance(self.x, Fraction) or not isinstance(self.y, Fraction):
            raise TypeError("VecQ coordinates must be canonical Fractions")


def vec(x: int | Fraction, y: int | Fraction) -> VecQ:
    return VecQ(rational(x), rational(y))


def add(u: VecQ, v: VecQ) -> VecQ:
    return vec(u.x + v.x, u.y + v.y)


def sub(u: VecQ, v: VecQ) -> VecQ:
    return vec(u.x - v.x, u.y - v.y)


def scale(a: int | Fraction, u: VecQ) -> VecQ:
    t = rational(a)
    return vec(t*u.x, t*u.y)


def det(u: VecQ, v: VecQ) -> Fraction:
    return u.x*v.y - u.y*v.x


def q(u: VecQ, color: Color = "b") -> Fraction:
    x, y = u.x, u.y
    if color == "b":
        return x*x+y*y
    if color == "r":
        return x*x-y*y
    if color == "g":
        return 2*x*y
    raise ValueError(f"unknown color {color!r}")


def bilinear(u: VecQ, v: VecQ, color: Color = "b") -> Fraction:
    a, b, c, d = u.x, u.y, v.x, v.y
    if color == "b":
        return a*c + b*d
    if color == "r":
        return a*c - b*d
    if color == "g":
        return a*d + b*c
    raise ValueError(f"unknown color {color!r}")


def spread(u: VecQ, v: VecQ, color: Color = "b") -> Fraction | None:
    """None exactly when either color quadrance is zero."""
    den = q(u, color)*q(v, color)
    if den == 0:
        return None
    return 1 - bilinear(u, v, color)**2/den


def quadrea(a: VecQ, b: VecQ, c: VecQ, color: Color = "b") -> Fraction:
    d1, d2, d3 = (q(sub(b, c), color), q(sub(a, c), color),
                  q(sub(a, b), color))
    return (d1+d2+d3)**2 - 2*(d1*d1+d2*d2+d3*d3)


def projectively_equal(u: VecQ, v: VecQ) -> bool:
    if u == vec(0, 0) or v == vec(0, 0):
        raise ValueError("zero vector is not a projective direction")
    return det(u, v) == 0


def rational_rotation(t: int | Fraction) -> tuple[Fraction, Fraction]:
    """Rational Cayley chart; 1+t²>0 for every rational t."""
    t = rational(t)
    denominator = 1+t*t
    assert denominator > 0
    return ((1-t*t)/denominator, 2*t/denominator)


def rotate(u: VecQ, t: int | Fraction) -> VecQ:
    c, s = rational_rotation(t)
    return vec(c*u.x-s*u.y, s*u.x+c*u.y)


def half_turn(u: VecQ) -> VecQ:
    """Exceptional rational rotor not represented by finite Cayley t."""
    return vec(-u.x, -u.y)


def blue_ball(a: VecQ, b: VecQ, radius_squared: int | Fraction) -> bool:
    """True Euclidean-radial squared-distance predicate over ordered Q."""
    r2 = rational(radius_squared)
    if r2 < 0:
        raise ValueError("squared radius must be nonnegative")
    return q(sub(a, b), "b") <= r2


def color_interval(
    a: VecQ, b: VecQ, color: Color,
    lower: int | Fraction, upper: int | Fraction,
) -> bool:
    """Ordered bounds on a quadratic observable; red/green are not metrics."""
    lo, hi = rational(lower), rational(upper)
    if hi < lo:
        raise ValueError("interval upper bound is smaller than lower bound")
    value = q(sub(a, b), color)
    return lo <= value <= hi


def exact_probability(favorable: int, possible: int) -> Fraction:
    """Finite counting probability; denominator and range checked."""
    if type(favorable) is not int or type(possible) is not int:
        raise TypeError("probability counts must be integers")
    if possible <= 0 or favorable < 0 or favorable > possible:
        raise ValueError("counts must satisfy 0 <= favorable <= possible > 0")
    return Fraction(favorable, possible)


def _odd_prime(p: int) -> bool:
    return (type(p) is int and p >= 3 and p % 2 == 1
            and all(p % k for k in range(2, isqrt(p)+1)))


def reduce_mod_prime(value: int | Fraction, p: int) -> int:
    """Partial localization Z_(p)->F_p; refuses denominators divisible by p.

    There is no total field homomorphism Q->F_p, and rational inequalities
    must never be transported through reduction.
    """
    if not _odd_prime(p):
        raise ValueError("p must be an odd prime in the chromogeometry regime")
    f = rational(value)
    den = f.denominator % p
    if den == 0:
        raise ZeroDivisionError("rational denominator is nonunit modulo p")
    return f.numerator * pow(den, -1, p) % p


def reduce_vec_mod_prime(u: VecQ, p: int) -> tuple[int, int]:
    return (reduce_mod_prime(u.x, p), reduce_mod_prime(u.y, p))


@dataclass(frozen=True)
class FlockQ:
    positions: tuple[VecQ, ...]
    velocities: tuple[VecQ, ...]


@dataclass(frozen=True)
class RationalConsensus:
    """Exact algebraic row-unital update over Q.

    Convexity (all entries >=0) is a separate *ordered* property.
    """

    rows: tuple[tuple[Fraction, ...], ...]

    def __post_init__(self) -> None:
        n = len(self.rows)
        if n == 0 or any(len(row) != n for row in self.rows):
            raise ValueError("consensus matrix must be nonempty and square")
        if any(any(not isinstance(value, Fraction) for value in row)
               for row in self.rows):
            raise TypeError("weights must be exact Fractions")
        if any(sum(row, Fraction(0)) != 1 for row in self.rows):
            raise ValueError("each algebraic row must sum to one")

    @property
    def n(self) -> int:
        return len(self.rows)

    @property
    def convex(self) -> bool:
        return all(weight >= 0 for row in self.rows for weight in row)

    @property
    def doubly_stochastic(self) -> bool:
        return (self.convex and
                all(sum((self.rows[i][j] for i in range(self.n)), Fraction(0)) == 1
                    for j in range(self.n)))

    def update_velocities(self, velocities: tuple[VecQ, ...]) -> tuple[VecQ, ...]:
        if len(velocities) != self.n:
            raise ValueError("velocity dimension mismatch")
        return tuple(
            vec(sum((weight*v.x for weight, v in zip(row, velocities)), Fraction(0)),
                sum((weight*v.y for weight, v in zip(row, velocities)), Fraction(0)))
            for row in self.rows
        )

    def step(self, flock: FlockQ, speed: int | Fraction = 1) -> FlockQ:
        if len(flock.positions) != self.n or len(flock.velocities) != self.n:
            raise ValueError("flock dimension mismatch")
        new_vel = self.update_velocities(flock.velocities)
        return FlockQ(
            positions=tuple(add(pos, scale(speed, v)) for pos, v in
                            zip(flock.positions, new_vel)),
            velocities=new_vel,
        )


def rational_mean(values: tuple[VecQ, ...]) -> VecQ:
    if not values:
        raise ValueError("the exact mean of an empty collection is undefined")
    return scale(Fraction(1, len(values)),
                 vec(sum((v.x for v in values), Fraction(0)),
                     sum((v.y for v in values), Fraction(0))))


def disagreement_two(v: tuple[VecQ, VecQ]) -> Fraction:
    return q(sub(v[0], v[1]), "b")


def symmetric_two_agent_consensus(a: int | Fraction) -> RationalConsensus:
    """P=[[1-a,a],[a,1-a]]; convex iff 0 <= a <= 1."""
    a = rational(a)
    return RationalConsensus(((1-a, a), (a, 1-a)))


def symmetric_contraction_factor(a: int | Fraction) -> Fraction:
    """Exact energy factor: E(Pv) = (1-2a)^2 E(v), for two agents."""
    a = rational(a)
    return (1-2*a)**2
