# F₇ nonlinear phase dynamics: Lean L1 complete finite proof

The Lean module `formal/lean/Chromoswarm.lean` now independently defines the
**actual algebraic two-oscillator update** `phaseStep7` using oriented unit
headings over `Fin 7`, alternating determinant coupling, and the Cayley
rational rotation with an explicit pole policy.

The finite rotor inverse is represented as `den^5`; this is the
Fermat inverse for nonzero `den ∈ F₇`. The eight-blue-unit
heading enumeration is itself kernel-checked for soundness and completeness.

New **Lean kernel-checked**, closed-domain claims (no sorry/admit/axioms):
- `unitHeading7_sound`: all eight coded headings are blue units.
- `unitHeading7_complete`: all F₇² blue-unit headings appear in this list.
- `phaseStep7_preserves_units`: the exact nonlinear map respects blue unit
  headings for all 64 initial phase configurations.
- `phaseStep7_three_eq_one`: on all 64 valid states, `F³(x)=F(x)`.
  In particular, every orbit is fixed or reaches a 2-cycle after at most
  one transition; this is an exact finite result, **not** a universal-field
  theorem or an asymptotic convergence claim.
- `phaseStep7_fixed_iff_det_zero`: all 16 fixed states have zero
  alternating determinant, and conversely.

These proofs evaluate the **formula**, not a precomputed lookup table.
The separately generated 64-state actual Mojo/Python orbit census
(`docs/PHASE_ORBIT_CENSUS.md`) additionally certifies the more detailed
cycle/basin signature. Lean does not yet certify basin counts or program
equivalence between the Lean, Python and Mojo implementations.

Next formal objective: move from closed F₇ enumeration to abstract identities
over arbitrary characteristic ≠ 2, plus the general quotient-nilpotence
consensus theorem. Mathematical equality is not inferred from one finite
dataset.
