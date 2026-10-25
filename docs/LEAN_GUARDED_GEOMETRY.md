# General Lean guarded chromogeometry and exact rotations

This stage extends the pinned Mathlib companion (`formal/general`) beyond polynomial identities.

- For **all field elements** with explicit nonzero denominators, Lean checks the blue, red, and green determinant forms of spread. Undefined/null denominators are *not* assigned a spread value; the theorem is conditional.
- The generic Cayley rotor law is certified for any field at parameters satisfying `1+t² ≠ 0`: the resulting `c,s` fulfill `c²+s²=1`.
- Blue preservation and coupled red/green covariance are universal polynomial identities of the rotation matrix.
- For **all rationals `t:ℚ`**, Lean proves `1+t²>0` and therefore guards rational Cayley rotation without a pole. The exceptional half-turn remains a separately represented group element.

These results quantify over arbitrary stated ring/field types and rational parameters. They are not the small-field `by decide` certificates, and they do not claim an analysis-based limit, full projective rotation-group formalization, or general N-agent Jensen inequality.

The CI uses the exact pinned Lean/Mathlib manifest and independent Lean kernel checker and keeps the separate fast finite-field proof lane.
