"""Finite positive column-overlap routing certificates over exact rationals."""
from collections import deque
from dataclasses import dataclass
from fractions import Fraction as Q

from reference.rational_contraction import ContractionCertificate, column_overlap
from reference.rational_swarm import RationalConsensus


def shortest_routes(operator, eta):
    """Deterministic BFS; use positive edges, and a supplied threshold if any."""
    n = operator.n
    graph = tuple(tuple(k for k in range(n) if k != j and
                        column_overlap(operator, j, k) > 0 and
                        (eta is None or column_overlap(operator, j, k) >= eta))
                  for j in range(n))
    result = []
    for start in range(n):
        found = {start: (start,)}
        queue = deque([start])
        while queue:
            j = queue.popleft()
            for k in graph[j]:
                if k not in found:
                    found[k] = found[j] + (k,)
                    queue.append(k)
        if len(found) != n:
            raise ValueError("positive-overlap graph is disconnected at this threshold")
        result.append(tuple(found[k] for k in range(n)))
    return tuple(result)


@dataclass(frozen=True)
class RouteCertificate:
    operator: RationalConsensus
    eta: Q | None = None
    max_length: int | None = None
    routes: tuple[tuple[tuple[int, ...], ...], ...] | None = None

    def __post_init__(self):
        # Reuse the existing complete matrix validation and immutable snapshot.
        operator = ContractionCertificate(self.operator).operator
        object.__setattr__(self, "operator", operator)
        n = operator.n
        if self.eta is not None:
            if not isinstance(self.eta, Q):
                raise TypeError("eta must be an exact Fraction")
            if not 0 < self.eta <= 1:
                raise ValueError("eta must satisfy 0 < eta <= 1")
        paths = (shortest_routes(operator, self.eta) if self.routes is None else
                 tuple(tuple(tuple(path) for path in row) for row in self.routes))
        if len(paths) != n or any(len(row) != n for row in paths):
            raise ValueError("requires one finite route for every ordered agent pair")
        used = []
        longest = 0
        for j in range(n):
            for k in range(n):
                path = paths[j][k]
                if not path or path[0] != j or path[-1] != k:
                    raise ValueError("route endpoints do not match the ordered pair")
                if any(type(t) is not int or not 0 <= t < n for t in path):
                    raise ValueError("route leaves the finite population")
                longest = max(longest, len(path)-1)
                for a, b in zip(path, path[1:]):
                    overlap = column_overlap(operator, a, b)
                    if overlap <= 0 or (self.eta is not None and overlap < self.eta):
                        raise ValueError("route uses an absent or insufficient overlap edge")
                    used.append(overlap)
        if self.eta is None:
            object.__setattr__(self, "eta", min(used + [Q(1)]))
        if self.max_length is None:
            object.__setattr__(self, "max_length", max(1, longest))
        if type(self.max_length) is not int or self.max_length < 1 or self.max_length < longest:
            raise ValueError("positive integer route budget must cover every finite route")
        object.__setattr__(self, "routes", paths)

    @property
    def coefficient(self) -> Q:
        # Nonempty population and positive integer budget guard the denominator.
        return self.eta / (self.operator.n * self.max_length**2)

    @property
    def rate(self) -> Q:
        return 1 - self.coefficient

    def variance_bound(self, initial_variance: Q, steps: int) -> Q:
        if not isinstance(initial_variance, Q):
            raise TypeError("variance must be an exact Fraction")
        if initial_variance < 0 or type(steps) is not int or steps < 0:
            raise ValueError("requires nonnegative variance and a finite nonnegative horizon")
        return self.rate**steps * initial_variance
