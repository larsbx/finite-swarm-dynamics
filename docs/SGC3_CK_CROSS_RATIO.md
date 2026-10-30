# SGC-3: Algebraic Cayley–Klein cross-ratio bridge

**Dependency:** stacked on PR #30 (general-field quadrilateral and Stokes theorems);
PR #29's compiled Mojo geometry is already merged in `main`.

## Precise domain

Take a field `K` with `4 != 0` and a linearly independent pair of
nonisotropic directions `u,v`. Their independence makes `[u+t v]` a
projective coordinate, with `[u]↦0` and `[v]↦∞`. Write
`[u+t v]` with `[u]↦0` and `[v]↦∞`. Write

```
  Q(u+t v) = a + 2*b*t + c*t²
  a=Q(u), b=B(u,v), c=Q(v).
```

For the planar blue quadratic `Q(x,y)=x²+y²`, the new general-field
Gram certificate establishes

```
b² - a*c = -(u_x*v_y - u_y*v_x)².
```

Thus independent planar directions have nonzero discriminant: the two
absolute intersections are distinct over a splitting field, although
they need not lie in the base field. The repeated-root algebraic
extension is relevant outside this independent planar-blue locus
(e.g., other restricted quadratic configurations), not an additional
admissible blue-plane four-point configuration.

Both `a,c` must be nonzero. If the restricted quadratic has roots
`r,s` in a splitting field `K'`, then Vieta yields

```
 c*(r+s)=-2*b
 c*(r*s)=a
```

The two roots are automatically nonzero when `a,c!=0`.
For the specified cross-ratio convention, the parameter is
`rho=cr(0,∞;r,s)=r/s`. Swapping the absolute references interchanges
`r,s` and changes `rho` to its inverse.

For **distinct roots** `r≠s`, the module also derives both
Vieta relations directly from the two quadratic root equations
`a+2br+cr²=0` and `a+2bs+cs²=0`. It then proves the
regular CK identity without assuming Vieta separately. The repeated-root
algebraic extension uses explicit Vieta hypotheses instead.

The kernel-checked identity is

```
  (2 - (r/s + s/r))/4 = 1 - b²/(a*c).
```

It applies over any extension field containing the roots, in particular
finite quadratic extensions. For a nonsplit quadratic over a base field,
Galois conjugation exchanges the roots; the symmetric expression equals
the right-hand side and is therefore in the base field.

### Critical distinctions

- If `r != s`, this is the ordinary four-distinct-point CK
  cross-ratio realization of rational-trigonometric spread.
- If `r = s`, the same **algebraic expression** remains defined
  and is zero, but an ordinary cross-ratio based on *distinct*
  absolute points is not defined. Do not claim four-point
  admissibility at tangency.
- If either direction is isotropic (`a=0` or `c=0`) the spread
  denominator is invalid; this is not zero spread.
- No ordering, infinitesimals, analytic trigonometry or physical
  synchronization follows from the identity.
- The formal theorem assumes Vieta's two equations instead of
  constructing projective root schemes or proving a generic
  quadratic splits in every base field. Geometry-to-Vieta and
  projective choice of coordinate remain explicit interface
  obligations.

## Proof/test artifacts

- `formal/general/ChromoswarmCrossRatio.lean`: field-general
  blue-plane Gram discriminant, root exchange and spread formulas; `hfour` guards characteristic two.
- `formal/general/ChromoswarmCrossRatioVectors.lean`: small
  modular controls and a rational specialization; test root committed
  before the implementation.
- `formal/general/ChromoswarmAcceptance.lean`: independent checker
  recursively imports earlier exact routing and swarm cell certificates.
- `.github/workflows/lean-general.yml`: Lean build and independent
  kernel checker plus transitive axiom-allowlist audit of the SGC-3 theorem
  namespace (`propext`, `Classical.choice`, `Quot.sound` only).
- `test_cross_ratio_arithmetic.py`: independent exhaustive
  nonzero/distinct split roots and planar Gram identity over F3,F5,F7,F11,F13,
  tangent algebraic evaluation, non-split F9 Frobenius exchange and invalid guards.

### Scope of discharge

This packet proves a **field algebra** identity for a declared
cross-ratio coordinate and exact Vieta conditions; it does not by
itself provide a Mathlib-level scheme-theoretic cross-ratio definition
or universal executable Mojo-to-Lean refinement.

Follow-up: formalize the coordinate-independence / projective
cross-ratio interface and the verified emission of `∂₂` by the
Mojo quad-cell constructor.
