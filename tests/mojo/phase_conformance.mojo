"""Exhaustive finite rotor and modal heading output over all F_7 unit headings.

PHASE7v1: all 8^2 two-oscillator oriented phase inputs, symmetric unit
coupling, κ=1, natural rotors and lag identity.
MODAL7v1: all 8^3 three-agent heading inputs, all-to-all observation,
identity supplied noise and speed=0. Output is headings only.
"""
from finite_exact.fp import Fp, FpField
from chromogeometry.chromatic import ChromoVec2, chromo_blue
from swarm_models.finite_phase import finite_kuramoto_step, modal_vicsek_step


def unit_headings() -> List[ChromoVec2[FpField[7]]]:
    var result = List[ChromoVec2[FpField[7]]]()
    for x in range(7):
        for y in range(7):
            var a = ChromoVec2[FpField[7]](Fp[7](Int64(x)), Fp[7](Int64(y)))
            if chromo_blue(a) == Fp[7](1):
                result.append(a.copy())
    return result^


def weights() -> List[List[Fp[7]]]:
    var matrix = List[List[Fp[7]]]()
    var a = List[Fp[7]]()
    a.append(Fp[7](0))
    a.append(Fp[7](1))
    matrix.append(a^)
    var b = List[Fp[7]]()
    b.append(Fp[7](1))
    b.append(Fp[7](0))
    matrix.append(b^)
    return matrix^


def all_to_all_3() -> List[List[Bool]]:
    var matrix = List[List[Bool]]()
    for i in range(3):
        var row = List[Bool]()
        for j in range(3):
            row.append(i != j)
        matrix.append(row^)
    return matrix^


def main() raises:
    var units = unit_headings()
    if len(units) != 8:
        raise Error("F_7 unit-blue conic must have exactly eight elements")
    var drift = List[ChromoVec2[FpField[7]]]()
    for _ in range(2):
        drift.append(ChromoVec2[FpField[7]](Fp[7](1), Fp[7](0)))
    var phase_weights = weights()
    var lag = ChromoVec2[FpField[7]](Fp[7](1), Fp[7](0))
    for i in range(len(units)):
        for j in range(len(units)):
            var old = List[ChromoVec2[FpField[7]]]()
            old.append(units[i].copy())
            old.append(units[j].copy())
            var next = finite_kuramoto_step[FpField[7]](
                old, phase_weights, Fp[7](1), drift, lag
            )
            if not next.ok:
                raise Error("valid F_7 phase input rejected")
            print(
                "PHASE7v1", old[0].x.v, old[0].y.v,
                old[1].x.v, old[1].y.v,
                next.headings[0].x.v, next.headings[0].y.v,
                next.headings[1].x.v, next.headings[1].y.v
            )
    var mask = all_to_all_3()
    var noise = List[ChromoVec2[FpField[7]]]()
    var positions = List[ChromoVec2[FpField[7]]]()
    for _ in range(3):
        noise.append(ChromoVec2[FpField[7]](Fp[7](1), Fp[7](0)))
        positions.append(ChromoVec2[FpField[7]](Fp[7](0), Fp[7](0)))
    for i in range(len(units)):
        for j in range(len(units)):
            for k in range(len(units)):
                var headings = List[ChromoVec2[FpField[7]]]()
                headings.append(units[i].copy())
                headings.append(units[j].copy())
                headings.append(units[k].copy())
                var next = modal_vicsek_step[FpField[7]](
                    positions, headings, mask, noise, Fp[7](0)
                )
                if not next.ok:
                    raise Error("valid F_7 modal input rejected")
                print(
                    "MODAL7v1",
                    headings[0].x.v, headings[0].y.v,
                    headings[1].x.v, headings[1].y.v,
                    headings[2].x.v, headings[2].y.v,
                    next.headings[0].x.v, next.headings[0].y.v,
                    next.headings[1].x.v, next.headings[1].y.v,
                    next.headings[2].x.v, next.headings[2].y.v
                )
