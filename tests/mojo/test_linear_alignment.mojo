"""Compiled pinned-Mojo swarm alignment regression and exact F_7 reference.

Run with pinned finite-math-kernels kernel on the Mojo import path.
"""
from std.testing import assert_false, assert_true
from finite_exact.field import ExactField
from finite_exact.fp import Fp, FpField
from chromogeometry.chromatic import ChromoVec2, chromo_blue
from swarm_models.linear_alignment import alignment_step, flock_step


def vector[p: Int64](x: Int64, y: Int64) -> ChromoVec2[FpField[p]]:
    return ChromoVec2[FpField[p]](Fp[p](x), Fp[p](y))


def chain3[p: Int64]() -> List[List[Fp[p]]]:
    # First agent reads second, second reads third, third retains itself.
    var pmat = List[List[Fp[p]]]()
    var a = List[Fp[p]]()
    a.append(Fp[p](0))
    a.append(Fp[p](1))
    a.append(Fp[p](0))
    pmat.append(a^)
    var b = List[Fp[p]]()
    b.append(Fp[p](0))
    b.append(Fp[p](0))
    b.append(Fp[p](1))
    pmat.append(b^)
    var c = List[Fp[p]]()
    c.append(Fp[p](0))
    c.append(Fp[p](0))
    c.append(Fp[p](1))
    pmat.append(c^)
    return pmat^


def test_chain[p: Int64]() raises:
    var v = List[ChromoVec2[FpField[p]]]()
    v.append(vector[p](1, 2))
    v.append(vector[p](3, 4))
    v.append(vector[p](5, 6))
    var weights = chain3[p]()
    var first = alignment_step[FpField[p]](weights, v)
    assert_true(first.ok)
    assert_true(first.velocities[0].x == Fp[p](3))
    assert_true(first.velocities[1].x == Fp[p](5))
    assert_true(first.velocities[2].x == Fp[p](5))
    var second = alignment_step[FpField[p]](weights, first.velocities)
    assert_true(second.ok)
    for i in range(3):
        assert_true(second.velocities[i].x == Fp[p](5))
        assert_true(second.velocities[i].y == Fp[p](6))

    var pos = List[ChromoVec2[FpField[p]]]()
    pos.append(vector[p](0, 0))
    pos.append(vector[p](1, 2))
    pos.append(vector[p](2, 1))
    var motion = flock_step[FpField[p]](weights, pos, v, Fp[p](1))
    assert_true(motion.ok)
    assert_true(motion.positions[0].x == Fp[p](3))
    assert_true(motion.positions[0].y == Fp[p](4))
    assert_true(motion.positions[1].x == Fp[p](6))
    assert_true(motion.positions[2].x == Fp[p](7))
    assert_true(chromo_blue(motion.velocities[0]) == Fp[p](25))


def test_rejects() raises:
    var weights = chain3[7]()
    var v = List[ChromoVec2[FpField[7]]]()
    v.append(vector[7](1, 0))
    assert_false(alignment_step[FpField[7]](weights, v).ok)
    var vv = List[ChromoVec2[FpField[7]]]()
    vv.append(vector[7](1, 0))
    vv.append(vector[7](0, 1))
    vv.append(vector[7](1, 1))
    var malformed = List[List[Fp[7]]]()
    var r0 = List[Fp[7]]()
    r0.append(Fp[7](1))
    r0.append(Fp[7](1))
    r0.append(Fp[7](0))
    malformed.append(r0^)
    var r1 = List[Fp[7]]()
    r1.append(Fp[7](0))
    r1.append(Fp[7](0))
    r1.append(Fp[7](1))
    malformed.append(r1^)
    var r2 = List[Fp[7]]()
    r2.append(Fp[7](0))
    r2.append(Fp[7](0))
    r2.append(Fp[7](1))
    malformed.append(r2^)
    assert_false(alignment_step[FpField[7]](malformed, vv).ok)
    # An algebraic matrix is not allowed to use rejected coefficients.
    var invalid = chain3[7]()
    invalid[0][1] = Fp[7].rejected_value()
    assert_false(alignment_step[FpField[7]](invalid, vv).ok)


def main() raises:
    test_chain[7]()
    test_chain[13]()
    test_rejects()
    print("Compiled field-generic Mojo alignment passed for F_7 and F_13.")
