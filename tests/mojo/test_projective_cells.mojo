"""SGC-1 test-first compiled geometry, topology, and circulation contracts."""
from std.testing import assert_true, assert_false
from finite_exact.fp import Fp, FpField
from chromogeometry.chromatic import ChromoVec2
from swarm_models.projective_cells import (
    check_quad_cell, inspect_complex, cycle_circulation,\n    certify_quad_face, build_quad_complex, verify_cellular_stokes,
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




def test_cycle_relabeling[p: Int64]() raises:
    var a = vec[p](0, 0)
    var b = vec[p](1, 0)
    var c = vec[p](0, 1)
    var d = vec[p](1, 1)
    var z = allowed_zero[p]()
    var edges = square_edges()
    var root = check_quad_cell[FpField[p]](a, b, c, d, edges, z)
    var rotate = check_quad_cell[FpField[p]](b, d, a, c, edges, z)
    var reverse = check_quad_cell[FpField[p]](a, c, b, d, edges, z)
    assert_true(root.ok and rotate.ok and reverse.ok)
    assert_true(root.attaches and rotate.attaches and reverse.attaches)

    # F7 regression: A,B,D are collinear, but A,B,C are not.
    # Old root-dependent guard admitted the cycle while rotation rejected it.
    var qd = vec[7](2, 0)
    var all_spreads = List[Fp[7]]()
    for x in range(7):
        all_spreads.append(Fp[7](Int64(x)))
    assert_false(check_quad_cell[FpField[7]](
        vec[7](0, 0), vec[7](1, 0), vec[7](0, 1),
        qd, square_edges(), all_spreads
    ).ok)
    assert_false(check_quad_cell[FpField[7]](
        vec[7](1, 0), qd, vec[7](0, 0), vec[7](0, 1),
        square_edges(), all_spreads
    ).ok)


def test_geometry_to_chain[p: Int64]() raises:
    var points = List[ChromoVec2[FpField[p]]]()
    points.append(vec[p](0, 0))
    points.append(vec[p](1, 0))
    points.append(vec[p](0, 1))
    points.append(vec[p](1, 1))
    var tails = List[Int]()
    var heads = List[Int]()
    tails.append(0)
    heads.append(1)
    tails.append(1)
    heads.append(3)
    tails.append(3)
    heads.append(2)
    tails.append(2)
    heads.append(0)

    var quad = List[Int]()
    quad.append(0)
    quad.append(1)
    quad.append(2)
    quad.append(3)
    var rotated = List[Int]()
    rotated.append(1)
    rotated.append(3)
    rotated.append(0)
    rotated.append(2)

    var decision = certify_quad_face[FpField[p]](
        points, tails, heads, quad, allowed_zero[p]()
    )
    assert_true(decision.ok and decision.attaches)
    assert_true(len(decision.boundary) == 4)
    for e in range(4):
        assert_true(decision.boundary[e] == Fp[p](1))

    var candidates = List[List[Int]]()
    candidates.append(quad^)
    candidates.append(rotated^)
    var built = build_quad_complex[FpField[p]](
        points, tails, heads, candidates, allowed_zero[p]()
    )
    assert_true(built.ok)
    # The second candidate is the same unrooted cycle, not a second face.
    assert_true(len(built.accepted_candidates) == 1)
    var summary = inspect_complex[FpField[p]](
        built.boundary1, built.boundary2
    )
    assert_true(summary.ok)
    assert_true(summary.beta0 == 1 and summary.beta1 == 0)
    assert_true(summary.beta2 == 0)

    var flow = List[Fp[p]]()
    flow.append(Fp[p](1))
    for _ in range(3):
        flow.append(Fp[p](0))
    var f = List[Fp[p]]()
    f.append(Fp[p](1))
    var stokes = verify_cellular_stokes[FpField[p]](
        built.boundary1, built.boundary2, flow, f
    )
    assert_true(stokes.ok)
    assert_true(stokes.face_evaluation == Fp[p](1))
    assert_true(stokes.boundary_circulation == Fp[p](1))
    var no_flow = List[Fp[p]]()
    for _ in range(4):
        no_flow.append(Fp[p](0))
    var closed = verify_cellular_stokes[FpField[p]](
        built.boundary1, built.boundary2, no_flow, f
    )
    assert_true(closed.ok and closed.face_evaluation == Fp[p](0))
    var bad_f = List[Fp[p]]()
    assert_false(verify_cellular_stokes[FpField[p]](
        built.boundary1, built.boundary2, flow, bad_f
    ).ok)

    var duplicate_tails = List[Int]()
    var duplicate_heads = List[Int]()
    for e in range(4):
        duplicate_tails.append(tails[e])
        duplicate_heads.append(heads[e])
    duplicate_tails.append(1)
    duplicate_heads.append(0)
    var invalid = build_quad_complex[FpField[p]](
        points, duplicate_tails, duplicate_heads, candidates,
        allowed_zero[p]()
    )
    assert_false(invalid.ok)


def test_disconnected_chain_is_not_geometric_face() raises:
    var points = List[ChromoVec2[FpField[7]]]()
    points.append(vec[7](0, 0))
    points.append(vec[7](1, 0))
    points.append(vec[7](0, 1))
    points.append(vec[7](1, 1))
    points.append(vec[7](3, 0))
    points.append(vec[7](4, 0))
    points.append(vec[7](3, 1))
    points.append(vec[7](4, 1))
    var tails = List[Int]()
    var heads = List[Int]()
    var sources = List[Int]()
    sources.append(0)
    sources.append(1)
    sources.append(3)
    sources.append(2)
    sources.append(4)
    sources.append(5)
    sources.append(7)
    sources.append(6)
    var destinations = List[Int]()
    destinations.append(1)
    destinations.append(3)
    destinations.append(2)
    destinations.append(0)
    destinations.append(5)
    destinations.append(7)
    destinations.append(6)
    destinations.append(4)
    for e in range(8):
        tails.append(sources[e])
        heads.append(destinations[e])

    var q0 = List[Int]()
    q0.append(0)
    q0.append(1)
    q0.append(2)
    q0.append(3)
    var q1 = List[Int]()
    q1.append(4)
    q1.append(5)
    q1.append(6)
    q1.append(7)
    var impossible = List[Int]()
    impossible.append(0)
    impossible.append(1)
    impossible.append(6)
    impossible.append(7)
    var candidates = List[List[Int]]()
    candidates.append(q0^)
    candidates.append(q1^)
    candidates.append(impossible^)
    var built = build_quad_complex[FpField[7]](
        points, tails, heads, candidates, allowed_zero[7]()
    )
    assert_true(built.ok)
    assert_true(len(built.accepted_candidates) == 2)
    var topology = inspect_complex[FpField[7]](
        built.boundary1, built.boundary2
    )
    assert_true(topology.ok and topology.beta0 == 2)
    assert_true(topology.beta1 == 0)

    # Algebraically z0+z1 is a cycle, but it cannot be the attaching
    # loop of a single geometric 2-cell across disconnected components.
    var artificial = List[List[Fp[7]]]()
    for _ in range(8):
        var row = List[Fp[7]]()
        row.append(Fp[7](1))
        artificial.append(row^)
    var algebra_only = inspect_complex[FpField[7]](
        built.boundary1, artificial
    )
    assert_true(algebra_only.ok)
    assert_true(algebra_only.beta0 == 2 and algebra_only.beta1 == 1)

def main() raises:
    test_cells[7]()
    test_cells[13]()
    test_homology_and_circulation[7]()
    test_homology_and_circulation[13]()
    test_isotropic_guard()
    test_cycle_relabeling[7]()
    test_cycle_relabeling[13]()
    test_geometry_to_chain[7]()
    test_geometry_to_chain[13]()
    test_disconnected_chain_is_not_geometric_face()
    print("SGC-1 compiled exact projective-cell and homology contracts passed.")
