"""Geometry-dependent finite neighborhoods for compiled swarm models.

Each color supplies either no restriction or a finite accepted quadrance set.
No field ordering, square roots, physical radius, or collision conflation.
"""
from finite_exact.field import ExactField
from chromogeometry.chromatic import (
    ChromoVec2, chromo_blue, chromo_red, chromo_green,
)


struct ChromaticMask[K: ExactField](Movable):
    var ok: Bool
    var adjacency: List[List[Bool]]

    def __init__(out self):
        self.ok = True
        self.adjacency = List[List[Bool]]()


def _contains[K: ExactField](value: K.Element, allowed: List[K.Element]) -> Bool:
    for item in allowed:
        if K.eq(value, item):
            return True
    return False


def chromatic_neighbor_mask[K: ExactField](
    positions: List[ChromoVec2[K]],
    use_blue: Bool,
    blue_allowed: List[K.Element],
    use_red: Bool,
    red_allowed: List[K.Element],
    use_green: Bool,
    green_allowed: List[K.Element],
) -> ChromaticMask[K]:
    """Undirected pair adjacency; all enabled quadratic membership tests required.

    Guards over field elements are sets operationally, but accepted as Lists
    to preserve simple Mojo consumer interoperability. Duplicates are benign.
    """
    var out = ChromaticMask[K]()
    var n = len(positions)
    if n == 0 or K.is_zero(K.from_int(2)):
        out.ok = False
        return out^
    for p in positions:
        if not p.accepted():
            out.ok = False
            return out^
    for v in blue_allowed:
        if not K.accepted(v):
            out.ok = False
            return out^
    for v in red_allowed:
        if not K.accepted(v):
            out.ok = False
            return out^
    for v in green_allowed:
        if not K.accepted(v):
            out.ok = False
            return out^

    for i in range(n):
        var row = List[Bool]()
        for j in range(n):
            var connected = i != j
            if connected:
                var d = ChromoVec2[K](
                    K.sub(positions[j].x, positions[i].x),
                    K.sub(positions[j].y, positions[i].y),
                )
                if use_blue:
                    connected = connected and _contains(chromo_blue(d), blue_allowed)
                if use_red:
                    connected = connected and _contains(chromo_red(d), red_allowed)
                if use_green:
                    connected = connected and _contains(chromo_green(d), green_allowed)
            row.append(connected)
        out.adjacency.append(row^)
    return out^
