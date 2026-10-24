"""Finite linear velocity alignment and exact scalar-state orbit census.

Research/reference model, not classical real-valued Cucker--Smale or
a canonical replacement for the finite-math-kernels Mojo graph library.
No ordered finite-field scalars, floating point, or asymptotic limits.
"""
from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Hashable, TypeVar

from reference.extension_chromogeometry import Element, FiniteField, Vec2


@dataclass(frozen=True)
class Flock:
    """Affine positions and *oriented velocities*, not normalized headings."""

    positions: tuple[Vec2, ...]
    velocities: tuple[Vec2, ...]


@dataclass(frozen=True)
class Cycle:
    """Exactly one cycle and its full basin within the enumerated state space."""

    indices: tuple[int, ...]
    basin_size: int
    max_transient: int

    @property
    def period(self) -> int:
        return len(self.indices)


@dataclass(frozen=True)
class Census:
    state_count: int
    cycles: tuple[Cycle, ...]

    @property
    def cycle_count(self) -> int:
        return len(self.cycles)


T = TypeVar("T", bound=Hashable)


def exact_census(
    states: tuple[T, ...],
    update: Callable[[T], T],
    *,
    max_states: int = 4096,
) -> Census:
    """All-state functional graph census; refuses caps and non-closed domains.

    Only explicitly supplied finite state spaces are claimed exhaustive.
    Index order is a deterministic enumeration convention, not field order.
    """
    if not states:
        raise ValueError("cannot census an empty state space")
    if len(states) > max_states:
        raise ValueError("census cap exceeded; no partial result")
    index = {s: k for k, s in enumerate(states)}
    if len(index) != len(states):
        raise ValueError("state enumeration contains duplicates")
    try:
        successors = tuple(index[update(s)] for s in states)
    except KeyError as e:
        raise ValueError("update is not closed on enumerated domain") from e
    reverse: list[list[int]] = [[] for _ in states]
    for i, j in enumerate(successors):
        reverse[j].append(i)

    visited: set[int] = set()
    roots: list[tuple[int, ...]] = []
    for start in range(len(states)):
        if start in visited:
            continue
        local: dict[int, int] = {}
        path: list[int] = []
        cur = start
        while cur not in visited and cur not in local:
            local[cur] = len(path)
            path.append(cur)
            cur = successors[cur]
        if cur in local:
            roots.append(tuple(path[local[cur]:]))
        visited.update(path)

    cycles: list[Cycle] = []
    assigned: set[int] = set()
    for root in roots:
        frontier = [(i, 0) for i in root]
        seen = set(root)
        for idx, depth in frontier:
            for predecessor in reverse[idx]:
                if predecessor not in seen:
                    seen.add(predecessor)
                    frontier.append((predecessor, depth+1))
        if assigned.intersection(seen):
            raise AssertionError("cycle basins overlap")
        assigned.update(seen)
        cycles.append(Cycle(root, len(seen), max(d for _, d in frontier)))
    if len(assigned) != len(states):
        raise AssertionError("census coverage failure")
    cycles.sort(key=lambda c: min(c.indices))
    return Census(len(states), tuple(cycles))


class ConsensusOperator:
    """Linear map P on F_q^N with rows summing to 1.

    Row-stochastic here is *algebraic* (P·1=1), never probabilistic.
    """

    def __init__(self, field: FiniteField, rows: tuple[tuple[Element, ...], ...]):
        n = len(rows)
        if n == 0 or any(len(row) != n for row in rows):
            raise ValueError("consensus operator requires a nonempty square matrix")
        for row in rows:
            if any(x.field != field for x in row):
                raise TypeError("matrix entries must use the same presented field")
            if sum(row, field.zero) != field.one:
                raise ValueError("each algebraic row sum must be 1")
        self.field = field
        self.rows = rows
        self.n = n

    @classmethod
    def from_weights(
        cls,
        field: FiniteField,
        weights: tuple[tuple[Element, ...], ...],
        coupling: Element,
    ) -> ConsensusOperator:
        n = len(weights)
        if n == 0 or any(len(row) != n for row in weights):
            raise ValueError("weight matrix must be nonempty and square")
        if coupling.field != field:
            raise TypeError("coupling scalar must lie in the chosen field")
        result: list[tuple[Element, ...]] = []
        for i, row in enumerate(weights):
            if any(x.field != field for x in row):
                raise TypeError("weight scalar from a different field")
            if row[i] != field.zero:
                raise ValueError("self-weight must be zero; diagonal is derived")
            result.append(tuple(
                field.one - coupling*sum(row, field.zero) if i == j
                else coupling*row[j]
                for j in range(n)
            ))
        return cls(field, tuple(result))

    def apply(self, state: tuple[Element, ...]) -> tuple[Element, ...]:
        if len(state) != self.n or any(x.field != self.field for x in state):
            raise ValueError("state must consist of N elements of the selected field")
        return tuple(sum((a*x for a, x in zip(row, state)), self.field.zero)
                     for row in self.rows)

    def apply_flock(self, state: Flock, *, speed: Element | None = None) -> Flock:
        if len(state.velocities) != self.n or len(state.positions) != self.n:
            raise ValueError("flock size must match operator dimension")
        nu = self.field.one if speed is None else speed
        if nu.field != self.field:
            raise TypeError("speed scalar must use the selected field")
        xs = tuple(v.x for v in state.velocities)
        ys = tuple(v.y for v in state.velocities)
        vx, vy = self.apply(xs), self.apply(ys)
        velocities = tuple(Vec2(x, y) for x, y in zip(vx, vy))
        positions = tuple(
            Vec2(old.x + nu*v.x, old.y + nu*v.y)
            for old, v in zip(state.positions, velocities)
        )
        return Flock(positions, velocities)

    def consensus_index(self) -> int | None:
        """Least m with every row of P^m identical; None means no universal
        finite-time velocity consensus. By the quotient nilpotency argument,
        if such m exists, m <= N-1.
        """
        n, f = self.n, self.field
        current = tuple(tuple(f.one if i == j else f.zero
                              for j in range(n)) for i in range(n))
        for m in range(n):
            if all(row == current[0] for row in current):
                return m
            current = tuple(tuple(
                sum((current[i][k]*self.rows[k][j] for k in range(n)), f.zero)
                for j in range(n)
            ) for i in range(n))
        return None

    def scalar_census(self, *, max_states: int = 4096) -> Census:
        """Exact census of all F_q^N scalar velocity states, not 2D positions."""
        q = self.field.size
        if q**self.n > max_states:
            raise ValueError("full scalar state census exceeds cap")
        elements = self.field.elements(max_size=max_states)
        states = tuple(product(elements, repeat=self.n))
        return exact_census(states, self.apply, max_states=max_states)
