"""Exact oriented finite phase and modal heading dynamics in pinned Mojo.

Domain-specific dynamics only. Every field operation and ChromoVec2 is imported
from the authoritative finite-math-kernels implementation.
The models are *not* real-time Vicsek or Kuramoto discretization theorems.
"""
from finite_exact.field import ExactField
from chromogeometry.chromatic import ChromoVec2, chromo_blue, chromo_det


def _same[K: ExactField](a: ChromoVec2[K], b: ChromoVec2[K]) -> Bool:
    return K.eq(a.x, b.x) and K.eq(a.y, b.y)


def _unit[K: ExactField](a: ChromoVec2[K]) -> Bool:
    return a.accepted() and K.eq(chromo_blue(a), K.one())


def _compose[K: ExactField](a: ChromoVec2[K], b: ChromoVec2[K]) -> ChromoVec2[K]:
    """Algebraic unit-conic rotor product (no complex numbers)."""
    var x = K.sub(K.mul(a.x, b.x), K.mul(a.y, b.y))
    var y = K.add(K.mul(a.x, b.y), K.mul(a.y, b.x))
    return ChromoVec2[K](x, y)


def _cayley_rotate[K: ExactField](t: K.Element, u: ChromoVec2[K]) -> ChromoVec2[K]:
    var t2 = K.mul(t, t)
    var den = K.add(K.one(), t2)
    if K.is_zero(den):
        # Explicit model totalization at Cayley poles: half turn (-I).
        return ChromoVec2[K](K.neg(u.x), K.neg(u.y))
    var c = K.div(K.sub(K.one(), t2), den)
    var s = K.div(K.mul(K.from_int(2), t), den)
    var rotor = ChromoVec2[K](c, s)
    return _compose(rotor, u)


struct PhaseStep[K: ExactField](Movable):
    var ok: Bool
    var headings: List[ChromoVec2[Self.K]]

    def __init__(out self):
        self.ok = True
        self.headings = List[ChromoVec2[Self.K]]()


def finite_kuramoto_step[K: ExactField](
    headings: List[ChromoVec2[K]],
    weights: List[List[K.Element]],
    coupling: K.Element,
    natural_rotors: List[ChromoVec2[K]],
    lag: ChromoVec2[K],
) -> PhaseStep[K]:
    """u_i+ = natural_i * Cayley(kappa Σ w_ij det(u_i,lag*u_j)) * u_i.

    All data read from the old state. Weight diagonal must be zero.
    """
    var out = PhaseStep[K]()
    var n = len(headings)
    if n == 0 or len(weights) != n or len(natural_rotors) != n:
        out.ok = False
        return out^
    if K.is_zero(K.from_int(2)) or not K.accepted(coupling) or not _unit(lag):
        out.ok = False
        return out^
    for i in range(n):
        if len(weights[i]) != n or not _unit(headings[i]) or not _unit(natural_rotors[i]):
            out.ok = False
            return out^
        for j in range(n):
            if not K.accepted(weights[i][j]):
                out.ok = False
                return out^
        if not K.is_zero(weights[i][i]):
            out.ok = False
            return out^

    for i in range(n):
        var t = K.zero()
        for j in range(n):
            if j != i:
                var neighbor = _compose(lag, headings[j])
                t = K.add(t, K.mul(weights[i][j], chromo_det(headings[i], neighbor)))
        var rotated = _cayley_rotate(K.mul(coupling, t), headings[i])
        var result = _compose(natural_rotors[i], rotated)
        if not _unit(result):
            out.ok = False
            out.headings.clear()
            return out^
        out.headings.append(result.copy())
    return out^


struct ModalStep[K: ExactField](Movable):
    var ok: Bool
    var positions: List[ChromoVec2[Self.K]]
    var headings: List[ChromoVec2[Self.K]]

    def __init__(out self):
        self.ok = True
        self.positions = List[ChromoVec2[Self.K]]()
        self.headings = List[ChromoVec2[Self.K]]()


def modal_vicsek_step[K: ExactField](
    positions: List[ChromoVec2[K]],
    headings: List[ChromoVec2[K]],
    adjacency: List[List[Bool]],
    noise_rotors: List[ChromoVec2[K]],
    speed: K.Element,
) -> ModalStep[K]:
    """Exact modal heading vote with self; ties retain the old heading.

    Directed adjacency[i][j] means agent i observes j. Diagonal must be false.
    Chromatic neighbor predicates belong to caller-selected graph construction.
    Noise is a caller-supplied finite rotor, not an implicit random variable.
    """
    var out = ModalStep[K]()
    var n = len(headings)
    if n == 0 or len(positions) != n or len(adjacency) != n or len(noise_rotors) != n:
        out.ok = False
        return out^
    if K.is_zero(K.from_int(2)) or not K.accepted(speed):
        out.ok = False
        return out^
    for i in range(n):
        if len(adjacency[i]) != n or adjacency[i][i]:
            out.ok = False
            return out^
        if not positions[i].accepted() or not _unit(headings[i]) or not _unit(noise_rotors[i]):
            out.ok = False
            return out^

    for i in range(n):
        var selected = headings[i].copy()
        var best = 0
        var tie = False
        for j in range(n):
            if i == j or adjacency[i][j]:
                var votes = 0
                for k in range(n):
                    if (i == k or adjacency[i][k]) and _same(headings[j], headings[k]):
                        votes += 1
                if votes > best:
                    best = votes
                    selected = headings[j].copy()
                    tie = False
                elif votes == best and not _same(selected, headings[j]):
                    tie = True
        if tie:
            selected = headings[i].copy()
        var rotated = _compose(noise_rotors[i], selected)
        var x = K.add(positions[i].x, K.mul(speed, rotated.x))
        var y = K.add(positions[i].y, K.mul(speed, rotated.y))
        if not _unit(rotated) or not K.accepted(x) or not K.accepted(y):
            out.ok = False
            out.positions.clear()
            out.headings.clear()
            return out^
        out.positions.append(ChromoVec2[K](x, y))
        out.headings.append(rotated.copy())
    return out^
