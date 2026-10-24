# Lean formal verification — L0 finite certificates

This stage establishes a genuine Lean 4 compilation/checking gate without Mathlib or nonstandard axiom declarations. Toolchain: `leanprover/lean4:v4.34.1`, matching the estate's existing `euler-powers-research` Lean toolchain. The Lean library resides in `formal/lean/Chromoswarm.lean`. GitHub Actions runs `lean-action` and an independent `leanchecker` pass and refuses locally declared axioms, `sorry`, `admit` and `native_decide` in that file.

## Proven domain

- Fin 7: exact chromatic Pythagoras on 49 vectors, an explicit nonzero green-null vector, distinct opposite headings, blue-invariance of quarter turns, and fourth-power quarter-turn identity on 49 vectors.
- Fin 3: blue Gram determinant identity on 81 ordered vector pairs, plus one-step consensus and idempotence for a specific two-agent linear alignment update.

Finite enumeration using `by decide` is accepted by the Lean kernel. **It does not prove corresponding theorems over all F_(p^k), nor does it verify the Python implementation.** The executable Python tests remain separately CI-gated and provide independent reference evidence.

## Future general proofs

1. Abstract polynomial blue/red/green identities over any commutative ring with 2 invertible where required.
2. Domain-safe spreads using explicitly supplied nonzero-quadrance witnesses.
3. Exterior determinants, homogeneous projective incidence and chromatic covariance.
4. A general linear-consensus theorem: `P * 1 = 1` and nilpotence of the induced quotient operator iff universal finite-time consensus.
5. Bridge actual Mojo field kernels to certified conformance vectors without conflating tests with proofs.

Generalization milestones remain open until their Lean declarations compile and pass the axioms audit.
