"""First-class Q exact arithmetic and ordered consensus via canonical Mojo.

This is a consumer of existing finite-math-kernels QField, Q, and chromatic
geometry, not a parallel implementation of rationals in the swarm repository.
"""
from std.testing import assert_true, assert_false
from finite_exact.field import QField
from finite_exact.rat_q import Q
from chromogeometry.chromatic import (
    ChromoVec2, chromo_blue, chromo_red, chromo_green, chromo_det,
    chromo_blue_spread, chromo_red_spread, chromo_green_spread,
    chromo_gram_identity, chromo_harmonic_spread, chromo_pythagoras,
)
from swarm_models.linear_alignment import alignment_step, flock_step


def v(x: Q, y: Q) -> ChromoVec2[QField]:
    return ChromoVec2[QField](x, y)


def test_rational_chromogeometry() raises:
    var u = v(Q(1,1), Q(2,1))
    var w = v(Q(2,1), Q(1,1))
    assert_true(QField.eq(chromo_blue(u), Q(5,1)))
    assert_true(QField.eq(chromo_red(u), Q(-3,1)))
    assert_true(QField.eq(chromo_green(u), Q(4,1)))
    assert_true(QField.eq(chromo_det(u, w), Q(-3,1)))
    assert_true(QField.eq(chromo_blue_spread(u,w), Q(9,25)))
    assert_true(QField.eq(chromo_red_spread(u,w), Q(1,1)))
    assert_true(QField.eq(chromo_green_spread(u,w), Q(-9,16)))
    assert_true(chromo_harmonic_spread(u,w))
    assert_true(chromo_pythagoras(u))
    assert_true(chromo_gram_identity(u,w,0))
    assert_true(chromo_gram_identity(u,w,1))
    assert_true(chromo_gram_identity(u,w,2))
    var null_green = v(Q(1,1), Q.zero())
    assert_false(chromo_green_spread(u,null_green).accepted())
    assert_false(Q(1,0).accepted())
    assert_false(Q(2,3).div(Q.zero()).accepted())
    # Rational strict order is exact and does not require real approximations.
    assert_true(Q(-3,5).lt(Q(2,3)))


def test_exact_rational_average_and_contraction() raises:
    # Symmetric rational convex averaging: disagreement energy drops by 1/4.
    var rows = List[List[Q]]()
    var row0 = List[Q]()
    row0.append(Q(3,4))
    row0.append(Q(1,4))
    rows.append(row0^)
    var row1 = List[Q]()
    row1.append(Q(1,4))
    row1.append(Q(3,4))
    rows.append(row1^)
    var velocities = List[ChromoVec2[QField]]()
    velocities.append(v(Q(1,1),Q.zero()))
    velocities.append(v(Q.zero(),Q(1,1)))
    var next = alignment_step[QField](rows,velocities)
    assert_true(next.ok)
    assert_true(QField.eq(next.velocities[0].x,Q(3,4)))
    assert_true(QField.eq(next.velocities[0].y,Q(1,4)))
    assert_true(QField.eq(next.velocities[1].x,Q(1,4)))
    assert_true(QField.eq(next.velocities[1].y,Q(3,4)))
    var before = v(Q(1,1),Q(-1,1))
    var after = v(
        QField.sub(next.velocities[0].x,next.velocities[1].x),
        QField.sub(next.velocities[0].y,next.velocities[1].y)
    )
    var before_energy = chromo_blue(before)
    var after_energy = chromo_blue(after)
    assert_true(QField.eq(before_energy,Q(2,1)))
    assert_true(QField.eq(after_energy,Q(1,2)))
    assert_true(QField.eq(after_energy,QField.mul(Q(1,4),before_energy)))
    assert_true(after_energy.lt(before_energy))
    # Average remains exactly (1/2,1/2), and does not reach consensus
    # at any finite iteration when the disagreement is initially nonzero.
    assert_true(QField.eq(QField.div(
        QField.add(next.velocities[0].x,next.velocities[1].x),Q(2,1)),Q(1,2)))
    var positions = List[ChromoVec2[QField]]()
    positions.append(v(Q.zero(),Q.zero()))
    positions.append(v(Q.one(),Q.one()))
    var moved = flock_step[QField](rows,positions,velocities,Q(1,2))
    assert_true(moved.ok)
    assert_true(QField.eq(moved.positions[0].x,Q(3,8)))
    assert_true(QField.eq(moved.positions[0].y,Q(1,8)))
    assert_true(QField.eq(moved.positions[1].x,Q(9,8)))
    assert_true(QField.eq(moved.positions[1].y,Q(11,8)))

    # A merely row-unital signed matrix is not automatically dissipative.
    var signed = List[List[Q]]()
    var s0 = List[Q]()
    s0.append(Q(-1,2))
    s0.append(Q(3,2))
    signed.append(s0^)
    var s1 = List[Q]()
    s1.append(Q(3,2))
    s1.append(Q(-1,2))
    signed.append(s1^)
    var bad = alignment_step[QField](signed,velocities)
    assert_true(bad.ok)
    var growing = v(
        QField.sub(bad.velocities[0].x,bad.velocities[1].x),
        QField.sub(bad.velocities[0].y,bad.velocities[1].y)
    )
    assert_true(QField.eq(chromo_blue(growing),Q(8,1)))


def main() raises:
    test_rational_chromogeometry()
    test_exact_rational_average_and_contraction()
    print("PASS: first-class Q field geometry, averaging, ordered decay and signed counterexample.")
