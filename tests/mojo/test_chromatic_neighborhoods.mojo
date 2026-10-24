"""Chromatic neighborhoods with directed update and exact null/collision guard."""
from std.testing import assert_true, assert_false
from finite_exact.fp import Fp, FpField
from chromogeometry.chromatic import ChromoVec2
from swarm_models.chromatic_neighborhoods import chromatic_neighbor_mask
from swarm_models.finite_phase import modal_vicsek_step


def v[p: Int64](x: Int64,y: Int64) -> ChromoVec2[FpField[p]]:
    return ChromoVec2[FpField[p]](Fp[p](x),Fp[p](y))


def test_star[p: Int64]() raises:
    var pos = List[ChromoVec2[FpField[p]]]()
    pos.append(v[p](0,0))
    pos.append(v[p](1,0))
    pos.append(v[p](0,1))
    var green = List[Fp[p]]()
    green.append(Fp[p](0))
    var empty = List[Fp[p]]()
    var mask = chromatic_neighbor_mask[FpField[p]](
        pos,False,empty,False,empty,True,green
    )
    assert_true(mask.ok)
    assert_true(mask.adjacency[0][1])
    assert_true(mask.adjacency[0][2])
    assert_false(mask.adjacency[1][2])
    assert_false(mask.adjacency[0][0])
    assert_true(mask.adjacency[1][0])
    var headings = List[ChromoVec2[FpField[p]]]()
    headings.append(v[p](1,0))
    headings.append(v[p](1,0))
    headings.append(v[p](0,1))
    var noise = List[ChromoVec2[FpField[p]]]()
    for _ in range(3):
        noise.append(v[p](1,0))
    var result = modal_vicsek_step[FpField[p]](
        pos,headings,mask.adjacency,noise,Fp[p](0)
    )
    assert_true(result.ok)
    assert_true(result.headings[0].x == Fp[p](1))
    assert_true(result.headings[1].x == Fp[p](1))
    assert_true(result.headings[2].y == Fp[p](1)) # tie retains oriented heading

    var blue = List[Fp[p]]()
    blue.append(Fp[p](1))
    var intersection = chromatic_neighbor_mask[FpField[p]](
        pos,True,blue,False,empty,True,green
    )
    assert_true(intersection.ok)
    assert_true(intersection.adjacency[0][1])
    assert_false(intersection.adjacency[1][2])

    var no_edges = chromatic_neighbor_mask[FpField[p]](
        pos,True,empty,False,empty,False,empty
    )
    assert_true(no_edges.ok)
    assert_false(no_edges.adjacency[0][1])

    var all_edges = chromatic_neighbor_mask[FpField[p]](
        pos,False,empty,False,empty,False,empty
    )
    assert_true(all_edges.ok)
    assert_true(all_edges.adjacency[1][2])


def test_distinct_null_not_collision() raises:
    var pos = List[ChromoVec2[FpField[7]]]()
    pos.append(v[7](0,0))
    pos.append(v[7](1,0))
    var zeros = List[Fp[7]]()
    zeros.append(Fp[7](0))
    var empty = List[Fp[7]]()
    var mask = chromatic_neighbor_mask[FpField[7]](
        pos,False,empty,False,empty,True,zeros
    )
    assert_true(mask.ok)
    assert_true(mask.adjacency[0][1]) # nonzero null displacement: green Q=0
    var bad = List[Fp[7]]()
    bad.append(Fp[7].rejected_value())
    assert_false(chromatic_neighbor_mask[FpField[7]](
        pos,False,empty,False,empty,True,bad
    ).ok)


def main() raises:
    test_star[7]()
    test_star[13]()
    test_distinct_null_not_collision()
    print("Chromatic Mojo neighborhood predicates passed over F_7 and F_13.")
