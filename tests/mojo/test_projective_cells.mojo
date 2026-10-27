"""SGC-1 test-first compiled geometry, topology, and circulation contracts."""
from std.testing import assert_true, assert_false
from finite_exact.fp import Fp, FpField
from chromogeometry.chromatic import ChromoVec2
from swarm_models.projective_cells import (
    check_quad_cell, inspect_complex, cycle_circulation,
)


def vec[p: Int64](x: Int64, y: Int64) -> ChromoVec2[FpField[p]]:
    return ChromoVec2[FpField[p]](Fp[p](x), Fp[p](y))


def allowed_zero[p: Int64]() -> List[Fp[p]]:
    var values = List[Fp[p]]()
    values.append(Fp[p](0))
    return values^


def square_edges() -> List[Bool]:
    var edges = List[Bool]()
    for _ in range(4):
        edges.append(True)
    return edges^


def test_cells[p: Int64]() raises:
    var a = vec[p](0, 0)
    var b = vec[p](1, 0)
    var c = vec[p](0, 1)
    var d = vec[p](1, 1)
    var edges = square_edges()
    var zero = allowed_zero[p]()
    var square = check_quad_cell[FpField[p]](a, b, c, d, edges, zero)
    assert_true(square.ok and square.attaches)
    assert_true(square.first == Fp[p](0))
    assert_true(square.second == Fp[p](0))

    # D=B+C-A is the only exact planar zero-spread completion.
    var skew = vec[p](2, 1)
    var rejected = check_quad_cell[FpField[p]](
        a, b, c, skew, edges, zero
    )
    assert_true(rejected.ok)
    assert_false(rejected.attaches)
    assert_true(rejected.first == Fp[p](0))
    assert_true(rejected.second == FpField[p].div(Fp[p](1), Fp[p](2)))

    var tolerate = allowed_zero[p]()
    tolerate.append(FpField[p].div(Fp[p](1), Fp[p](2)))
    var widened = check_quad_cell[FpField[p]](
        a, b, c, skew, edges, tolerate
    )
    assert_true(widened.ok and widened.attaches)
    var absent = square_edges()
    absent[2] = False
    var missing_edge = check_quad_cell[FpField[p]](
        a, b, c, d, absent, zero
    )
    assert_true(missing_edge.ok)
    assert_false(missing_edge.attaches)
    assert_false(check_quad_cell[FpField[p]](
        a, b, c, d, List[Bool](), zero
    ).ok)
    assert_false(check_quad_cell[FpField[p]](
        a, b, c, c, edges, zero
    ).ok)
    assert_false(check_quad_cell[FpField[p]](
        a, b, vec[p](2, 0), vec[p](3, 0), edges, zero
    ).ok)
    var bad_set = allowed_zero[p]()
    bad_set.append(Fp[p].rejected_value())
    assert_false(check_quad_cell[FpField[p]](
        a, b, c, d, edges, bad_set
    ).ok)


def square_boundary1[p: Int64]() -> List[List[Fp[p]]]:
    # Ordered edges are A->B, B->D, D->C, C->A.
    var rows = List[List[Fp[p]]]()
    for vertex in range(4):
        var row = List[Fp[p]]()
        for edge in range(4):
            if vertex == edge:
                row.append(Fp[p](-1))
            elif vertex == (edge + 1) % 4:
                row.append(Fp[p](1))
            else:
                row.append(Fp[p](0))
        rows.append(row^)
    return rows^


def square_boundary2[p: Int64](faces: Int) -> List[List[Fp[p]]]:
    var rows = List[List[Fp[p]]]()
    for _ in range(4):
        var row = List[Fp[p]]()
        for _ in range(faces):
            row.append(Fp[p](1))
        rows.append(row^)
    return rows^


def test_homology_and_circulation[p: Int64]() raises:
    var d1 = square_boundary1[p]()
    var no_faces = square_boundary2[p](0)
    var unfilled = inspect_complex[FpField[p]](d1, no_faces)
    assert_true(unfilled.ok)
    assert_true(unfilled.beta0 == 1)
    assert_true(unfilled.beta1 == 1)
    assert_true(unfilled.beta2 == 0)

    var filled = square_boundary2[p](1)
    var disk = inspect_complex[FpField[p]](d1, filled)
    assert_true(disk.ok)
    assert_true(disk.beta0 == 1)
    assert_true(disk.beta1 == 0)
    assert_true(disk.beta2 == 0)

    # Redundant cell increases H2, not further decreasing H1.
    var two_faces = square_boundary2[p](2)
    var sphere = inspect_complex[FpField[p]](d1, two_faces)
    assert_true(sphere.ok)
    assert_true(sphere.beta0 == 1)
    assert_true(sphere.beta1 == 0)
    assert_true(sphere.beta2 == 1)

    var bad_faces = square_boundary2[p](1)
    bad_faces[1][0] = Fp[p](0)
    assert_false(inspect_complex[FpField[p]](d1, bad_faces).ok)

    var cycle = List[Fp[p]]()
    var flow = List[Fp[p]]()
    for i in range(4):
        cycle.append(Fp[p](1))
        flow.append(Fp[p](Int64(1 if i == 0 else 0)))
    var circulating = cycle_circulation[FpField[p]](d1, cycle, flow)
    assert_true(circulating.ok)
    assert_true(circulating.value == Fp[p](1))
    # Attaching a face does not make a physical flow cochain closed.
    assert_true(disk.beta1 == 0 and circulating.value == Fp[p](1))
    var still = List[Fp[p]]()
    for _ in range(4):
        still.append(Fp[p](0))
    var stationary = cycle_circulation[FpField[p]](d1, cycle, still)
    assert_true(stationary.ok and stationary.value == Fp[p](0))
    cycle[0] = Fp[p](0)
    assert_false(cycle_circulation[FpField[p]](d1, cycle, flow).ok)


def test_isotropic_guard() raises:
    # 1^2+2^2=0 modulo 5 even though the heading is nonzero.
    var a = vec[5](0, 0)
    var b = vec[5](1, 2)
    var c = vec[5](0, 1)
    var d = vec[5](1, 3)
    assert_false(check_quad_cell[FpField[5]](
        a, b, c, d, square_edges(), allowed_zero[5]()
    ).ok)


def main() raises:
    test_cells[7]()
    test_cells[13]()
    test_homology_and_circulation[7]()
    test_homology_and_circulation[13]()
    test_isotropic_guard()
    print("SGC-1 compiled exact projective-cell and homology contracts passed.")
