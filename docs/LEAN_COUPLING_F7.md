# Lean L2: all seven couplings in F₇

Lean now models the actual finite two-oscillator update at a **variable
coupling** `k : Fin 7`, rather than only the previously fixed `k=1`.

Five kernel-checked theorem statements cover the explicitly finite
parameter/state family: formula agreement at k=1, unit-heading preservation,
`F_k³=F_k` for every k and all 64 oriented states, conjugacy
`T ∘ F_k = F_(−k) ∘ T` with `T(u,v)=(u,−v)`, and `T²=id`.

The finite Lean proof obligations evaluate the algebraic Cayley formula
directly, not the committed Mojo/Python transition corpus. Existing CI
performs Lean compilation and independent `leanchecker` verification.

**Scope:** exactly 7×64=448 finite configurations with the symmetric
zero-lag, identity-drift model. This is not an all-fields theorem, a
proof of classical Kuramoto correspondence, or full verification of the
Mojo implementation. The separate `docs/COUPLING_STRATIFICATION.md`
documents complete cycle/basin counts from independently verified
runtime transitions.

The general theory over arbitrary odd-characteristic fields, and the
linear-consensus quotient-nilpotence theorem, remain further milestones.
