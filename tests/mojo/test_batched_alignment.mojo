"""Compiled batch/serial parity for exact field-generic alignment.

No performance claims: this is an arithmetic acceptance test, not a benchmark.
"""
from std.testing import assert_true, assert_false, assert_equal
from finite_exact.fp import Fp, FpField
from chromogeometry.chromatic import ChromoVec2
from swarm_models.linear_alignment import flock_step
from swarm_models.batched_alignment import batched_flock_step


def v[p: Int64](x: Int64, y: Int64) -> ChromoVec2[FpField[p]]:
    return ChromoVec2[FpField[p]](Fp[p](x), Fp[p](y))


def chain[p: Int64]() -> List[List[Fp[p]]]:
    var out = List[List[Fp[p]]]()
    for i in range(3):
        var row = List[Fp[p]]()
        for j in range(3):
            row.append(Fp[p](Int64(1 if j == min(i+1, 2) else 0)))
        out.append(row^)
    return out^


def test_batch[p: Int64]() raises:
    var pos = List[List[ChromoVec2[FpField[p]]]]()
    var vel = List[List[ChromoVec2[FpField[p]]]]()
    for b in range(5):
        var ps = List[ChromoVec2[FpField[p]]]()
        var vs = List[ChromoVec2[FpField[p]]]()
        for i in range(3):
            ps.append(v[p](Int64(b+i), Int64(b*2+i)))
            vs.append(v[p](Int64(2*b+i), Int64(b+2*i)))
        pos.append(ps^)
        vel.append(vs^)
    var pmat = chain[p]()
    var speed = Fp[p](3)
    var batch = batched_flock_step[FpField[p]](pmat, pos, vel, speed)
    assert_true(batch.ok)
    assert_equal(len(batch.batches), 5)

    for b in range(5):
        var serial = flock_step[FpField[p]](pmat, pos[b], vel[b], speed)
        assert_true(serial.ok)
        assert_equal(len(batch.batches[b].positions), 3)
        assert_equal(len(batch.batches[b].velocities), 3)
        for i in range(3):
            assert_true(batch.batches[b].positions[i].x == serial.positions[i].x)
            assert_true(batch.batches[b].positions[i].y == serial.positions[i].y)
            assert_true(batch.batches[b].velocities[i].x == serial.velocities[i].x)
            assert_true(batch.batches[b].velocities[i].y == serial.velocities[i].y)

    # The directed chain reaches velocity consensus in exactly two steps.
    var after_pos = List[List[ChromoVec2[FpField[p]]]]()
    var after_vel = List[List[ChromoVec2[FpField[p]]]]()
    for b in range(5):
        var ap = List[ChromoVec2[FpField[p]]]()
        var av = List[ChromoVec2[FpField[p]]]()
        for i in range(3):
            ap.append(batch.batches[b].positions[i].copy())
            av.append(batch.batches[b].velocities[i].copy())
        after_pos.append(ap^)
        after_vel.append(av^)
    var twice = batched_flock_step[FpField[p]](pmat, after_pos, after_vel, speed)
    assert_true(twice.ok)
    for b in range(5):
        for i in range(3):
            assert_true(twice.batches[b].velocities[i].x == twice.batches[b].velocities[2].x)
            assert_true(twice.batches[b].velocities[i].y == twice.batches[b].velocities[2].y)

    # Preflight rejects one malformed batch *without* emitting other results.
    var bad_pos = List[List[ChromoVec2[FpField[p]]]]()
    var bad_vel = List[List[ChromoVec2[FpField[p]]]]()
    for b in range(5):
        var ps = List[ChromoVec2[FpField[p]]]()
        var vs = List[ChromoVec2[FpField[p]]]()
        var count = 2 if b == 4 else 3
        for i in range(count):
            ps.append(pos[b][i].copy())
            vs.append(vel[b][i].copy())
        bad_pos.append(ps^)
        bad_vel.append(vs^)
    var invalid = batched_flock_step[FpField[p]](pmat, bad_pos, bad_vel, speed)
    assert_false(invalid.ok)
    assert_equal(len(invalid.batches), 0)


def main() raises:
    test_batch[7]()
    test_batch[13]()
    print("PASS: exact batched Mojo and serial parity on 10 finite flock states.")
