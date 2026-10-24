"""Exact functional-graph census for the bounded F7^2 phase experiment.

Consumes the actual compiled-Mojo conformance stream. The phase subsystem
contains exactly 64 ordered states (8 unit-conic headings per agent).
The trailing modal portion is independently verified before use.
No bounded-search result is presented as a proof outside this fixed domain.
"""
from __future__ import annotations

from collections import Counter
from dataclasses import dataclass

from reference.linear_alignment import Census, exact_census
from tools.check_phase_conformance import GOLD, verify

Phase = tuple[int, int, int, int]


@dataclass(frozen=True)
class PhaseOrbitReport:
    state_count: int
    cycle_count: int
    fixed_points: int
    cycle_signature: tuple[tuple[int, int, int, int], ...]
    max_transient: int
    global_rotor_equivariance: bool


EXPECTED_SIGNATURE = ((1, 1, 0, 16), (2, 2, 0, 8), (2, 4, 1, 8))


def _rotate(u: tuple[int, int], rotor: tuple[int, int]) -> tuple[int, int]:
    (a, b), (x, y) = u, rotor
    return ((a*x-b*y) % 7, (a*y+b*x) % 7)


def _all_units() -> tuple[tuple[int, int], ...]:
    return tuple((x, y) for x in range(7) for y in range(7)
                 if (x*x+y*y) % 7 == 1)


def phase_orbit_report(raw: str, *, gold: str | None = None) -> PhaseOrbitReport:
    """Complete actual-Mojo transition census after full independent replay.

    Raises ValueError for malformed/missing/extra records, closedness failures
    or changed phase-orbit structure. This is not a partial search.
    """
    if gold is None:
        gold = GOLD.read_text(encoding="utf-8")
    verify(raw, gold)
    lines = raw.splitlines()[:64]
    transition: dict[Phase, Phase] = {}
    for line in lines:
        words = line.split(" ")
        if len(words) != 9 or words[0] != "PHASE7v1":
            raise ValueError("noncanonical two-agent phase record")
        try:
            vals = tuple(int(w) for w in words[1:])
        except ValueError as e:
            raise ValueError("phase record contains nondecimal scalar") from e
        if any(not 0 <= v < 7 for v in vals):
            raise ValueError("phase record has noncanonical field scalar")
        input_state = (vals[0], vals[1], vals[2], vals[3])
        output_state = (vals[4], vals[5], vals[6], vals[7])
        if input_state in transition:
            raise ValueError("duplicate phase state")
        transition[input_state] = output_state

    units = _all_units()
    domain = tuple((a, b, c, d)
                   for a, b in units for c, d in units)
    if len(domain) != 64 or set(transition) != set(domain):
        raise ValueError("phase state coverage is not exhaustive")
    if any(s not in transition for s in transition.values()):
        raise ValueError("phase update leaves the enumerated unit conic")

    census: Census = exact_census(domain, transition.__getitem__, max_states=64)
    counts = Counter((c.period, c.basin_size, c.max_transient) for c in census.cycles)
    signature = tuple(sorted((p, b, t, n) for (p, b, t), n in counts.items()))
    if signature != EXPECTED_SIGNATURE:
        raise ValueError(f"phase orbit signature differs: {signature!r}")

    # Each common unit-conic rotation acts diagonally on two phases.
    # We verify covariance of the *full transition map* on all 8×64 pairs.
    equivariant = True
    for rotor in units:
        for state in domain:
            a, b, c, d = state
            u, v = _rotate((a, b), rotor), _rotate((c, d), rotor)
            rotated_state: Phase = (*u, *v)
            nxt = transition[state]
            next_u, next_v = _rotate((nxt[0], nxt[1]), rotor), _rotate((nxt[2], nxt[3]), rotor)
            if transition[rotated_state] != (*next_u, *next_v):
                equivariant = False
                break
        if not equivariant:
            break
    if not equivariant:
        raise ValueError("finite phase map violates expected simultaneous rotor covariance")

    return PhaseOrbitReport(
        state_count=census.state_count,
        cycle_count=census.cycle_count,
        fixed_points=sum(c.period == 1 for c in census.cycles),
        cycle_signature=signature,
        max_transient=max(c.max_transient for c in census.cycles),
        global_rotor_equivariance=equivariant,
    )


def main(args: list[str]) -> int:
    from pathlib import Path
    import sys
    if len(args) != 2:
        raise SystemExit("usage: python -m tools.phase_orbit_census <compiled-phase-output>")
    report = phase_orbit_report(Path(args[1]).read_text(encoding="utf-8"))
    print(f"PASS: {report.state_count} F_7 phase states; "
          f"{report.cycle_count} cycles; {report.fixed_points} fixed points; "
          f"max tail {report.max_transient}; "
          f"signature={report.cycle_signature}; "
          f"rotation equivariance={report.global_rotor_equivariance}")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main(sys.argv))
