# Certified swarm geometry and leader placement: exact homology image test (LPC-1)

**Status (2026-10-27):** first compiled Mojo verifier and bounded regression suite, not a proof that a proposed placement is optimal or that pinning damps a physical dynamical mode. The field-linear equivalence below is mathematical; the implemented checks use the pinned upstream `ExactField` implementation. Formal Lean proof, persistent-bar extraction, and a globally optimal planner are **not** included in LPC-1.

## 1. Arithmetic and geometric boundary

The foundational domains remain **ℤ, ordered ℚ, and separately guarded finite fields**, following [EXACT_ARITHMETIC_DOMAINS.md](EXACT_ARITHMETIC_DOMAINS.md). No modular ordering, positivity, real spectrum, infinitesimal angle, or continuum limit is inferred.

Choose an odd-characteristic field `F`, a nondegenerate quadratic form `Q`, its polar form `B`, and the absolute quadric `Ω={ [u] : Q(u)=0 }` in the hyperplane at infinity. Nonisotropic direction spread is

```
s_Ω([u],[v]) = 1 - B(u,v)^2 / (Q(u) Q(v)),
guard: Q(u) != 0 and Q(v) != 0.
```

For a non-tangent projective line through the directions this is also `(2-(ρ+ρ⁻¹))/4` with `ρ=cr([u],[v];α,β)` for the two distinct intersections with the absolute. When the line is tangent (`α=β`), the displayed cross-ratio is not an admissible definition even though the guarded bilinear spread is defined. Do not silently identify `s=0` with equal **oriented** headings.

Let interaction edges and admissible 2-cell boundaries be constructed from *specified* quadrance and spread tests. Over `F_p`, a filter is an explicit set `S_t ⊆ F_p` with `S_t ⊆ S_(t+1)`; it is never a field inequality. Each newly admitted 2-cell must be an actual cellular attachment with a closed edge-word and `∂₁∂₂=0`. A geometric 2-cell does not automatically certify that its boundary has zero physical circulation under a separate dynamical model.

An abstract finite oriented 2-dimensional **cell complex** `K_t` suffices: degree-two boundaries may contain multiple edges with signed coefficients. A simplicial model is an optional stricter specialization.

## 2. Leader placement does not change the original homology

Let `G=K_t^(1)` be the interaction graph. For a set of pinned/informed vertices `S`, form the closed graph neighborhood `N_G[S]` and retain exactly vertices `V\\N_G[S]` with their entire supported cells:

```
U_t(S) = K_t[V \\ N_G[S]]   (induced subcomplex)
i_S    : U_t(S) ↪ K_t
I_1    : C₁(U_t(S);F) ↪ C₁(K_t;F)
```

This is an **induced vertex deletion**. The phrase `K minus the closed star` is ambiguous: the complement of a closed star is not generally a subcomplex. Removal includes all edges/faces incident to removed vertices.

For a specified nonzero policy class `c=[z] ∈ H₁(K_t;F)` define

```
covered(S,c)  iff  c ∉ image(H₁(U_t(S);F) --i_S,*--> H₁(K_t;F)).
```

It means there is no representative of `c` wholly supported away from the removed region. It does **not** claim that the original homology group changes or that pinning forces dynamical decay. If `S⊆T`, then `U_t(T)⊆U_t(S)`; hence coverage is monotone in `S`.

Policy is a **finite, explicitly tracked family** of nonzero classes (e.g. classes certified by selected persistence intervals), not the entire module disguised as a finite canonical set of barcode elements. A homology barcode alone does not canonically assign a support to every class. Track cycle witnesses, filtration maps, interval choices and an identification rule. A basis of `H₁` is suitable for verifying **zero image** universally, but covering each chosen basis class separately does not generally cover every nonzero linear combination.

## 3. Linear-algebra theorem: no homology bases necessary

Write `d₁:C₁(K;F)→C₀(K;F)`, `d₂:C₂(K;F)→C₁(K;F)`. Assume `d₁d₂=0` and `d₁z=0`. Let `J_S` be the matrix whose columns are standard edge basis vectors for edges of `U(S)`. Then:

> **Theorem (inclusion-image criterion).** For a cycle `z`,
>
> `[z] ∈ im(i_S,*)  ⇔  ∃ y,b : J_S y + d₂ b = z`.
>
> Equivalently, `rank([J_S | d₂]) = rank([J_S | d₂ | z])`.

**Proof.** If the class has a preimage, choose a representative cycle `y` on `U(S)`. The difference `z-J_Sy` is a boundary, hence equals `d₂b`. Conversely, any displayed equality implies `d₁J_Sy=d₁z-d₁d₂b=0`. Since `U(S)` is induced, `J_Sy` is a supported cycle in `U(S)`; therefore it represents a preimage of `[z]`. □

The proof is valid over **any field**. The compiled Mojo implementation uses odd prime-field instances of `ExactField` and returns a witness `J_Sy` when the augmented system is consistent.

For verification of **all** classes (not just a selected policy set):

```
im(i_S,*) = 0  ⇔  im(J_S) ⊆ im(d₂) on cycles.
```

For an implementable rank formulation compute a basis `Z_U` of `ker(d₁|_(edges of U))` and check `rank([d₂ | J_S Z_U]) = rank(d₂)`. Simply checking the columns of `J_S` is **wrong**, since individual edges need not be cycles.

### Mojo contract

`kernel/swarm_models/leader_coverage.mojo` implements

```
verify_leader_coverage[K: ExactField](boundary1, boundary2, cycle, leaders)
    -> CoverageCheck[K] { ok, covered, witness }
```

- `boundary1`: vertices × edges, exactly one `-1` and one `+1` per edge; oriented simple graph without loops.
- `boundary2`: edges × attached 2-cells, all rows same length; verifies `d₁d₂=0`.
- `cycle`: full edge vector; verifies `d₁cycle=0`.
- `leaders`: vertex flags; derive the original graph closed neighborhood *before* deleting edges.
- Field scalar acceptance and characteristic-not-two guards fail closed; no division by zero.
- `ok=false` means malformed/unsupported input, **not** “covered.”
- If `ok=true, covered=false`, the `witness` is an exact cycle on `U(S)` homologous to the input cycle.
- If `ok=true, covered=true`, there is no such witness. This statement is independent of a chosen homology basis.

Worst-case work is standard dense elimination on an `|E| × (|E_U|+|F|+1)` augmented matrix; no sparse or polynomial-time optimal placement claim follows. The solver builds a full matrix and is currently intended for bounded finite research examples.

## 4. Cohomology greedy is a proxy only

With `F` a field, select named cohomology classes `[ω_j]` with **declared** cocycle representatives `ω_j`. Define `H_j` as the endpoints of edges where the chosen cochain is nonzero (optionally enlarge by a documented neighborhood). For nonnegative rational policy weights `w_j`:

```
proxy(S) = sum_j w_j * 1[S ∩ H_j != ∅].
```

This **representative-dependent** proxy is monotone submodular; cardinality-`k` greedy has the usual `1−1/e` guarantee **for this proxy only**. It has no automatic guarantee for invariant coverage or for the number of leaders needed. For exact verification use the inclusion-image solver above on homology cycle witnesses. Cohomology–homology pairing `ω(z)` may inform **heuristic** weight updates but does not make cochain supports canonical, nor turn a cocycle into a graph cut. In general cellular complexes, 1-cocycles are *not* necessarily cuts.

A feasible loop is:

1. Choose a finite class policy and budget with traceable geometric certificates.
2. Propose vertices using deterministic greedy support coverage, tie-breaking consistently.
3. Check each required class with `verify_leader_coverage`.
4. For a residual class the solver provides a currently unpinned representative. A new leader incident to its support removes **that witness**, but may leave another representative and is **not** proof of strict progress in the image or a guarantee of budget-optimal termination.
5. Continue only while gaining previously unselected vertices. If exhausted, return explicit `incomplete` with residual witnesses. Exhaustive subset enumeration gives an exact bounded optimizer for small graphs; it is not yet implemented here.

Do not assert greedily selected leaders are optimal because arithmetic is discrete. Even basic `rank(L+diag(1_S))` need **not** be monotone over a finite field: over `F_3`, the two-vertex unit-edge Laplacian `[[1,-1],[-1,1]]` has rank 2 after pinning the first vertex, but rank 1 after pinning **both** (determinant `3=0 mod 3`). Consequently matroid-rank and general submodularity assertions for diagonal pinning require separately proved hypotheses.

## 5. Operator and precision separation

`L_0+B_S` is a *vertex-state* operator on `C₀`, not an operator on cycle chains in `C₁`. For a real-valued secondary **edge-state** model, a correctly typed operator is `Δ₁=d₂ d₂ᵀ+d₁ᵀd₁` on the **fixed full** `C₁(K;ℝ)`; an explicitly declared edge-local leader penalty `P_S` can be added there. Neither this real model nor the inclusion-map predicate implies the other. A normalized minimum Rayleigh quotient over representatives is not automatically attained by the ordinary harmonic representative; any such claim needs an independent optimization argument. Do not use `Δ₁(U(S))` against a representative `z∈C₁(K)` without an explicit projection and changed domain.

Over `F_p`, ranks/solvability and finite transition reachability replace real spectral or damping claims. Over `ℤ/p^m`, module-image membership is an **exact finite-ring** question but requires valuation-aware elimination/Smith invariants; this field Gaussian eliminator must **not** be used on nonunits. Finite precision does not by itself certify a `ℤ_p` assertion.

For a `p`-adic invertible system matrix `A_S`, the algebraic rank-one identity is

```
det(A_S + b e_v e_vᵀ) = det(A_S) (1 + b (A_S⁻¹)_(vv)).
```

If `x=b(A_S⁻¹)_(vv)`, then `ν_p(1+x)=0` if `ν_p(x)>0`; equals `ν_p(x)` if `ν_p(x)<0`; and for `ν_p(x)=0` cancellation at `x≡-1 mod p` may have arbitrarily high valuation. If `1+x=0`, the new determinant is zero and its valuation is `∞`. A finite-modulus observation of `0 mod p^m` gives only the bound `ν_p≥m`, not an exact valuation.

## 6. Verification and next milestones

CI compiles `tests/mojo/test_leader_coverage.mojo` using the pinned upstream finite-math-kernels Mojo. Its exact regression cases over `F_7` and `F_13` exercise: an unfilled square cycle; a pin that covers its nonzero class; a filled square whose boundary is **zero homology** and therefore must remain in the image; rejection of a noncycle; and rejection of `d₁d₂≠0`.

Open obligations: formalize the inclusion-image theorem in Lean, add independent Python differential and brute-force placement oracle, verify arbitrary cochains/alternating representative witnesses, then implement a bounded exact `k`-leader optimizer with explicit reachability/control checks. Geometric 2-cell certificates and finite-field finite-state dynamics remain independent prerequisites, not inferred results.
