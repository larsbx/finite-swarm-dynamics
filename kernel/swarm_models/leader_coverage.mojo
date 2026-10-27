"""Exact inclusion-image verifier for finite-field swarm leader coverage.

A policy class represented by a 1-cycle z is uncovered precisely when
z = I_1*y + d2*b for a 1-cycle y carried by the induced unpinned subcomplex.
Because d1*z=0, d1*d2=0, and I_1 is inclusion, the equation itself
implies d1*(I_1*y)=0. Thus one guarded field-linear system suffices.

This module intentionally neither changes homology by pinning nor asserts
finite-field spectral decay. ExactField arithmetic comes from the pinned
finite-math-kernels; it is not reimplemented here.
"""
from finite_exact.field import ExactField


struct CoverageCheck[K: ExactField](Movable):
    var ok: Bool
    var covered: Bool
    var witness: List[Self.K.Element]

    def __init__(out self):
        self.ok = False
        self.covered = False
        self.witness = List[Self.K.Element]()


def verify_leader_coverage[K: ExactField](
    boundary1: List[List[K.Element]],
    boundary2: List[List[K.Element]],
    cycle: List[K.Element],
    leaders: List[Bool],
) -> CoverageCheck[K]:
    """Verify [cycle] NOT in image H1(U(S)) -> H1(K), over a field.

    boundary1: vertices x edges, exactly one +1 and one -1 per edge.
    boundary2: edges x faces, with boundary1*boundary2 = 0.
    U(S): induced subcomplex on vertices outside the closed graph
          neighborhood of the leader set S.
    On success, covered=True iff no cycle representative is supported
    in U(S). If uncovered, witness is an exact 1-cycle on U(S)
    homologous to cycle in K; otherwise witness is empty.
    Invalid matrix/chain inputs fail closed with ok=False.
    """
    var out = CoverageCheck[K]()
    var nv = len(boundary1)
    var ne = len(cycle)
    if nv == 0 or ne == 0 or len(leaders) != nv or len(boundary2) != ne:
        return out^
    if K.is_zero(K.from_int(2)):
        return out^

    var nf = len(boundary2[0])
    for e in range(ne):
        if len(boundary2[e]) != nf or not K.accepted(cycle[e]):
            return out^
        for f in range(nf):
            if not K.accepted(boundary2[e][f]):
                return out^

    var starts = List[Int]()
    var ends = List[Int]()
    for e in range(ne):
        var start = -1
        var end = -1
        for v in range(nv):
            if len(boundary1[v]) != ne:
                return out^
            var a = boundary1[v][e]
            if not K.accepted(a):
                return out^
            if K.eq(a, K.neg(K.one())):
                if start != -1:
                    return out^
                start = v
            elif K.eq(a, K.one()):
                if end != -1:
                    return out^
                end = v
            elif not K.is_zero(a):
                return out^
        if start == -1 or end == -1 or start == end:
            return out^
        starts.append(start)
        ends.append(end)

    # Chain contract and input cycle guard.
    for v in range(nv):
        var dz = K.zero()
        for e in range(ne):
            dz = K.add(dz, K.mul(boundary1[v][e], cycle[e]))
        if not K.is_zero(dz):
            return out^
        for f in range(nf):
            var composition = K.zero()
            for e in range(ne):
                composition = K.add(
                    composition, K.mul(boundary1[v][e], boundary2[e][f])
                )
            if not K.is_zero(composition):
                return out^

    var removed = List[Bool]()
    for v in range(nv):
        removed.append(leaders[v])
    for e in range(ne):
        if leaders[starts[e]]:
            removed[ends[e]] = True
        if leaders[ends[e]]:
            removed[starts[e]] = True

    var kept = List[Int]()
    for e in range(ne):
        if not removed[starts[e]] and not removed[ends[e]]:
            kept.append(e)
    var kept_count = len(kept)
    var nunknown = kept_count + nf

    # Matrix [I_(kept) | d2 | z], with all entries in the field.
    var matrix = List[List[K.Element]]()
    for e in range(ne):
        var row = List[K.Element]()
        for _ in range(nunknown + 1):
            row.append(K.zero())
        for j in range(kept_count):
            if kept[j] == e:
                row[j] = K.one()
        for f in range(nf):
            row[kept_count + f] = K.add(boundary2[e][f], K.zero())
        row[nunknown] = K.add(cycle[e], K.zero())
        matrix.append(row^)

    # Reduced row echelon elimination (zero free variables).
    var pivots = List[Int]()
    var pivot_row = 0
    for col in range(nunknown):
        if pivot_row == ne:
            break
        var found = pivot_row
        while found < ne and K.is_zero(matrix[found][col]):
            found += 1
        if found == ne:
            continue
        if found != pivot_row:
            for j in range(nunknown + 1):
                var tmp = K.add(matrix[found][j], K.zero())
                matrix[found][j] = K.add(matrix[pivot_row][j], K.zero())
                matrix[pivot_row][j] = tmp
        var inv = K.div(K.one(), matrix[pivot_row][col])
        for j in range(col, nunknown + 1):
            matrix[pivot_row][j] = K.mul(matrix[pivot_row][j], inv)
        for i in range(ne):
            if i != pivot_row:
                var factor = K.add(matrix[i][col], K.zero())
                if not K.is_zero(factor):
                    for j in range(col, nunknown + 1):
                        matrix[i][j] = K.sub(
                            matrix[i][j], K.mul(factor, matrix[pivot_row][j])
                        )
        pivots.append(col)
        pivot_row += 1

    for i in range(pivot_row, ne):
        if not K.is_zero(matrix[i][nunknown]):
            out.ok = True
            out.covered = True
            return out^

    # Consistent: reconstruct a supported representative of the class.
    for _ in range(ne):
        out.witness.append(K.zero())
    for i in range(len(pivots)):
        if pivots[i] < kept_count:
            out.witness[kept[pivots[i]]] = K.add(matrix[i][nunknown], K.zero())
    out.ok = True
    out.covered = False
    return out^
