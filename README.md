# Finite Swarm Dynamics

An exact algebraic research program for swarm dynamics over **ℤ, ℚ, and finite fields**, using projective incidence, rational trigonometry, chromogeometry and explicitly typed dynamical models. **ℚ is a first-class ordered field**, not an approximation layer; finite fields retain their independent modular semantics.

## Foundational arithmetic domains (current architecture)

The core domain stack is **ℤ → ℚ**, together with separately guarded finite-field specializations and reductions. ℤ supports integral structures/certificates, ℚ supports exact division, ordered thresholds, rational probabilities, geometry and consensus, and finite fields support modular invariants, orbit classification and exhaustive verification. These domains have different ordering, normalization, and convergence properties.

See **[First-class ℤ/ℚ/finite-field architecture](docs/EXACT_ARITHMETIC_DOMAINS.md)**. The older finite-only sections below describe historical, still-supported implementation phases, **not** a restriction that excludes ℚ. Exact rational Python semantics are in `reference/rational_swarm.py`; CI also compiles rational tests against the canonical upstream Mojo `QField`.

## Chromoswarm kernel 0.1 (historical finite-field implementation)

This initial change establishes an executable reference kernel over **odd prime fields F_p**. It implements planar affine/projective incidence, blue/red/green quadratic forms, exact bilinear and determinant computations, guarded colored spreads and quadrea, algebraic blue rotations, and a synchronous oriented-heading swarm map with exact orbit detection.

All arithmetic is exact and modular. The dynamics use **no** floating point, real or complex numbers, transcendental functions, continuum limits, or ordering of field scalars. Only odd *prime* fields are implemented, not arbitrary extension fields.

### Test locally

Requires Python 3.11 or later; no third-party dependencies.

    python -m unittest discover -s . -v

Nine test methods exercise exact finite-field identities exhaustively over declared small domains (typically F_3, F_5, F_7, F_11) and verify sample swarm invariants. CI runs the full Python test suite once, on pinned Python 3.12. Lean and canonical Mojo have separate verification jobs.

### Main entrypoints

- Chromo(p): scalar arithmetic, quadratic forms, colored spreads, exterior determinant, projective join/meet/incident, quadrea, Cayley rotation.
- Agent(position, heading): oriented heading, requiring blue quadrance 1 for the update.
- Swarm(agents): immutable tuple of agents.
- Chromo.step(): deterministic synchronous chromatic-neighborhood swarm map.
- Chromo.orbit(): exact transient length and eventual cycle period.

### Mathematical contract

See [SPEC.md](SPEC.md) for definitions, guards and the distinction between proved identities and model-specific dynamics; see [THEOREMS.md](THEOREMS.md) for proofs.

**Deliberate nonclaims:** finite-state periodicity is not classical flocking convergence; projective directions do not carry the orientation of a heading; field-valued energies do not have an order; finite-field diffusion is not a real-valued Markov probability distribution. Computational tests are not universal Lean proofs.

### Next phases

1. Typed general characteristic-not-2 / extension-field geometry and reusable finite kernels.
2. Lean formalization of chromatic identities, null guards, rotations and transition invariants.
3. Independent finite Cucker–Smale, Vicsek and Kuramoto analogues with explicit correspondence/non-equivalence obligations.

## Extension-field reference (phase 0.2)

The exact non-authoritative Python oracle `reference/extension_chromogeometry.py`
implements algebraic blue/red/green geometry and finite swarm transitions over
validated quotient fields F_p[X]/(f), including genuinely non-prime fields.
It rejects reducible moduli and cross-field operands and explicitly guards
undefined spread values. New tests check F_9, F_25 and F_27 arithmetic and
compare all F_7 geometry against the original prime-field kernel.

Run `python -m unittest discover -s . -v`.

**Canonical source boundary:** See [shared-kernel consumer contract](docs/CONSUMER_BOUNDARY.md).
Reusable production field, polynomial and rotor kernels belong in
[larsbx/finite-math-kernels](https://github.com/larsbx/finite-math-kernels),
not in copies maintained independently in this repository. Python remains
an independent research/differential oracle until a pinned Mojo integration
and conformance checks are delivered.

## Finite linear alignment and functional-graph census

The exact Python oracle `reference/linear_alignment.py` now specifies an
algebraically row-stochastic velocity update and exhaustive finite-state orbit
census (for an explicitly enumerated domain within a declared cap). Its
`consensus_index()` determines whether **every** velocity configuration
reaches common velocity after at most N−1 steps, using the induced nilpotent
operator on the consensus quotient. This is an exact finite theorem, not a
contraction argument or an assertion of classical Cucker–Smale equivalence.

See [the alignment theorem and scope](docs/LINEAR_ALIGNMENT.md).

## Finite Vicsek/Kuramoto structural analogues

`reference/finite_phase_models.py` now provides an oriented modal-Vicsek update
with exact neighbor heading-count selection, plus a finite algebraic phase
oscillator model with determinant coupling and finite rotation-group drift.
Read [the model contracts](docs/FINITE_PHASE_MODELS.md) before interpreting
these as classical dynamical systems: their update and phase-transition
semantics differ. Test with `python -m unittest discover -s . -v`.

## Compiled Mojo finite alignment

The field-generic linear alignment step is implemented in `kernel/swarm_models/linear_alignment.mojo`, backed by the pinned upstream `ExactField` and `ChromoVec2`. CI compiles and exercises its directed-chain consensus and rejection cases in F_7 and F_13. The Python reference remains independent; see [Mojo alignment contract](docs/MOJO_ALIGNMENT.md).

## Exhaustive Mojo ↔ Python conformance

The 343 scalar configurations in `F_7³` for the directed alignment chain are replayed through actual pinned Mojo code and independently through the Python oracle. CI compares every canonical row against a versioned finite-field dataset; see [conformance protocol](docs/ALIGNMENT_CONFORMANCE.md).

## Exact rational N-agent variance certificates

The rational domain now includes a finite algebraic Jensen/variance identity for arbitrary agent count N, with a separate nonnegative/column-unital guard for ordered weak Lyapunov descent. A signed doubly unital counterexample and a rational Markov transition kernel distinguish algebraic row sums from probability. The compiled Mojo witness uses the canonical upstream `QField`; see [RQV-1 variance specification](docs/RATIONAL_VARIANCE.md). The arbitrary-finite-agent scalar and planar weak-descent theorems are kernel checked in `formal/general/ChromoswarmJensen.lean` and `ChromoswarmPlanar.lean`. `ChromoswarmStrict.lean` proves the exact variance-loss identity, strict descent if and only if a row mixes two distinct old planar velocities with positive weights, and the separate equality characterization. See [one-step strictness and its boundaries](docs/STRICT_VARIANCE.md). These are state-dependent finite-step results. The subsequent [rational overlap certificate](docs/OVERLAP_CONTRACTION.md) gives a sufficient uniform contraction rate and exact finite-horizon bound under additional explicit hypotheses. Eventual consensus and program refinement remain separate obligations.

Finite positive-overlap routes now also give a conservative rational rate for connected sparse supports whose minimum direct overlap is zero. Lean checks the finite routing hypotheses, strict descent off consensus, and the finite-horizon bound; see [routed contraction](docs/ROUTED_CONTRACTION.md).

## Exact leader placement / homology image certificates (LPC-1)

[Leader placement specification](docs/LEADER_PLACEMENT.md) connects spread-certified 2-cells to basis-independent homology-class coverage by leader neighborhoods. The compiled finite-field verifier in `kernel/swarm_models/leader_coverage.mojo` checks whether a policy cycle has an unpinned homologous representative using the exact linear equation `z = J_S y + ∂₂b`; it emits a supported witness or a coverage certificate. CI exercises guarded F_7 and F_13 cases. This is not a claim about spectral damping, matroid rank, optimal placement, or changing the original homology of the swarm.

## Guarded projective swarm-cell geometry (SGC-1)

[SGC-1 geometry/topology specification](docs/PROJECTIVE_SWARM_GEOMETRY.md) adds a compiled Mojo consumer for guarded planar Cayley–Klein spread quadrilateral admission, exact finite-field cellular ranks/Betti numbers, and oriented cycle/cochain circulation. Tests were committed before the kernel and are independently replayed using a Python finite-field oracle. Pinned CI compiles F_7/F_13 geometric and homology cases and F_5 isotropic rejection. A cell certificate does not imply consensus, physical vorticity or stabilization.

## General-field proof follow-up (SGC-2)

[General planar cell and Stokes proof packet](docs/SGC2_PROOF_STATUS.md) adds Lean theorems for exact parallelogram completion from independent wedge directions, oriented four-walk closure, and the cellular Stokes chain–cochain identity over arbitrary commutative rings. The formal statements preserve the distinction between wedge numerators and guarded rational-trigonometric spreads, and do not claim universal program refinement or swarm stabilization.

## Mathematical literature for projective finite-field swarm geometry

[Review of Cayley–Klein geometry, rational trigonometry, finite fields, and cellular algebra](docs/CAYLEY_KLEIN_FINITE_FIELD_LITERATURE_REVIEW.md) gives the classical and modern sources for the absolute/cross-ratio approach, its quadratic-form spread identity, Galois-descent and tangency distinctions, and the separate topology and dynamics literature. It is a literature survey, not a new theorem, proof acceptance record, or synchronization claim.

## Cayley–Klein projective root-ratio proof (SGC-3)

[Exact cross-ratio/spread proof status](docs/SGC3_CK_CROSS_RATIO.md) states the odd-characteristic Vieta/root-ratio identity, with a strict distinction between an ordinary distinct-root cross-ratio and its algebraic tangent extension. Lean and independent bounded split/non-split finite-field examples are separate from geometric face construction and synchronization dynamics.
