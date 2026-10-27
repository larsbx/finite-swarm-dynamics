"""Compiled finite-field inclusion-image checks, including a filled-class control."""
from std.testing import assert_true, assert_false
from finite_exact.fp import Fp, FpField
from swarm_models.leader_coverage import verify_leader_coverage


def square_d1[p: Int64]() -> List[List[Fp[p]]]:
    # Four consistently oriented edges: 0->1->2->3->0.
    var rows = List[List[Fp[p]]]()
    for v in range(4):
        var row = List[Fp[p]]()
        for e in range(4):
            if v == e:
                row.append(Fp[p](-1))
            elif v == (e + 1) % 4:
                row.append(Fp[p](1))
            else:
                row.append(Fp[p](0))
        rows.append(row^)
    return rows^


def square_d2[p: Int64](filled: Bool) -> List[List[Fp[p]]]:
    var rows = List[List[Fp[p]]]()
    for _ in range(4):
        var row = List[Fp[p]]()
        if filled:
            row.append(Fp[p](1))
        rows.append(row^)
    return rows^


def square_cycle[p: Int64]() -> List[Fp[p]]:
    var z = List[Fp[p]]()
    for _ in range(4):
        z.append(Fp[p](1))
    return z^


def pins(v: Int) -> List[Bool]:
    var s = List[Bool]()
    for i in range(4):
        s.append(i == v)
    return s^


def test_square[p: Int64]() raises:
    var d1 = square_d1[p]()
    var d2 = square_d2[p](False)
    var z = square_cycle[p]()
    var no_pins = List[Bool]()
    for _ in range(4):
        no_pins.append(False)

    # The unfilled fundamental class has an unpinned representative.
    var raw = verify_leader_coverage[FpField[p]](d1, d2, z, no_pins)
    assert_true(raw.ok)
    assert_false(raw.covered)
    for e in range(4):
        assert_true(raw.witness[e] == Fp[p](1))

    # One leader removes its graph neighborhood and all remaining cycle routes.
    var covered = verify_leader_coverage[FpField[p]](d1, d2, z, pins(0))
    assert_true(covered.ok)
    assert_true(covered.covered)
    assert_true(len(covered.witness) == 0)

    # A filled boundary is the zero homology class. It remains in the image
    # even when all edges of U are removed: do NOT label this class covered.
    var filled = square_d2[p](True)
    var zero_class = verify_leader_coverage[FpField[p]](
        d1, filled, z, pins(0)
    )
    assert_true(zero_class.ok)
    assert_false(zero_class.covered)
    for e in range(4):
        assert_true(zero_class.witness[e] == Fp[p](0))

    # Not a cycle: refuse rather than claim it is covered.
    var bad_z = square_cycle[p]()
    bad_z[0] = Fp[p](0)
    var invalid = verify_leader_coverage[FpField[p]](
        d1, d2, bad_z, no_pins
    )
    assert_false(invalid.ok)

    # Non-chain d2 (boundary of a single oriented edge) is rejected.
    var bad_d2 = square_d2[p](False)
    for e in range(4):
        bad_d2[e].append(Fp[p](Int64(1 if e == 0 else 0)))
    assert_false(verify_leader_coverage[FpField[p]](
        d1, bad_d2, z, no_pins
    ).ok)


def main() raises:
    test_square[7]()
    test_square[13]()
    print("Compiled exact leader homology image checks passed: F_7, F_13.")
