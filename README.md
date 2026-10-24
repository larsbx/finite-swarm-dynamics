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
