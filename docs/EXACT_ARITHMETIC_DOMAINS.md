# First-class exact arithmetic: ℤ, ℚ, and finite fields

**Status:** normative architecture; compiled rational geometry and linear alignment are tested through the canonical Mojo `QField` implementation, while `reference/rational_swarm.py` is a separate exact Python oracle. This document supersedes any interpretation that finite fields are the exclusive arithmetic substrate. Earlier finite-field model specifications remain valid within their own declared domains.

## 1. Domain taxonomy and capabilities

| Domain | Role | Mathematical structure | Order | Division | Dynamics semantics |
| --- | --- | --- | --- | --- | --- |
| ℤ | Canonical integral coordinates, lattices, determinants, exact certificates and counts | Integral domain/ring | Yes | Partial (only exact divisibility) | Integral updates; integrality must be preserved |
| ℚ | Geometry, exact weighted averages, rational probabilities, projective transformations, inequality reasoning | Ordered field | Yes | Every nonzero scalar | Exact ordered discrete dynamics, no completeness assumed |
| Fₚ and F_(p^k) | Modular reduction, algebraic invariants, finite transition systems, exhaustive orbit analysis | Finite fields | **No field-compatible order** | Every nonzero scalar | Eventual periodicity and finite reachability |

No field of characteristic 2 satisfies the ordinary blue/red/green polarization contracts used here. `F_p` here refers to an odd prime and explicit extension-field presentations may use `F_(p^k)`. ℤ is not passed into a field-only kernel unless a valid localization/coercion into ℚ or another specified field has been made.

The engine should use **capability-driven interfaces**, not one ad hoc common scalar: `ExactRing` for polynomial identities and incidence without division; `ExactField` for guarded spread/ratios and rotors; `OrderedExactField` for inequalities, constrained optimization and Lyapunov certificates; `FiniteEnumerableField` for exhaustive orbit tools. These are design roles, not claims that all four Mojo traits exist today. The reusable `Q`, `QField`, `FpField`, projective rotor and chromogeometric functions already exist upstream in `larsbx/finite-math-kernels`; keep domain-neutral kernels there.

## 2. Shared geometry and partiality

Over ℚ (or odd-characteristic fields where appropriate), define planar chromatic quadrances

    Q_b(x,y)=x²+y²,   Q_r(x,y)=x²−y²,   Q_g(x,y)=2xy.

The polar bilinear forms are `b_c(u,v)=(Q_c(u+v)-Q_c(u)-Q_c(v))/2`, and the guarded spread is

    s_c([u],[v]) = 1 - b_c(u,v)²/(Q_c(u)Q_c(v)).

A zero denominator is undefined, never `0`. All three chromatic identities, Gram determinants and quadrea relations are algebraically exact. Projective direction `[u]` identifies `u` and `-u`; a velocity or oriented phase **does not**.

For blue ℚ quadrance, `Q_b(u)≥0` and `Q_b(u)=0 ↔ u=0` (sum of rational squares). Red and green have nonzero null vectors even over ℚ, so a red/green "zero quadrance" cannot be interpreted as a collision or Euclidean zero distance. All signed-red/green inequalities are legitimate comparisons of algebraic observables, **not** automatically radial distance comparisons.

A rational Cayley parameter `t∈ℚ` has `1+t²>0`, so rational rotations

    c=(1−t²)/(1+t²),    s=2t/(1+t²),    R=[[c,−s],[s,c]]

have no finite rational parameter poles. The exceptional half-turn `R=−I` is represented explicitly; every rational unit-circle heading is accessible by the conic parametrization with this exception. A general rational vector cannot always be normalized to quadrance 1 within ℚ because its blue quadrance need not have a rational square root. Positions are affine, not normalized projective directions.

## 3. Ordered exact rational consensus

For an `N×N` matrix `P∈Mat_N(ℚ)`, the algebraic requirement `P·1=1` only preserves unanimity. **Convex consensus** adds `P_ij≥0`. Mass/mean preservation requires the **separate** left-eigenvector condition `1ᵀP=1ᵀ`, not merely row sums.

Discrete dynamics:

    v_i⁺ = Σ_j P_ij v_j,
    x_i⁺ = x_i + ν v_i⁺,   ν∈ℚ.

Over ℚ, averaging by `1/N` is always legal for `N>0`. Fractions can grow, but results remain exact as long as computation is completed; a resource cap may return `inconclusive`, never certify a theorem on a truncated search.

For the two-agent symmetric rational matrix `P=[[1−a,a],[a,1−a]]`, define disagreement energy

    E(v₁,v₂) = Q_b(v₁−v₂).

An exact identity gives

    E(Pv) = (1−2a)² E(v).

For `0≤a≤1`, `0≤(1−2a)²≤1` and `E(Pv)≤E(v)`. At `a=1/4`, `E(Pv)=E(v)/4` and unequal rational initial velocities approach but do not reach exact consensus in a finite number of steps. At `a=3/2`, `E(Pv)=4E(v)`: a matrix with rows summing to 1 is not necessarily dissipative. Exact rational inequalities support a genuine discrete Lyapunov proof, not a claim about continuous ODE or PDE regularity.

## 4. Probabilities and interaction predicates

A finite choice set Ω with `m` favorable events among `n>0` outcomes gives an exact rational probability `m/n`. Real-valued Gaussian noise or stochastic calculus are not introduced by this definition. A probability kernel has rational, **nonnegative** weights whose rows sum to 1; unlike an arbitrary finite-field row-unital operator, this is an actual Markov transition kernel.

An ordered blue-distance neighborhood may use `Q_b(x_i−x_j)≤r²` for `r²∈ℚ_{≥0}`. Signed red/green interval guards, rational comparisons and chromatic set predicates are independently configured. Finite-field analogues instead use explicit membership predicates; "≤" must not be silently transported modulo p.

## 5. Precise interoperability and forbidden inferences

- `ℤ→ℚ` is a canonical injective order-preserving ring map.
- `ℤ→Fₚ` is a total ring homomorphism; it is generally not injective and does not preserve integer inequalities.
- **There is no total field homomorphism `ℚ→Fₚ`.** For each odd prime p, reduction is defined only on the localization `ℤ_(p) = {a/b∈ℚ : p ∤ b}`, with `redₚ(a/b) = (a mod p)(b mod p)⁻¹`. A rational expression with a denominator divisible by p must be rejected for that reduction, even when it was perfectly defined in ℚ.
- Rational polynomial identities descend to supported modular reductions after their coefficients and all inversions satisfy the relevant guard conditions; ordered inequalities, positivity, radii, and analytic asymptotics **do not** descend. A rationally defined spread may become undefined modulo p because its quadrance denominator reduces to zero.
- Exact `ℚ` dynamics do not imply completeness, compactness, real-valued metric limits, PDE weak solutions, stochastic Brownian convergence, or equivalence to classical Cucker–Smale/Vicsek/Kuramoto. Classical correspondence claims require separately stated theorems.

## 6. Consumer and verification contracts

- **Upstream authoritative Mojo:** `finite-math-kernels/kernel/finite_exact/{rat_q,field,fp}.mojo`, `chromogeometry/chromatic.mojo`, and `projective_limits/rotor.mojo`.
- **Consumer compiled models:** `finite-swarm-dynamics/kernel/swarm_models/linear_alignment.mojo` and the other model-specific Mojo modules. Run both `QField` and finite-field specializations where model contracts permit.
- **Independent exact Python:** `reference/rational_swarm.py`, built from stdlib `fractions.Fraction`, with explicit refusal of floats and undefined denominators.
- **Tests:** guarded chromatic spreads, blue exact radius predicates, rational rotations and exceptional half-turns, strict rational probability counts, ordered two-agent contraction and a signed counterexample, and partial reduction to odd prime fields.
- **Formal proof milestones:** universal chromatic polynomial identities, rational two-agent contraction over ordered fields, general finite-field quotient-nilpotence criterion, and model-by-model classical correspondence/noncorrespondence. Tests are not universal proofs.

**Architectural rule:** ℚ is a foundational mathematical domain on equal footing with ℤ and finite fields. Do not call it an approximation layer or force ordered rational dynamics through modular semantics.
