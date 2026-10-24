"""Exact batched planar linear alignment over a canonical ExactField.

Single validated operator P is applied to many independent swarm states.
This is a deterministic CPU baseline for future MAX/GPU execution, not a
claimed accelerator. It never changes the finite-field algebra.
"""
from finite_exact.field import ExactField
from chromogeometry.chromatic import ChromoVec2
from swarm_models.linear_alignment import FlockStep


struct BatchedFlockStep[K: ExactField](Movable):
    var ok: Bool
    var batches: List[FlockStep[Self.K]]

    def __init__(out self):
        self.ok = True
        self.batches = List[FlockStep[Self.K]]()


def batched_flock_step[K: ExactField](
    rows: List[List[K.Element]],
    positions: List[List[ChromoVec2[K]]],
    velocities: List[List[ChromoVec2[K]]],
    speed: K.Element,
) -> BatchedFlockStep[K]:
    """Apply one algebraically row-unital P to B trajectories.

    Input: B nonempty, N nonempty, P shape NxN, positions and velocities BxN.
    All inputs are validated *before* any output is committed. Invalid inputs
    return ok=False with an empty batches list; no partial batch succeeds.
    Computation uses exact field operations with no floating point or ordering.
    """
    var out = BatchedFlockStep[K]()
    var b_count = len(positions)
    var n = len(rows)
    if n == 0 or b_count == 0 or len(velocities) != b_count or not K.accepted(speed):
        out.ok = False
        return out^

    for i in range(n):
        if len(rows[i]) != n:
            out.ok = False
            return out^
        var rowsum = K.zero()
        for j in range(n):
            if not K.accepted(rows[i][j]):
                out.ok = False
                return out^
            rowsum = K.add(rowsum, rows[i][j])
        if not K.eq(rowsum, K.one()):
            out.ok = False
            return out^

    for b in range(b_count):
        if len(positions[b]) != n or len(velocities[b]) != n:
            out.ok = False
            return out^
        for i in range(n):
            if not positions[b][i].accepted() or not velocities[b][i].accepted():
                out.ok = False
                return out^

    for b in range(b_count):
        var batch = FlockStep[K]()
        for i in range(n):
            var x = K.zero()
            var y = K.zero()
            for j in range(n):
                x = K.add(x, K.mul(rows[i][j], velocities[b][j].x))
                y = K.add(y, K.mul(rows[i][j], velocities[b][j].y))
            var new_x = K.add(positions[b][i].x, K.mul(speed, x))
            var new_y = K.add(positions[b][i].y, K.mul(speed, y))
            # Preflight made these valid, but fail closed if an implementation
            # of ExactField rejects intermediate arithmetic (e.g. overflow).
            if not K.accepted(new_x) or not K.accepted(new_y) or (
                not K.accepted(x) or not K.accepted(y)
            ):
                out.ok = False
                out.batches.clear()
                return out^
            batch.positions.append(ChromoVec2[K](new_x, new_y))
            batch.velocities.append(ChromoVec2[K](x, y))
        out.batches.append(batch^)
    return out^
