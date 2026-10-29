# SGC-2: general-field planar cell and cochain certificates

This packet is a proof-only continuation of merged SGC-1 (PR #29). The
authoritative compiled implementation remains `kernel/swarm_models/projective_cells.mojo`;
reusable finite fields, projective spreads and determinants remain pinned to
`larsbx/finite-math-kernels`. The Lean proofs are checked against the
repository's pinned Mathlib revision without new axioms.

## Theorems

**GEO-05, general characteristic.** For a field `K` and four affine
vertices `A,B,C,D : K × K`, let `x=B-A`, `y=C-A`.
If `x∧y ≠ 0`, then

```text
  (B-A) ∧ (D-C) = 0 and (C-A) ∧ (D-B) = 0
       if and only if D=B+C-A.
```

The statement is a **wedge-numerator** theorem. To interpret it as
a zero-spread theorem, all four relevant direction quadrances must be
nonzero, because rational trigonometric spread has non-isotropic
guards. The proof does not introduce a finite-field order, angle,
analytic completion or nontrivial choice of square roots.

**TOP-04, general commutative rings.** For a four-step oriented walk
`A→B→D→C→A`, the signed boundary is zero:
`(B-A)+(D-B)+(C-D)+(A-C)=0`. This is a scalar evaluation of the
cellular boundary, rather than a stand-alone representation of its
graph incidence matrix.

**COH-01, general commutative rings.** Given any finite edge×face
boundary array `d₂`, edge cochain `j`, face chain `f`, exact
distributivity and interchange of finite sums give

```text
  Σ_face (Σ_edge j_edge * d₂(edge,face)) * f_face
    = Σ_edge j_edge * (Σ_face d₂(edge,face) * f_face).
```

If every face coboundary evaluation vanishes then the circulation
around every face-chain boundary is zero. No `d₁d₂=0` condition is
needed for this **pure pairing identity**. That condition is separately
required before interpreting `d₂` as a differential of a chain complex.

## Encoding, testing, and scope

- `formal/general/ChromoswarmCells.lean`: exact general-field/ring proofs.
- `formal/general/ChromoswarmCellVectors.lean`: separately imported
  consumer examples, committed before the theorem file.
- `formal/general/ChromoswarmAcceptance.lean`: imports earlier routing
  proofs and new cells, so the independent Lean checker sees both.
- Existing exhaustive `test_projective_cells_reference.py`, and pinned
  compiled `tests/mojo/test_projective_cells.mojo`, remain in CI.

Proofs do **not** establish that every arbitrary algebraic `d₂` is
geometrically realizable, that the Mojo program refines Lean for all
inputs, that topological cycles imply physical vortex motion, or that
a swarm update synchronizes. They only discharge the named algebraic
theorems.

## Next obligations

1. Formalize equivalence of bilinear spread and Cayley–Klein
   cross-ratio on the distinct-absolute-intersection locus.
2. Formalize permutation/relabeling invariance of the guarded filter.
3. Prove the verified graph-edge-word construction creates `d₁d₂=0`
   and integrate a finite Mojo-to-Lean or independent differential
   conformance packet.
4. Keep dynamical stabilization separate until an actual finite-state
   transition and a strict defect measure are specified.
