# Shared finite-math-kernels contract and consumer boundary

This repository is a **consumer** of the reusable, field-independent mathematical kernels in `larsbx/finite-math-kernels`. The latter is the authoritative reusable Mojo library. Domain-specific swarm laws and model correspondence belong here.

## Upstream inventory (main at d4445ff59e7b5036081f56f066525ad7b60003fe)

| Upstream kernel | Responsibility | Swarm consumer |
| --- | --- | --- |
| `kernel/finite_exact/fp.mojo` | Typed `Fp[p]` and `FpField[p]`, rejecting invalid operations | Scalar substrate |
| `kernel/finite_exact/field.mojo` | `ExactField` structure | Generic finite geometry contract |
| `kernel/finite_polynomial/rabin_irreducibility.mojo` | Rabin irreducibility and replayable certificates | Validate quotient field presentations |
| `kernel/finite_polynomial/polynomial_fp.mojo` | Fp polynomial arithmetic | Finite-field extensions |
| `kernel/projective_limits/rotor.mojo` | Projective, non-isotropic rotor group over `ExactField` | Algebraic heading transport |
| `kernel/projective_limits/spread_polynomial.mojo` | Named spread-polynomial laws | Rational trigonometry |
| `kernel/finite_graph/{scc,union_find}.mojo` | Finite graph search | Swarm orbit and component census |

The new `reference/extension_chromogeometry.py` is an **independent, non-authoritative exact Python oracle** to validate field-extension geometries and experiments when Mojo is unavailable. It is not a claim that a second canonical field implementation exists. A production `F_(p^k)` substrate and any reusable chromogeometric algebra should be implemented upstream against the canonical `ExactField` protocol, then consumed here by a pinned, provenance-checked import or vendor dependency.

Do not silently copy named kernels into this repository and drift. For a future shared implementation, update the upstream library, pin its commit, and use its existing vendoring tooling and manifest rather than ad hoc copies. Do not claim this repository currently vendors or executes the Mojo kernels; the boundary is documented, not implemented.

## Presentation, arithmetic and typing policy

- Python oracle field presentation is `F_p[X]/(f)`, with monic irreducible `f`; it rejects composite characteristics, even characteristic, reducible or noncanonical presentations.
- A field element is tagged with its presentation; cross-field operations fail closed.
- Inversion of zero raises; spread returns `None` at a null denominator.
- The transition uses oriented blue-unit headings, **not** projective rays; antiparallel headings remain distinguishable in state.
- The Cayley-pole policy maps to `-I` as an explicitly declared finite totalization. This differs from the fully projective rotor construction upstream.
- No field ordering, real distances, or implicit probabilistic semantics are introduced.
- An exact Python finite check is only evidence for the checked domain; math proofs and verified implementation are independent obligations.

## Acceptance milestones

1. Current: independent F_p/F_(p^k) oracle with Rabin validation, exhaustive F_9 identities, sampled F_25, F_27 field arithmetic, prime-field differential checks, and finite orbit tests.
2. Next upstream PR: generic colored quadratic forms and exterior determinants under `ExactField`, with Mojo smoke tests; no copy of existing rotor, spread-polynomial or polynomial arithmetic.
3. Next consumer PR: import pinned canonical kernels with verified conformance vectors, create its `Mojo/MAX` accelerated path, and retain Python solely as independent differential oracle.
4. Formal PR: Lean definitions and proof of guarded spread/chromatic identities, then transition invariants. Tests shall not be represented as Lean proofs.
5. Model PRs: separate finite Cucker–Smale/Vicsek/Kuramoto-style state maps and behavioral/non-equivalence certificates.

No stage is marked complete on the basis of a document alone.
