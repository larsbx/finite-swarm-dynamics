"""Exhaustive F7 coupling-parameter sweep using the compiled phase kernel.

Emits STRAT7v1 k x0 y0 x1 y1 next_x0 next_y0 next_x1 next_y1.
All 7*8*8 possible cases are computed by actual compiled Mojo.
"""
from finite_exact.fp import Fp, FpField
from chromogeometry.chromatic import ChromoVec2, chromo_blue
from swarm_models.finite_phase import finite_kuramoto_step


def unit_headings() -> List[ChromoVec2[FpField[7]]]:
    var out = List[ChromoVec2[FpField[7]]]()
    for x in range(7):
        for y in range(7):
            var u = ChromoVec2[FpField[7]](Fp[7](Int64(x)), Fp[7](Int64(y)))
            if chromo_blue(u) == Fp[7](1):
                out.append(u.copy())
    return out^


def symmetric_weights() -> List[List[Fp[7]]]:
    var rows = List[List[Fp[7]]]()
    var a = List[Fp[7]]()
    a.append(Fp[7](0))
    a.append(Fp[7](1))
    rows.append(a^)
    var b = List[Fp[7]]()
    b.append(Fp[7](1))
    b.append(Fp[7](0))
    rows.append(b^)
    return rows^


def main() raises:
    var units = unit_headings()
    if len(units) != 8:
        raise Error("unexpected F7 unit-blue conic cardinality")
    var drift = List[ChromoVec2[FpField[7]]]()
    drift.append(ChromoVec2[FpField[7]](Fp[7](1), Fp[7](0)))
    drift.append(ChromoVec2[FpField[7]](Fp[7](1), Fp[7](0)))
    var lag = ChromoVec2[FpField[7]](Fp[7](1), Fp[7](0))
    var weights = symmetric_weights()
    for k in range(7):
        for i in range(8):
            for j in range(8):
                var old = List[ChromoVec2[FpField[7]]]()
                old.append(units[i].copy())
                old.append(units[j].copy())
                var next = finite_kuramoto_step[FpField[7]](
                    old, weights, Fp[7](Int64(k)), drift, lag
                )
                if not next.ok:
                    raise Error("valid coupling-stratum input rejected")
                print(
                    "STRAT7v1", k,
                    old[0].x.v, old[0].y.v, old[1].x.v, old[1].y.v,
                    next.headings[0].x.v, next.headings[0].y.v,
                    next.headings[1].x.v, next.headings[1].y.v
                )
