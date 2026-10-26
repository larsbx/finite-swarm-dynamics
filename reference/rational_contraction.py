"""Exact finite overlap certificates for the rational swarm reference model.

This is an independent research oracle. It does not extend the production
Mojo API or claim refinement between executable code and the Lean model.
"""
from dataclasses import dataclass
from fractions import Fraction as Q

from reference.rational_swarm import RationalConsensus


def column_overlap(operator: RationalConsensus, j: int, k: int) -> Q:
    """Σ_i P_ij P_ik: two original agents contribute to a common update row."""
    if not 0 <= j < operator.n or not 0 <= k < operator.n:
        raise IndexError("agent index outside the population")
    return sum((row[j] * row[k] for row in operator.rows), Q(0))


@dataclass(frozen=True)
class ContractionCertificate:
    """Construct with a validated rational operator and optional lower bound.

    An explicit eta is checked, never silently reduced. With eta omitted,
    choose the minimum off-diagonal overlap, capped at 1/n. For n=1 use
    1/n: the pair condition is vacuous and every variance is zero.
    """
    operator: RationalConsensus
    eta: Q | None = None

    def __post_init__(self):
        if not isinstance(self.operator, RationalConsensus):
            raise TypeError("operator must be a RationalConsensus")
        # Snapshot rows so mutable caller-owned lists cannot invalidate a
        # previously checked certificate. Revalidate the complete operator.
        snapshot = RationalConsensus(tuple(tuple(row) for row in self.operator.rows))
        object.__setattr__(self, "operator", snapshot)
        if not self.operator.doubly_stochastic:
            raise ValueError("requires nonnegative weights and both row and column sums one")
        n = self.operator.n  # RationalConsensus has already checked n>0.
        lower = min((column_overlap(self.operator, j, k)
                     for j in range(n) for k in range(j)), default=Q(1, n))
        if self.eta is None:
            object.__setattr__(self, "eta", min(lower, Q(1, n)))
        elif not isinstance(self.eta, Q):
            raise TypeError("eta must be an exact Fraction")
        if not 0 <= self.eta <= Q(1, n) or self.eta > lower:
            raise ValueError("eta violates nonnegativity, rate range or a pair overlap")

    @property
    def rate(self) -> Q:
        return 1 - self.operator.n * self.eta

    @property
    def has_positive_overlap(self) -> bool:
        """Sufficient for a rate below one, not necessary for contraction."""
        return self.eta > 0

    def variance_bound(self, initial_variance: Q, steps: int) -> Q:
        if not isinstance(initial_variance, Q):
            raise TypeError("variance must be an exact Fraction")
        if initial_variance < 0:
            raise ValueError("initial variance must be nonnegative")
        if type(steps) is not int or steps < 0:
            raise ValueError("steps must be a finite nonnegative integer")
        return self.rate ** steps * initial_variance
