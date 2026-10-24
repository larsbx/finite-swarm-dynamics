# Compiled finite phase models (Mojo)

`kernel/swarm_models/finite_phase.mojo` contains the first compiled, exact
finite-state implementations of modal Vicsek and algebraic Kuramoto-inspired
dynamics. It imports `ExactField` and `ChromoVec2` from the pinned
`finite-math-kernels` repository and owns only the agent update laws.

- `modal_vicsek_step` accepts a directed Boolean observation graph
  (caller-selected, not necessarily symmetric), old affine positions,
  oriented blue-unit headings, supplied finite unit-conic noise rotors and a
  field-valued speed. Self is always observed. It uses integer vote
  multiplicities and retains the old heading at a tie, then applies the
  noise rotor and advances positions *synchronously*.
- `finite_kuramoto_step` accepts an algebraic zero-diagonal weighted matrix,
  oriented blue-unit headings, coupling, natural drift rotors, and an explicit
  phase-lag rotor. Coupling is the alternating determinant and dynamics use the
  Cayley rational rotation, including the deliberately specified `-I`
  totalization when `1+t²=0`.

Both functions reject malformed sizes, rejected field entries, non-unit
rotors, or invalid adjacency diagonals without reporting partial success.
Neither model introduces real or complex phases, real order or stochastic
assumptions. A supplied `noise_rotors` argument is a deterministic input;
a separate finite random-channel model may provide it later.

**Boundary:** The graph mask is an explicit input and can be constructed from
the caller's chromatic quadrance predicates. The compiled updates do not
silently choose a metric ordering or range threshold. No classical analytic
equivalence is claimed. Reference Python semantics remain independent.

CI tests exact unanimous drift, anti-phase stationary configurations, polar
orientation, majority/tie handling, invalid inputs, blue-unit preservation and
F_5 Cayley poles over F_5/F_7/F_13. These are bounded executable checks,
not universal Lean proofs.
