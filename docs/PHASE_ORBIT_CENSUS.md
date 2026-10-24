# Complete F₇ two-oscillator orbit census — experiment PHASE7v1

## Reproducible experiment

The phase state is an ordered pair `(u,v)` of **oriented** blue-unit headings
over `F₇`; there are 8 possible headings, hence **64 states**. The update is
exactly the model already specified and verified in
`docs/PHASE_CONFORMANCE.md`: two symmetric unit-weight interactions,
zero self-coupling, κ=1, identity natural drift and identity phase lag.
Coupling is `det(u,v)` and each heading rotates by the Cayley map with its
corresponding signed coupling.

The resulting deterministic 64-vertex functional graph has the following
**complete finite signature**:

| Cycle period | Full basin | Longest tail | Number of components |
| ---: | ---: | ---: | ---: |
| 1 | 1 | 0 | 16 |
| 2 | 2 | 0 | 8 |
| 2 | 4 | 1 | 8 |

This has 32 total cycles, 16 fixed points, and maximum transient length 1.
The sum of component basins is `16·1 + 8·2 + 8·4 = 64`.
Exactly 48 states lie directly on cycles; 16 states are transient.

**Fixed states:** The 16 states with parallel (equal or antipodal) headings have
zero alternating determinant, so neither heading rotates under this zero-lag,
zero-natural-drift update. In this particular enumerated field, these are all
the fixed states (computationally exhaustive).

**Simultaneous rotation:** The update commutes with every common element of
the finite blue-unit rotation group. This is checked for all `8×64=512`
group/state pairs, rather than inferred from a numerical approximation.

## Evidence chain

The canonical pinned upstream Mojo executable generates actual phase transition
rows for every initial state, together with 512 modal-Vicsek records.
`tools.check_phase_conformance.verify` first checks the complete 576-row stream
against the independent exact Python oracle and committed corpus.
`tools.phase_orbit_census` then constructs a finite functional graph from
**the Mojo outputs themselves**, verifies closure and completeness, computes
basins and cycle structure using the generic exact census, and checks the
512 rotor-equivariance cases.

CI rejects missing/duplicate/noncanonical or corrupted records, inconsistent
model transitions, and cycle-signature discrepancies. It performs no
infinite limit and uses no field ordering or floating point.

## Claim classification

This is **exhaustive finite computation for one fully specified model**.
The finite identity and orbit signature do *not* assert a theorem about all
finite fields, all parameter regimes, or classical real Kuramoto dynamics.
General algebraic proofs and classification of parameter strata remain
open research steps. Python and Mojo agreement is implementation evidence,
not a formal Lean proof of the transition.
