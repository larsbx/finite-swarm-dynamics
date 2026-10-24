"""Finite-field linear velocity alignment: domain-specific Mojo consumer.

Canonical field and planar vector types are imported from the pinned
finite-math-kernels implementation. This module owns only the swarm update.
A rejected state or non-unital matrix fails closed, never projects to zero.
"""
from finite_exact.field import ExactField
from chromogeometry.chromatic import ChromoVec2


struct AlignmentStep[K: ExactField](Movable):
    var ok: Bool
    var velocities: List[ChromoVec2[Self.K]]

    def __init__(out self):
        self.ok = True
        self.velocities = List[ChromoVec2[Self.K]]()


def alignment_step[K: ExactField](
    rows: List[List[K.Element]],
    velocities: List[ChromoVec2[K]],
) -> AlignmentStep[K]:
    """P*V for a finite, algebraically row-unital matrix P.

    P 1 = 1, but no coefficient positivity or probability is implied.
    Input dimension, field acceptance and row unitality are checked.
    Invalid inputs return ok=False and no partial output.
    """
    var out = AlignmentStep[K]()
    var n = len(velocities)
    if n == 0 or len(rows) != n:
        out.ok = False
        return out^
    for i in range(n):
        if len(rows[i]) != n or not velocities[i].accepted():
            out.ok = False
            return out^
        var total = K.zero()
        for j in range(n):
            if not K.accepted(rows[i][j]):
                out.ok = False
                return out^
            total = K.add(total, rows[i][j])
        if not K.eq(total, K.one()):
            out.ok = False
            return out^

    for i in range(n):
        var x = K.zero()
        var y = K.zero()
        for j in range(n):
            x = K.add(x, K.mul(rows[i][j], velocities[j].x))
            y = K.add(y, K.mul(rows[i][j], velocities[j].y))
        if not K.accepted(x) or not K.accepted(y):
            out.ok = False
            out.velocities.clear()
            return out^
        out.velocities.append(ChromoVec2[K](x, y))
    return out^


struct FlockStep[K: ExactField](Movable):
    var ok: Bool
    var positions: List[ChromoVec2[Self.K]]
    var velocities: List[ChromoVec2[Self.K]]

    def __init__(out self):
        self.ok = True
        self.positions = List[ChromoVec2[Self.K]]()
        self.velocities = List[ChromoVec2[Self.K]]()


def flock_step[K: ExactField](
    rows: List[List[K.Element]],
    positions: List[ChromoVec2[K]],
    velocities: List[ChromoVec2[K]],
    speed: K.Element,
) -> FlockStep[K]:
    """Synchronous v+=P v; x+=x+speed*v+ using *new* velocities."""
    var out = FlockStep[K]()
    if not K.accepted(speed) or len(positions) != len(velocities):
        out.ok = False
        return out^
    for p in positions:
        if not p.accepted():
            out.ok = False
            return out^
    var motion = alignment_step[K](rows, velocities)
    if not motion.ok:
        out.ok = False
        return out^
    for i in range(len(positions)):
        var u = motion.velocities[i].copy()
        var new_x = K.add(positions[i].x, K.mul(speed, u.x))
        var new_y = K.add(positions[i].y, K.mul(speed, u.y))
        if not K.accepted(new_x) or not K.accepted(new_y):
            out.ok = False
            out.positions.clear()
            out.velocities.clear()
            return out^
        out.positions.append(ChromoVec2[K](new_x, new_y))
        out.velocities.append(ChromoVec2[K](u.x, u.y))
    return out^
