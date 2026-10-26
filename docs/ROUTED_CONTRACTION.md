# Finite positive-overlap routes and rational contraction

The direct-pair certificate in `OVERLAP_CONTRACTION.md` gives only rate one
when some original-agent pairs have no common update row. A finite routing
certificate can still give a rate below one if positive-overlap edges connect
every pair. This extension supplies explicit route witnesses and a conservative
rational estimate, without an analytic or eventual-consensus argument.

## Finite certificate

For a nonempty finite population of size `N`, retain the rational matrix `P`
with nonnegative entries and both row and column sums one. Its column overlap is

\[
C_{jk}=\sum_i P_{ij}P_{ik}.
\]

A certificate supplies `0 < η ≤ 1`, a positive integer budget `L`, and for
every ordered pair `j,k` a finite route of length at most `L` from `j` to `k`.
Every route vertex must lie in the population and every used edge must satisfy
`η ≤ C_ab`. Zero-length self-routes are allowed. A singleton uses `L=1`, so the
rate denominator remains positive even though its actual routes have length zero.

`ChromoswarmRoutes.Routes` formalizes exactly these finite prefixes. A function
on natural indices represents each route, but only indices up to its explicitly
bounded finite length are used. No infinite sum or limiting process occurs.

Set

\[
\mu=\frac{\eta}{N L^2},\qquad r=1-\mu.
\]

The checked certificate gives `0 < μ ≤ 1` and `0 ≤ r < 1`, and Lean proves

\[
V(Pv)\le r V(v),\qquad V(P^k v)\le r^k V(v)
\]

for each finite natural horizon `k`. It also proves that one-step variance
descent is strict **if and only if** the original planar velocities are not
all equal, under this routed-support certificate.

## Algebraic proof and conservative constants

`formal/general/ChromoswarmRoutes.lean` imports the accepted exact loss and
pairwise-variance results. The new proof uses only finite ordered rational
algebra:

1. A telescoping sum and the finite sum-of-squares inequality give
   `Q_b(v_start−v_end) ≤ l Σ_edge Q_b(Δv)` on a route of length `l`.
2. Each used edge obeys `η Q_b(Δv) ≤ 2 loss`, because its nonnegative ordered
   overlap term is part of the exact loss sum.
3. Hence `η Q_b(v_j−v_k) ≤ L² (2 loss)` for every pair.
4. Sum over all pairs and use `Σ_j,k Q_b(v_j−v_k)=2 N V(v)`. Cancelling the
   positive finite factors yields `μ V(v) ≤ loss`, hence the rate above.
5. Induction gives the finite-horizon estimate. The separate positivity lemma
   identifies positive variance exactly with the existence of unequal velocities.

The bound deliberately overcounts route use and does not claim an optimal
constant, a spectral gap formula, a necessary condition for arbitrary
time-varying systems, or a characterization of exact finite-time consensus.
Row/column normalization, nonnegativity, route membership, overlap threshold
and positive denominator guards remain explicit.

`routes_propagate` separately proves that any value constant on guarded edges
is constant along every certified route. Lean uses it to refute route existence
for a swap and for independently averaged blocks, for **every** positive `η`
and finite budget. Another Lean control refutes a unit route budget between
opposite vertices of the four-cycle fixture.

## Executable evidence

`reference/rational_routes.py` validates and snapshots the operator, builds
deterministic shortest paths by finite breadth-first search, and returns exact
`Fraction` coefficients. A caller may supply paths, a threshold or a budget;
all are checked without silently weakening the supplied conditions. Routes
are copied into immutable tuples. Disconnected support, absent or insufficient
edges, bad endpoints, out-of-population vertices, undersized budgets, invalid
weights and invalid horizons are rejected.

| Fixture | Direct rate | Routed rate | Actual finite observation |
|---|---:|---:|---|
| Four-cycle half averaging | 1 | 63/64 | Variance 2 becomes 1/4 after two steps |
| Four-cycle thirds averaging | 1 | 71/72 | A rational non-consensus state remains non-consensus at step two |
| Five-cycle half averaging | 1 | 79/80 | Variance 28/5 becomes 49/40 after two steps |
| Two-agent complete averaging | 0 | 3/4 | Variance 2 becomes 0 after one step |
| Singleton | 0 | 0 | Variance remains zero |
| Four-cycle consensus state | 1 | 63/64 | Variance remains zero |

The complete-averaging example shows that the direct certificate can be much
sharper. The routed estimate complements it. Positive residual variance in the
cycle examples prevents confusing this bound with exact consensus at the
tested horizon.

Six fixed records in `conformance/rational_routes_Q_v1.json` quote every
finite route, exact coefficient, rate and expected finite variance. The renderer
`tools/route_vectors.py` emits ordinary Lean proofs checking every route edge,
endpoint, membership and length, as well as the exact values and applications
of the general finite-horizon theorem. The renderer does not establish
connectivity by assertion. Independent Python replay checks these witnesses,
the rejection controls and 192 sparse cyclic trajectories through horizons
zero to two (sizes 3–6 and three rational weights).

The general Lean gate checks all three vector renderers, the independent exact
tests, and the new root with all prior regression imports. Existing finite Lean
and pinned canonical Mojo acceptance lanes remain active. This reference code
does not extend the production Mojo API or establish Lean-to-program refinement.
Eventual consensus and variable-matrix connectivity criteria remain separate
obligations; no real limits or classical flocking convergence is claimed.
