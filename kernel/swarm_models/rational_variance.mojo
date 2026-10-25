"""Exact rational N-agent variance certification over canonical QField.

No analytic completion or limit. Input row-unital matrices may be signed.
Positivity and column-unitality are separate mathematical capabilities.
"""
from finite_exact.field import QField
from finite_exact.rat_q import Q
from chromogeometry.chromatic import ChromoVec2, chromo_blue
from swarm_models.linear_alignment import alignment_step


struct RationalVarianceWitness(Movable):
    var ok: Bool
    var column_unital: Bool
    var nonnegative_weights: Bool
    var mean_preserved: Bool
    var moment_gap: Q
    var pairwise_witness: Q
    var variance_before: Q
    var variance_after: Q
    var exact_identity: Bool
    var nonincrease_certified: Bool

    def __init__(out self):
        self.ok = False
        self.column_unital = False
        self.nonnegative_weights = False
        self.mean_preserved = False
        self.moment_gap = Q.zero()
        self.pairwise_witness = Q.zero()
        self.variance_before = Q.zero()
        self.variance_after = Q.zero()
        self.exact_identity = False
        self.nonincrease_certified = False


def _difference_blue(a: ChromoVec2[QField], b: ChromoVec2[QField]) -> Q:
    return chromo_blue(ChromoVec2[QField](
        QField.sub(a.x,b.x), QField.sub(a.y,b.y)
    ))


def _sum_variance(values: List[ChromoVec2[QField]]) -> Q:
    var n = len(values)
    var sumx = Q.zero()
    var sumy = Q.zero()
    for v in values:
        sumx = QField.add(sumx,v.x)
        sumy = QField.add(sumy,v.y)
    var denominator = Q.from_int(Int64(n))
    var mean = ChromoVec2[QField](
        QField.div(sumx,denominator),
        QField.div(sumy,denominator)
    )
    var result = Q.zero()
    for v in values:
        result = QField.add(result,_difference_blue(v,mean))
    return result^


def rational_variance_witness(
    rows: List[List[Q]],
    velocities: List[ChromoVec2[QField]],
) -> RationalVarianceWitness:
    """Exact 2D quadratic Jensen equality, all N rows and pairs.

    If P1=1 and 1ᵀP=1ᵀ:
       variance(V) - variance(PV)
         = Σ_i Σ_(j<k) P_ij P_ik Q_blue(V_j−V_k).
    If every P_ij>=0 the right side proves finite one-step decay.
    """
    var report = RationalVarianceWitness()
    var n = len(velocities)
    if n == 0 or len(rows)!=n:
        return report^
    var nonnegative = True
    for i in range(n):
        if len(rows[i])!=n or not velocities[i].accepted():
            return report^
        var row_sum = Q.zero()
        for j in range(n):
            if not rows[i][j].accepted():
                return report^
            row_sum = QField.add(row_sum,rows[i][j])
            if rows[i][j].lt(Q.zero()):
                nonnegative = False
        if not QField.eq(row_sum,Q.one()):
            return report^

    var column_unital = True
    for j in range(n):
        var col_sum = Q.zero()
        for i in range(n):
            col_sum = QField.add(col_sum,rows[i][j])
        if not QField.eq(col_sum,Q.one()):
            column_unital = False

    var next = alignment_step[QField](rows,velocities)
    if not next.ok:
        return report^
    var weighted_input = Q.zero()
    var old_moment = Q.zero()
    var new_moment = Q.zero()
    var witness = Q.zero()
    for j in range(n):
        old_moment = QField.add(old_moment,chromo_blue(velocities[j]))
        new_moment = QField.add(new_moment,chromo_blue(next.velocities[j]))
    for i in range(n):
        for j in range(n):
            weighted_input = QField.add(
                weighted_input,
                QField.mul(rows[i][j],chromo_blue(velocities[j]))
            )
            for k in range(j+1,n):
                var product = QField.mul(rows[i][j],rows[i][k])
                var separation = _difference_blue(velocities[j],velocities[k])
                witness = QField.add(witness,QField.mul(product,separation))

    var old_variance = _sum_variance(velocities)
    var new_variance = _sum_variance(next.velocities)
    var moment_gap = QField.sub(old_moment,new_moment)
    var variance_gap = QField.sub(old_variance,new_variance)
    var row_identity = QField.eq(
        QField.sub(weighted_input,new_moment), witness)
    if not row_identity:
        return report^
    var mean_preserved = True
    var sx = Q.zero()
    var sy = Q.zero()
    var nx = Q.zero()
    var ny = Q.zero()
    for i in range(n):
        sx = QField.add(sx,velocities[i].x)
        sy = QField.add(sy,velocities[i].y)
        nx = QField.add(nx,next.velocities[i].x)
        ny = QField.add(ny,next.velocities[i].y)
    mean_preserved = QField.eq(sx,nx) and QField.eq(sy,ny)
    var global_identity = not column_unital or (
        mean_preserved and QField.eq(moment_gap,witness)
        and QField.eq(variance_gap,witness)
    )
    if not global_identity:
        return report^
    if not old_variance.accepted() or not new_variance.accepted() or (
        not moment_gap.accepted() or not witness.accepted()
    ):
        return report^

    report.ok = True
    report.column_unital = column_unital
    report.nonnegative_weights = nonnegative
    report.mean_preserved = mean_preserved
    report.moment_gap = moment_gap
    report.pairwise_witness = witness
    report.variance_before = old_variance
    report.variance_after = new_variance
    report.exact_identity = row_identity and global_identity
    report.nonincrease_certified = column_unital and nonnegative and (
        not witness.lt(Q.zero()) and new_variance.le(old_variance)
    )
    return report^
