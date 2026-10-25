"""Finite, exact rational Jensen/variance certificates for N-agent alignment.

No real limits are used: a certificate is a finite rational equality and,
when P has nonnegative rational entries, an ordered nonnegativity proof
obligation. Polynomial identities alone do not imply energy dissipation.
"""
from __future__ import annotations
from dataclasses import dataclass
from fractions import Fraction as Q

from reference.rational_swarm import (
    RationalConsensus, VecQ, add, q, rational_mean, scale, sub, vec,
)


def norm_square(u: VecQ) -> Q:
    return q(u, "b")


def total_quadrance(values: tuple[VecQ, ...]) -> Q:
    return sum((norm_square(u) for u in values), Q(0))


def variance(values: tuple[VecQ, ...]) -> Q:
    """Sum, not average, of squared deviations from the exact rational mean."""
    mean = rational_mean(values)
    return sum((norm_square(sub(u, mean)) for u in values), Q(0))


def pair_gap(
    row: tuple[Q, ...], values: tuple[VecQ, ...],
) -> Q:
    """Σ_{j<k} p_j p_k Q_blue(v_j−v_k), exact signed algebraic expression."""
    if len(row) != len(values):
        raise ValueError("row and state lengths differ")
    return sum((
        row[j] * row[k] * norm_square(sub(values[j], values[k]))
        for j in range(len(row)) for k in range(j + 1, len(row))
    ), Q(0))


@dataclass(frozen=True)
class VarianceCertificate:
    n: int
    row_unital: bool
    column_unital: bool
    nonnegative: bool
    mean_preserved: bool
    old_variance: Q
    new_variance: Q
    moment_gap: Q
    pairwise_witness: Q
    equality_verified: bool
    nonincrease_certified: bool


def rational_variance_certificate(
    operator: RationalConsensus, values: tuple[VecQ, ...],
) -> VarianceCertificate:
    """Produce a *checked* exact N-agent Jensen identity.

    For a doubly row/column-unital P:
      Σ_i Q(v_i) − Σ_i Q((Pv)_i)
         = Σ_i Σ_{j<k} P_ij P_ik Q(v_j−v_k).
    The rational mean is preserved. The same identity then holds for
    variance about that common mean.

    A certificate may be *valid* for signed P, without certifying decay.
    If P has nonnegative entries, the witness is manifestly ≥0 over Q.
    """
    if len(values) != operator.n:
        raise ValueError("state dimension does not match the operator")
    updated = operator.update_velocities(values)
    col_unital = all(
        sum((operator.rows[i][j] for i in range(operator.n)), Q(0)) == 1
        for j in range(operator.n)
    )
    old_moment = total_quadrance(values)
    new_moment = total_quadrance(updated)
    weighted_input = sum((
        operator.rows[i][j] * norm_square(values[j])
        for i in range(operator.n) for j in range(operator.n)
    ), Q(0))
    witness = sum((pair_gap(row, values) for row in operator.rows), Q(0))
    # Jensen identity per row does not need column unitality.
    row_identity = weighted_input - new_moment == witness
    if not row_identity:
        raise AssertionError("exact algebraic row-Jensen identity failed")
    old_var, new_var = variance(values), variance(updated)
    mean_preserved = rational_mean(updated) == rational_mean(values)
    if mean_preserved != col_unital and operator.n > 0:
        # The given state can have accidental mean preservation even when
        # the operator fails column unitality. Do not infer a universal fact.
        pass
    global_identity = col_unital and old_moment - new_moment == witness
    var_identity = col_unital and old_var - new_var == witness
    if col_unital and not (global_identity and var_identity and mean_preserved):
        raise AssertionError("doubly unital variance identity violated")
    positive = operator.convex
    monotone = (col_unital and positive and witness >= 0 and
                old_var >= new_var and var_identity)
    return VarianceCertificate(
        n=operator.n,
        row_unital=True,
        column_unital=col_unital,
        nonnegative=positive,
        mean_preserved=mean_preserved,
        old_variance=old_var,
        new_variance=new_var,
        moment_gap=old_moment-new_moment,
        pairwise_witness=witness,
        equality_verified=row_identity and (not col_unital or var_identity),
        nonincrease_certified=monotone,
    )


@dataclass(frozen=True)
class RationalMarkov:
    """Actual rational transition probabilities, not field-valued row sums."""
    rows: tuple[tuple[Q, ...], ...]

    def __post_init__(self) -> None:
        n = len(self.rows)
        if not n or any(len(row) != n for row in self.rows):
            raise ValueError("requires a nonempty square transition matrix")
        for row in self.rows:
            if any(not isinstance(x, Q) or x < 0 for x in row):
                raise ValueError("probability entries must be nonnegative rationals")
            if sum(row, Q(0)) != 1:
                raise ValueError("probabilities in each row must sum to exactly one")

    def advance(self, probabilities: tuple[Q, ...]) -> tuple[Q, ...]:
        n = len(self.rows)
        if len(probabilities) != n or any(
            not isinstance(p, Q) or p < 0 for p in probabilities
        ) or sum(probabilities, Q(0)) != 1:
            raise ValueError("input distribution must be a valid rational simplex")
        out = tuple(sum((
            probabilities[i]*self.rows[i][j] for i in range(n)
        ), Q(0)) for j in range(n))
        assert sum(out, Q(0)) == 1 and all(v >= 0 for v in out)
        return out
