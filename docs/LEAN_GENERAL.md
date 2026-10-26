# General exact field and rational Lean theorems

This companion to the existing fast finite-field Lean library uses Mathlib 4 at **commit d13f23b723b8a846827a245b89c10fc7d3f11612**, paired with Lean v4.34.1 and a pinned transitive manifest.

Its scope is mathematically general rather than enumerative:

- Chromatic Pythagoras, blue/red/green Gram determinant identities, and mixed chromatic identity are formalized over **any commutative ring**. Spread division still requires nonzero denominators and characteristic distinct from 2 for polarization.
- For **all rational** velocities and all rational coupling weights, symmetric two-agent averaging preserves the sum, scales differences by `1−2a`, and scales squared blue disagreement by `(1−2a)²`.
- When `0 ≤ a ≤ 1`, it proves **weak one-step Lyapunov nonincrease** for scalar and planar rational velocities using exact ordered arithmetic.

The companion also includes arbitrary-finite-agent rational Jensen and planar weak variance descent (`ChromoswarmJensen`, `ChromoswarmPlanar`), and the exact loss, state-dependent strictness and equality theorems (`ChromoswarmStrict`). See [strict variance](STRICT_VARIANCE.md). `ChromoswarmContraction` adds a sufficient uniform rational overlap rate and an exact finite-horizon bound; see [overlap contraction](OVERLAP_CONTRACTION.md). Infinite-time convergence, continuous-time ODE equivalence and program refinement between Lean and Mojo remain separate proof obligations.

CI uses the independent Lean kernel checker, rejects new axioms and proof holes, and retains the original small-field Lean lane unchanged.
