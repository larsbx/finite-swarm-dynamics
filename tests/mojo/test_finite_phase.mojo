"""Smoke tests for compiled finite phase and modal Vicsek over F_7 and F_13."""
from std.testing import assert_true, assert_false
from finite_exact.fp import Fp, FpField
from chromogeometry.chromatic import ChromoVec2, chromo_blue
from swarm_models.finite_phase import finite_kuramoto_step, modal_vicsek_step


def v[p: Int64](x: Int64, y: Int64) -> ChromoVec2[FpField[p]]:
    return ChromoVec2[FpField[p]](Fp[p](x), Fp[p](y))


def weights[p: Int64]() -> List[List[Fp[p]]]:
    var out = List[List[Fp[p]]]()
    for i in range(3):
        var row = List[Fp[p]]()
        for j in range(3):
            row.append(Fp[p](1 if i != j else 0))
        out.append(row^)
    return out^


def mask_all(n: Int) -> List[List[Bool]]:
    var out = List[List[Bool]]()
    for i in range(n):
        var row = List[Bool]()
        for j in range(n):
            row.append(i != j)
        out.append(row^)
    return out^


def test_modal[p: Int64]() raises:
    var headings = List[ChromoVec2[FpField[p]]]()
    headings.append(v[p](1,0))
    headings.append(v[p](1,0))
    headings.append(v[p](0,1))
    var positions = List[ChromoVec2[FpField[p]]]()
    positions.append(v[p](0,0))
    positions.append(v[p](1,2))
    positions.append(v[p](2,1))
    var identity_noise = List[ChromoVec2[FpField[p]]]()
    for _ in range(3):
        identity_noise.append(v[p](1,0))
    var out = modal_vicsek_step[FpField[p]](
        positions, headings, mask_all(3), identity_noise, Fp[p](1)
    )
    assert_true(out.ok)
    for i in range(3):
        assert_true(out.headings[i].x == Fp[p](1))
        assert_true(out.headings[i].y == Fp[p](0))
        assert_true(out.positions[i].x == positions[i].x + Fp[p](1))
        assert_true(out.positions[i].y == positions[i].y)
    # An observed tie retains each old oriented heading.
    var two_headings = List[ChromoVec2[FpField[p]]]()
    two_headings.append(v[p](1,0))
    two_headings.append(v[p](0,1))
    var two_pos = List[ChromoVec2[FpField[p]]]()
    two_pos.append(v[p](0,0))
    two_pos.append(v[p](1,0))
    var two_noise = List[ChromoVec2[FpField[p]]]()
    two_noise.append(v[p](1,0))
    two_noise.append(v[p](1,0))
    var tied = modal_vicsek_step[FpField[p]](
        two_pos, two_headings, mask_all(2), two_noise, Fp[p](1)
    )
    assert_true(tied.ok)
    assert_true(tied.headings[0].x == Fp[p](1))
    assert_true(tied.headings[1].y == Fp[p](1))
    var bad_noise = List[ChromoVec2[FpField[p]]]()
    for _ in range(3):
        bad_noise.append(v[p](0,0))
    assert_false(modal_vicsek_step[FpField[p]](
        positions, headings, mask_all(3), bad_noise, Fp[p](1)
    ).ok)


def test_phase[p: Int64]() raises:
    var old = List[ChromoVec2[FpField[p]]]()
    old.append(v[p](1,0))
    old.append(v[p](1,0))
    old.append(v[p](1,0))
    var drift = List[ChromoVec2[FpField[p]]]()
    for _ in range(3):
        drift.append(v[p](0,1))
    var next = finite_kuramoto_step[FpField[p]](
        old, weights[p](), Fp[p](1), drift, v[p](1,0)
    )
    assert_true(next.ok)
    for i in range(3):
        assert_true(next.headings[i].x == Fp[p](0))
        assert_true(next.headings[i].y == Fp[p](1))
        assert_true(chromo_blue(next.headings[i]) == Fp[p](1))
    var anti = List[ChromoVec2[FpField[p]]]()
    anti.append(v[p](1,0))
    anti.append(v[p](-1,0))
    var w2 = List[List[Fp[p]]]()
    for i in range(2):
        var row = List[Fp[p]]()
        for j in range(2):
            row.append(Fp[p](0 if i == j else 1))
        w2.append(row^)
    var unitdrift = List[ChromoVec2[FpField[p]]]()
    unitdrift.append(v[p](1,0))
    unitdrift.append(v[p](1,0))
    var stable = finite_kuramoto_step[FpField[p]](
        anti, w2, Fp[p](1), unitdrift, v[p](1,0)
    )
    assert_true(stable.ok)
    assert_true(stable.headings[0].x == Fp[p](1))
    assert_true(stable.headings[1].x == Fp[p](-1))
    var bad = weights[p]()
    bad[0][0] = Fp[p](1)
    assert_false(finite_kuramoto_step[FpField[p]](
        old, bad, Fp[p](1), drift, v[p](1,0)
    ).ok)


def test_pole_f5() raises:
    # Cayley parameter t=2 has 1+t²=0 in F_5, so totalization is -I.
    var old = List[ChromoVec2[FpField[5]]]()
    old.append(v[5](1,0))
    old.append(v[5](0,1))
    var natural = List[ChromoVec2[FpField[5]]]()
    natural.append(v[5](1,0))
    natural.append(v[5](1,0))
    var w = List[List[Fp[5]]]()
    var a = List[Fp[5]]()
    a.append(Fp[5](0))
    a.append(Fp[5](2))
    w.append(a^)
    var b = List[Fp[5]]()
    b.append(Fp[5](0))
    b.append(Fp[5](0))
    w.append(b^)
    var next = finite_kuramoto_step[FpField[5]](
        old, w, Fp[5](1), natural, v[5](1,0)
    )
    assert_true(next.ok)
    assert_true(next.headings[0].x == Fp[5](4))
    assert_true(next.headings[0].y == Fp[5](0))


def main() raises:
    test_modal[7]()
    test_modal[13]()
    test_phase[7]()
    test_phase[13]()
    test_pole_f5()
    print("Compiled finite phase models passed: F_5, F_7, F_13.")
