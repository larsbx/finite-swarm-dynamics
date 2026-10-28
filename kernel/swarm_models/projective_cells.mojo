"""SGC-1: exact planar quadrilateral cells and bounded cellular diagnostics.

Domain geometry (vectors, determinant, guarded RT spread, field arithmetic)
belongs to pinned finite-math-kernels. This swarm consumer supplies graph
admission, cellular ranks and cochain evaluation, not a generic field fork.

An admitted cell is an oriented A->B->D->C->A four-cycle. A static cell
certifies neither heading synchronization nor physical circulation.
"""
from finite_exact.field import ExactField
from chromogeometry.chromatic import (
    ChromoVec2, chromo_det, chromo_blue_spread,
)


struct CellDecision[K: ExactField](Movable):
    var ok: Bool
    var attaches: Bool
    var first: Self.K.Element
    var second: Self.K.Element

    def __init__(out self):
        self.ok = False
        self.attaches = False
        self.first = Self.K.rejected()
        self.second = Self.K.rejected()


def _difference[K: ExactField](
    b: ChromoVec2[K], a: ChromoVec2[K]
) -> ChromoVec2[K]:
    return ChromoVec2[K](K.sub(b.x, a.x), K.sub(b.y, a.y))


def _same[K: ExactField](a: ChromoVec2[K], b: ChromoVec2[K]) -> Bool:
    return K.eq(a.x, b.x) and K.eq(a.y, b.y)


def _member[K: ExactField](value: K.Element, permitted: List[K.Element]) -> Bool:
    for candidate in permitted:
        if K.eq(value, candidate):
            return True
    return False


def check_quad_cell[K: ExactField](
    a: ChromoVec2[K],
    b: ChromoVec2[K],
    c: ChromoVec2[K],
    d: ChromoVec2[K],
    boundary_edges: List[Bool],
    permitted_spreads: List[K.Element],
) -> CellDecision[K]:
    """Decide geometric admission of a fixed oriented four-cycle.

    Boundary edges, in order: AB, BD, DC, CA. Distinct vertices,
    noncollinear A/B/C and non-isotropic AB/CD/AC/BD are required.
    A missing graph edge gives a valid negative decision, not a cell.
    The filter is explicit membership, never an ordering of field values.
    """
    var out = CellDecision[K]()
    if K.is_zero(K.from_int(2)) or len(boundary_edges) != 4:
        return out^
    if not a.accepted() or not b.accepted() or not c.accepted() or not d.accepted():
        return out^
    for scalar in permitted_spreads:
        if not K.accepted(scalar):
            return out^
    if (
        _same(a, b) or _same(a, c) or _same(a, d)
        or _same(b, c) or _same(b, d) or _same(c, d)
    ):
        return out^
    var ab = _difference(b, a)
    var ac = _difference(c, a)
    if (
        K.is_zero(chromo_det(ab, ac))
        or K.is_zero(chromo_det(ab, _difference(d, a)))
        or K.is_zero(chromo_det(ac, _difference(d, a)))
        or K.is_zero(chromo_det(_difference(c, b), _difference(d, b)))
    ):
        # All four triples must be noncollinear, independent of cycle root.
        return out^
    var cd = _difference(d, c)
    var bd = _difference(d, b)
    var first = chromo_blue_spread(ab, cd)
    var second = chromo_blue_spread(ac, bd)
    if not K.accepted(first) or not K.accepted(second):
        return out^
    var complete = True
    for exists in boundary_edges:
        if not exists:
            complete = False
    var selected = (
        complete and _member(first, permitted_spreads)
        and _member(second, permitted_spreads)
    )
    out.first = first^
    out.second = second^
    out.ok = True
    out.attaches = selected
    return out^


def _valid_oriented_edges[K: ExactField](
    d1: List[List[K.Element]], ne: Int
) -> Bool:
    var nv = len(d1)
    if nv == 0 or ne == 0 or K.is_zero(K.from_int(2)):
        return False
    for v in range(nv):
        if len(d1[v]) != ne:
            return False
    for e in range(ne):
        var nsource = 0
        var ntarget = 0
        for v in range(nv):
            var coeff = K.add(d1[v][e], K.zero())
            if not K.accepted(coeff):
                return False
            if K.eq(coeff, K.neg(K.one())):
                nsource += 1
            elif K.eq(coeff, K.one()):
                ntarget += 1
            elif not K.is_zero(coeff):
                return False
        if nsource != 1 or ntarget != 1:
            return False
    return True


def _rank[K: ExactField](input: List[List[K.Element]], columns: Int) -> Int:
    """Field Gaussian elimination on a validated rectangular matrix."""
    var matrix = List[List[K.Element]]()
    for source in input:
        var target = List[K.Element]()
        for entry in source:
            target.append(K.add(entry, K.zero()))
        matrix.append(target^)
    var pivot = 0
    for col in range(columns):
        if pivot == len(matrix):
            break
        var found = pivot
        while found < len(matrix) and K.is_zero(matrix[found][col]):
            found += 1
        if found == len(matrix):
            continue
        if found != pivot:
            for j in range(columns):
                var saved = K.add(matrix[pivot][j], K.zero())
                matrix[pivot][j] = K.add(matrix[found][j], K.zero())
                matrix[found][j] = saved^
        var inv = K.div(K.one(), matrix[pivot][col])
        for j in range(col, columns):
            matrix[pivot][j] = K.mul(matrix[pivot][j], inv)
        for i in range(pivot + 1, len(matrix)):
            var factor = K.add(matrix[i][col], K.zero())
            if not K.is_zero(factor):
                for j in range(col, columns):
                    matrix[i][j] = K.sub(
                        matrix[i][j], K.mul(factor, matrix[pivot][j])
                    )
        pivot += 1
    return pivot


struct CellularSummary(Movable):
    var ok: Bool
    var rank1: Int
    var rank2: Int
    var beta0: Int
    var beta1: Int
    var beta2: Int

    def __init__(out self):
        self.ok = False
        self.rank1 = 0
        self.rank2 = 0
        self.beta0 = 0
        self.beta1 = 0
        self.beta2 = 0


def inspect_complex[K: ExactField](
    boundary1: List[List[K.Element]],
    boundary2: List[List[K.Element]],
) -> CellularSummary:
    """Inspect a finite oriented graph with guarded cellular face boundaries.

    d1 is vertices x edges, with one +1/-1 per edge;
    d2 is edges x faces. Check d1*d2=0 before computing exact Betti
    numbers over the supplied field. No topological or dynamical claims
    follow from face counts alone.
    """
    var out = CellularSummary()
    var nv = len(boundary1)
    var ne = len(boundary2)
    if not _valid_oriented_edges[K](boundary1, ne):
        return out^
    var nf = len(boundary2[0])
    for e in range(ne):
        if len(boundary2[e]) != nf:
            return out^
        for f in range(nf):
            if not K.accepted(boundary2[e][f]):
                return out^
    for v in range(nv):
        for f in range(nf):
            var boundary_of_boundary = K.zero()
            for e in range(ne):
                boundary_of_boundary = K.add(
                    boundary_of_boundary,
                    K.mul(boundary1[v][e], boundary2[e][f])
                )
            if not K.is_zero(boundary_of_boundary):
                return out^
    out.rank1 = _rank[K](boundary1, ne)
    out.rank2 = _rank[K](boundary2, nf)
    out.beta0 = nv - out.rank1
    out.beta1 = ne - out.rank1 - out.rank2
    out.beta2 = nf - out.rank2
    out.ok = True
    return out^


struct CirculationResult[K: ExactField](Movable):
    var ok: Bool
    var value: Self.K.Element

    def __init__(out self):
        self.ok = False
        self.value = Self.K.rejected()


def cycle_circulation[K: ExactField](
    boundary1: List[List[K.Element]],
    cycle: List[K.Element],
    edge_flow: List[K.Element],
) -> CirculationResult[K]:
    """Evaluate an edge 1-cochain on a verified closed 1-chain.

    A nonzero value has no inherent positive magnitude. Even a boundary
    can carry nonzero flow if the cochain is not closed (d(flow) != 0).
    """
    var out = CirculationResult[K]()
    var ne = len(cycle)
    if len(edge_flow) != ne or not _valid_oriented_edges[K](boundary1, ne):
        return out^
    for e in range(ne):
        if not K.accepted(cycle[e]) or not K.accepted(edge_flow[e]):
            return out^
    for vertex in range(len(boundary1)):
        var boundary = K.zero()
        for e in range(ne):
            boundary = K.add(
                boundary, K.mul(boundary1[vertex][e], cycle[e])
            )
        if not K.is_zero(boundary):
            return out^
    var total = K.zero()
    for e in range(ne):
        total = K.add(total, K.mul(cycle[e], edge_flow[e]))
    out.value = total^
    out.ok = True
    return out^
