"""Two strictly finite, oriented swarm analogues: modal Vicsek and phase Kuramoto.

The modal choice uses finite equality counts; it has no field-valued argmin.
Every tie retains the current heading, avoiding coordinate-enumeration bias.
Phase coupling uses an alternating determinant and finite unit-quadrance rotors.
Neither dynamics is claimed to be an analytic discretization of the originals.
"""
from __future__ import annotations

from dataclasses import dataclass

from reference.extension_chromogeometry import (
    Agent, ChromaticPlane, Element, Swarm, Vec2,
)


@dataclass(frozen=True)
class PhaseState:
    """Oriented unit-blue headings of finite oscillators."""
    headings: tuple[Vec2, ...]


def _unit(g: ChromaticPlane, heading: Vec2) -> bool:
    if heading.x.field != g.f or heading.y.field != g.f:
        return False
    return g.q(heading, "b") == g.f.one


def _require_units(g: ChromaticPlane, headings: tuple[Vec2, ...]) -> None:
    if not all(_unit(g, u) for u in headings):
        raise ValueError("all oriented headings and rotors must be blue-unit vectors")


def rotor_multiply(g: ChromaticPlane, a: Vec2, b: Vec2) -> Vec2:
    """SO(Q_blue) multiplication as a polynomial map, not complex arithmetic."""
    _require_units(g, (a, b))
    return g.v(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x)


def inverse_rotor(g: ChromaticPlane, u: Vec2) -> Vec2:
    _require_units(g, (u,))
    return g.v(u.x, -u.y)


def relative_rotor(g: ChromaticPlane, first: Vec2, second: Vec2) -> Vec2:
    """first^{-1} * second: oriented relative phase, not merely spread."""
    return rotor_multiply(g, inverse_rotor(g, first), second)


def _validate_guards(
    g: ChromaticPlane, guards: dict[str, frozenset[Element]] | None
) -> dict[str, frozenset[Element]]:
    selected = guards or {}
    if any(
        c not in ("b", "r", "g")
        or any(not isinstance(v, Element) or v.field != g.f for v in values)
        for c, values in selected.items()
    ):
        raise ValueError("chromatic guards must contain only chosen-field elements")
    return selected


def modal_vicsek_step(
    g: ChromaticPlane,
    state: Swarm,
    *,
    speed: Element | None = None,
    allowed_quadrances: dict[str, frozenset[Element]] | None = None,
    noise_rotors: tuple[Vec2, ...] | None = None,
) -> Swarm:
    """Synchronous modal finite heading alignment.

    For agent i, include self plus neighbors satisfying all specified color
    membership predicates. Count exact headings among observed old neighbors.
    A unique most frequent heading wins. Every tie leaves u_i unchanged.
    An optional independently supplied list of unit rotors perturbs headings;
    noise is a specified finite transition input, *not* assumed Gaussian.
    """
    f = g.f
    nu = f.one if speed is None else speed
    if nu.field != f:
        raise TypeError("speed belongs to the plane field")
    guards = _validate_guards(g, allowed_quadrances)
    n = len(state.agents)
    _require_units(g, tuple(a.heading for a in state.agents))
    if noise_rotors is not None:
        if len(noise_rotors) != n:
            raise ValueError("one supplied noise rotor is needed per agent")
        _require_units(g, noise_rotors)

    new_headings: list[Vec2] = []
    for i, agent in enumerate(state.agents):
        counts: dict[Vec2, int] = {agent.heading: 1}
        for j, other in enumerate(state.agents):
            if i == j:
                continue
            difference = g.sub(other.position, agent.position)
            if all(g.q(difference, c) in values for c, values in guards.items()):
                counts[other.heading] = counts.get(other.heading, 0) + 1
        max_count = max(counts.values())
        winners = [h for h, count in counts.items() if count == max_count]
        selected = winners[0] if len(winners) == 1 else agent.heading
        if noise_rotors is not None:
            selected = rotor_multiply(g, noise_rotors[i], selected)
        new_headings.append(selected)
    return Swarm(tuple(
        Agent(g.add(a.position, g.scale(nu, h)), h)
        for a, h in zip(state.agents, new_headings)
    ))


def finite_kuramoto_step(
    g: ChromaticPlane,
    state: PhaseState,
    *,
    weights: tuple[tuple[Element, ...], ...],
    coupling: Element,
    natural_rotors: tuple[Vec2, ...],
    phase_lag_rotor: Vec2 | None = None,
) -> PhaseState:
    """Finite algebraic phase-oscillator map.

    t_i = coupling Σ_j w_ij det(u_i, phase_lag * u_j)
    u_i+ = natural_i * Cayley(t_i) * u_i.

    A Cayley pole is totalized as -I by ChromaticPlane.rotation().
    Pairwise det and the rotor group law are algebraic; this is not classical
    continuous-time sine coupling or the Ott–Antonsen reduction.
    """
    n = len(state.headings)
    if len(natural_rotors) != n or len(weights) != n:
        raise ValueError("oscillator/drift/weight array sizes must agree")
    if any(len(row) != n for row in weights):
        raise ValueError("weight matrix must be square")
    if coupling.field != g.f:
        raise TypeError("coupling belongs to the plane field")
    if any(
        not isinstance(w, Element) or w.field != g.f
        for row in weights for w in row
    ):
        raise TypeError("weight entry belongs to a different field")
    if any(weights[i][i] != g.f.zero for i in range(n)):
        raise ValueError("self coupling is excluded")
    lag = g.v(1, 0) if phase_lag_rotor is None else phase_lag_rotor
    _require_units(g, state.headings + natural_rotors + (lag,))

    nxt: list[Vec2] = []
    for i in range(n):
        t = g.f.zero
        for j in range(n):
            if j == i:
                continue
            lagged = rotor_multiply(g, lag, state.headings[j])
            t = t + weights[i][j] * g.det(state.headings[i], lagged)
        intermediate = g.rotate(state.headings[i], coupling * t)
        nxt.append(rotor_multiply(g, natural_rotors[i], intermediate))
    return PhaseState(tuple(nxt))


def exact_coherence(state: PhaseState) -> tuple[int, int]:
    """Integer pair counts: identically oriented headings, total unordered pairs."""
    n = len(state.headings)
    matches = sum(
        state.headings[i] == state.headings[j]
        for i in range(n) for j in range(i+1, n)
    )
    return matches, n*(n-1)//2
