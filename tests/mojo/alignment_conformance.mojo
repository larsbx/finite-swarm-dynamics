"""Exhaustive F_7^3 scalar velocity differential corpus through canonical Mojo.

Rows: ALIGN7v1 a b c v0+ v1+ v2+.
The fixed, directed, row-unital operator is [[0,1,0],[0,0,1],[0,0,1]].
This executable itself performs the full 343-case enumeration.
"""
from finite_exact.fp import Fp, FpField
from chromogeometry.chromatic import ChromoVec2
from swarm_models.linear_alignment import alignment_step


def chain7() -> List[List[Fp[7]]]:
    var matrix = List[List[Fp[7]]]()
    var a = List[Fp[7]]()
    a.append(Fp[7](0))
    a.append(Fp[7](1))
    a.append(Fp[7](0))
    matrix.append(a^)
    var b = List[Fp[7]]()
    b.append(Fp[7](0))
    b.append(Fp[7](0))
    b.append(Fp[7](1))
    matrix.append(b^)
    var c = List[Fp[7]]()
    c.append(Fp[7](0))
    c.append(Fp[7](0))
    c.append(Fp[7](1))
    matrix.append(c^)
    return matrix^


def main() raises:
    var weights = chain7()
    for a in range(7):
        for b in range(7):
            for c in range(7):
                var velocities = List[ChromoVec2[FpField[7]]]()
                velocities.append(
                    ChromoVec2[FpField[7]](Fp[7](Int64(a)), Fp[7](0))
                )
                velocities.append(
                    ChromoVec2[FpField[7]](Fp[7](Int64(b)), Fp[7](0))
                )
                velocities.append(
                    ChromoVec2[FpField[7]](Fp[7](Int64(c)), Fp[7](0))
                )
                var next = alignment_step[FpField[7]](weights, velocities)
                if not next.ok:
                    raise Error("valid F_7 row-unital transition unexpectedly rejected")
                print(
                    "ALIGN7v1", a, b, c,
                    next.velocities[0].x.v,
                    next.velocities[1].x.v,
                    next.velocities[2].x.v
                )
