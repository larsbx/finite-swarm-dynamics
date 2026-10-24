# Finite Swarm Dynamics

An algebraic research program for swarm dynamics over finite fields, with projective incidence, rational trigonometry and chromogeometry.

## Chromoswarm kernel 0.1

This initial change establishes an executable reference kernel over **odd prime fields F_p**. It implements planar affine/projective incidence, blue/red/green quadratic forms, exact bilinear and determinant computations, guarded colored spreads and quadrea, algebraic blue rotations, and a synchronous oriented-heading swarm map with exact orbit detection.

All arithmetic is exact and modular. The dynamics use **no** floating point, real or complex numbers, transcendental functions, continuum limits, or ordering of field scalars. Only odd *prime* fields are implemented, not arbitrary extension fields.

### Test locally

Requires Python 3.11 or later; no third-party dependencies.

    python -m unittest discover -s . -v

Nine test methods exercise exact finite-field identities exhaustively over declared small domains (typically F_3, F_5, F_7, F_11) and verify sample swarm invariants. CI executes the tests on Python 3.11, 3.12, and 3.13.

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
