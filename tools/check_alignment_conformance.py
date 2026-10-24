"""Fail-closed, exhaustive differential check of Mojo vs Python F_7 alignment.

The checked fixture is an independent immutable 343-row data contract.
The reference is the independent, exact Python finite-field operator.
No truncated search or floating-point computation is allowed.
"""
from __future__ import annotations

import itertools
from pathlib import Path
import sys

from reference.extension_chromogeometry import FiniteField
from reference.linear_alignment import ConsensusOperator

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "conformance" / "alignment_F7_v1.txt"
COUNT = 7**3


def verify_rows(raw: str, fixture_raw: str) -> None:
    rows = raw.splitlines()
    fixture = fixture_raw.splitlines()
    if len(rows) != COUNT or len(fixture) != COUNT:
        raise ValueError("exhaustive 343-state corpus missing or truncated")
    if raw != ("\n".join(rows) + "\n") or fixture_raw != ("\n".join(fixture) + "\n"):
        raise ValueError("noncanonical final newline or blank line")
    f = FiniteField(7)
    zero, one = f.zero, f.one
    op = ConsensusOperator(
        f, ((zero, one, zero), (zero, zero, one), (zero, zero, one))
    )
    for i, (a, b, c) in enumerate(itertools.product(range(7), repeat=3)):
        expected = op.apply((f.element(a), f.element(b), f.element(c)))
        expected_line = (
            f"ALIGN7v1 {a} {b} {c} "
            + " ".join(str(e.coeffs[0]) for e in expected)
        )
        if fixture[i] != expected_line:
            raise ValueError(f"fixture disagrees with independent oracle at row {i}")
        if rows[i] != expected_line:
            raise ValueError(f"Mojo/output disagrees at row {i}: {rows[i]!r}")
    if len(set(rows)) != COUNT:
        raise ValueError("duplicate rows imply missing source states")


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        raise SystemExit("usage: python tools/check_alignment_conformance.py <mojo-output.txt>")
    verify_rows(Path(argv[1]).read_text(encoding="utf-8"), FIXTURE.read_text(encoding="utf-8"))
    print("PASS: exhaustive F_7^3 canonical Mojo/Python alignment conformance (343 rows)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
