# Finite Vicsek and Kuramoto-inspired models (reference stage)

These are **structural analogues**, not discretizations claiming identical real-valued dynamics.

## Modal finite Vicsek

State: affine positions x_i in K² and oriented headings u_i with Q_blue(u_i)=1.
The geometric neighborhood is an explicit conjunction of configured blue/red/green quadrance membership predicates. Self is always included in the observation multiset. Let n_i(v) count neighbors carrying exact oriented heading v.

A unique most frequent observed heading is selected; in every tie the agent retains its existing heading. This is a finite combinatorial decision, not an argmin of field scalars. Because ties retain the old vector, the rule commutes with simultaneous blue rotations when its neighborhood predicate is blue-rotation invariant. Arbitrary red/green predicates can break blue-rotational equivariance.

Optional supplied unit rotors η_i rotate the selected heading exactly; no Gaussian distribution or unprovided probability law is assumed. Positions then advance as x_i⁺=x_i+ν u_i⁺. Without noise, a unanimously aligned swarm retains its headings and moves rigidly. Tie preservation also retains polar orientation; [u] and [-u] are not conflated.

This mode-count model does **not** assert preservation of the angular averaging behavior, continuous critical exponents, or density/phase transitions of the original Vicsek model. The finite behavior is available for exact orbit-census investigation.

## Finite Kuramoto phase group

Each phase is an oriented blue-unit vector u_i on the finite algebraic unit conic. The phase multiplication

    (a,b) * (c,d) = (ac-bd, ad+bc)

is an exact finite abelian group operation; its inverse is (a,-b). This is an algebraic multiplication *inside K²*, not complex-number arithmetic over C. Relative phase u_i^-1*u_j retains antipodal information lost by spread.

Given weighted interaction matrix W with diagonal 0, natural rotor ω_i, coupling κ, and an optional lag rotor ℓ, define

    t_i = κ sum_(j != i) W_ij det(u_i, ℓ*u_j)
    u_i⁺ = ω_i * R_Cayley(t_i) * u_i

where R_Cayley is the existing exact rational rotation with a documented -I pole policy. No real phases, sine, differential equations, or analytic OA manifold are imported.

Properties:
- Q_blue(u_i⁺)=1 for valid initial states and rotors.
- All identical phases remain identical under common natural rotation when lag=identity, regardless of W.
- With κ=0 and common ω_i, each relative rotor u_i^-1*u_j stays constant.
- Opposite phases have zero determinant coupling at zero lag; anti-phase configurations can remain stationary (unlike a universal consensus guarantee).
- A nontrivial lag with unequal row sums can break a synchronous state.
- Deterministic maps on the finite phase state space eventually enter periodic cycles.

The exact coherence statistic counts unordered pairs with **identically oriented headings**, not a potentially cancelling finite-field sum. Integer counts are a combinatorial observable; no field order is assumed.

## Verification and limits

`python -m unittest discover -s . -v` runs the finite-model tests across prime and extension fields, checks supplied noise, neighborhood masks, equivariance, anti-phase stationary states, rotor preservation, relative phase, and an exhaustive four-state oscillator orbit.

Next: canonical Mojo geometry pin from `finite-math-kernels` when upstream tests pass; Lean specifications for guarded geometry and quotient consensus; explicit correspondence/non-equivalence tests against selected classical formulas.
