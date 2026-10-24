"""Exhaustive F_7 unit-conic finite phase/model correspondence checker.

Exact, deterministic, no truncation or floating point. Independent Python
reference model and immutable finite golden data must both match compiled Mojo.
"""
from __future__ import annotations

from itertools import product
from pathlib import Path
import sys

from reference.extension_chromogeometry import Agent, ChromaticPlane, FiniteField, Swarm
from reference.finite_phase_models import PhaseState, finite_kuramoto_step, modal_vicsek_step

ROOT = Path(__file__).resolve().parents[1]
GOLD = ROOT / "conformance" / "phase_F7_v1.txt"
COUNTS = (64, 512)
TOTAL = sum(COUNTS)


def oracle_rows() -> list[str]:
    f = FiniteField(7)
    g = ChromaticPlane(f)
    e = g.v(1, 0)
    zero, one = f.zero, f.one
    units = [g.v(x, y) for x, y in product(f.elements(), repeat=2)
             if g.q(g.v(x, y), "b") == one]
    assert len(units) == 8
    rows = []
    phase_weights = ((zero, one), (one, zero))
    for u, v in product(units, repeat=2):
        nxt = finite_kuramoto_step(
            g, PhaseState((u, v)), weights=phase_weights, coupling=one,
            natural_rotors=(e, e), phase_lag_rotor=e
        )
        values = [u.x, u.y, v.x, v.y,
                  nxt.headings[0].x, nxt.headings[0].y,
                  nxt.headings[1].x, nxt.headings[1].y]
        rows.append("PHASE7v1 " + " ".join(str(s.coeffs[0]) for s in values))
    for a, b, c in product(units, repeat=3):
        old = Swarm((Agent(g.v(0, 0), a), Agent(g.v(0, 0), b), Agent(g.v(0, 0), c)))
        nxt = modal_vicsek_step(g, old, speed=zero)
        values = [a.x, a.y, b.x, b.y, c.x, c.y] + [
            el for agent in nxt.agents for el in (agent.heading.x, agent.heading.y)
        ]
        rows.append("MODAL7v1 " + " ".join(str(s.coeffs[0]) for s in values))
    return rows


def verify(actual: str, golden: str) -> None:
    if not actual.endswith("\n") or not golden.endswith("\n"):
        raise ValueError("canonical output requires a final LF newline")
    actual_rows, golden_rows = actual.splitlines(), golden.splitlines()
    if len(actual_rows) != TOTAL or len(golden_rows) != TOTAL:
        raise ValueError("incomplete finite state enumeration")
    if "\n".join(actual_rows)+"\n" != actual or "\n".join(golden_rows)+"\n" != golden:
        raise ValueError("noncanonical blank lines or line endings")
    expected = oracle_rows()
    if len(expected) != TOTAL or len(set(expected)) != TOTAL:
        raise AssertionError("independent oracle failed exhaustive state coverage")
    for i, row in enumerate(expected):
        if golden_rows[i] != row:
            raise ValueError(f"golden dataset differs from independent reference on row {i}")
        if actual_rows[i] != row:
            raise ValueError(f"compiled Mojo differs from exact Python model on row {i}")


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        raise SystemExit("usage: python -m tools.check_phase_conformance <compiled-output>")
    verify(Path(argv[1]).read_text(encoding="utf-8"), GOLD.read_text(encoding="utf-8"))
    print("PASS: exact Mojo/Python conformance on 64 F7 phase pairs and 512 modal triples")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
