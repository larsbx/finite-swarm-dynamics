# Finite linear alignment and exact orbit-census contract

This is a **new finite model inspired by the linear alignment skeleton of Cucker–Smale**. It is not a reduction, discretization theorem, or proof of equivalence to real-valued flocking.

## Algebraic alignment

Let K = F_(p^k), and let P in M_N(K). Define algebraic row-stochasticity by

    P * 1_N = 1_N.

Here row-stochastic means **only** that every row sums to the scalar 1. Entries are not positive, and P is not a Markov probability kernel. Positivity, monotone energy loss, weighted average arguments and real-valued spectral contraction cannot be assumed.

With velocity vectors v_i in K² and affine positions x_i in K², the synchronous finite update is

    v_i(t+1) = sum_j P_ij v_j(t)
    x_i(t+1) = x_i(t) + nu*v_i(t+1)

for field scalar nu. Coupling from a directed weighted adjacency W with zero self-weights is

    P_ij = kappa W_ij     for i != j
    P_ii = 1 - kappa sum_{j != i} W_ij.

This is an exact finite analogue of the **formula shape**, not the continuous-time model's analytical meaning.

## Theorem — exact universal finite-time velocity consensus

For an algebraically row-stochastic P, define C=span{1_N} subset K^N.
Then the following are equivalent:

1. There exists m >= 0 such that P^m maps every initial scalar velocity vector to C.
2. P^m has identical rows for some m >= 0.
3. The induced linear operator on K^N/C is nilpotent.
4. P^(N-1) has identical rows.

Proof: P1_N=1_N, so C is invariant and the induced endomorphism bar(P) of the (N-1)-dimensional quotient is defined. Its m-th power vanishes exactly when image(P^m) is contained in C. A nilpotent endomorphism of dimension N-1 has nilpotency index at most N-1. A matrix with image contained in C has identical rows. Thus the least universal consensus time is an integer m in 0..N-1, or **no finite universal consensus exists**. This result is valid over any field. For N=1, m=0.

The reference implementation checks powers of P up to N-1, **without** interpreting eigenvalue magnitudes or contraction. The theorem concerns arbitrary scalar initial states; the two velocity coordinates evolve independently by the same P.

## Fixed-heading consequences

Once velocities become equal to a common v, they remain equal since P1_N=1_N. Subsequent steps translate every position by the same nu*v, preserving affine differences and all colored quadrances.

In characteristic p, common nonzero translation has exact period p on absolute positions, even over F_(p^k). When nu*v=0, the unanimous configuration is fixed. A general system may instead have non-consensus cycles and transients.

## Exact functional-graph census

For explicitly enumerated finite domain S and deterministic closed update F:S->S, the state-transition graph has outdegree 1. Each connected functional component has exactly one directed cycle and a finite predecessor basin.

`exact_census` counts every cycle, its length, the number of states in its full basin, and its largest incoming tail length. Its executable invariants are

    sum(basin_size) = |S|,
    basin_size >= period >= 1,
    max_transient >= 0.

Inputs are rejected if enumeration has duplicates, a transition exits the domain, or the declared size cap is exceeded. No capped search is called complete. Index order follows the caller-supplied enumeration, not any ordering of finite-field scalars.

The `ConsensusOperator.scalar_census` enumerates **scalar velocity vectors** in K^N, of cardinality |K|^N; it does not claim to enumerate full affine positions, 2D velocities, non-linear graph updates or stochastic choices.

## Exact small-field witnesses

- F_3 with P=[[0,1],[0,1]]: universal consensus time 1; 9 scalar states, 3 fixed-point cycles, 3-state basin each.
- F_3 with P=[[0,1],[1,0]]: no universal consensus; 9 scalar states, 3 fixed points and 3 two-cycles.
- Any K with P=[[0,1,0],[0,0,1],[0,0,1]]: universal consensus time 2.

## Proof status and re-use policy

The universal-consensus theorem above has a mathematical proof and finite test witnesses; it has **not** been checked in Lean. The production finite-graph SCC library is maintained in `larsbx/finite-math-kernels/kernel/finite_graph`; the Python census remains a narrow independent exact oracle. Planned follow-ups include a canonical Mojo implementation, pinned conformance tests, a Lean quotient-space theorem, and independent finite Vicsek and Kuramoto replacement models.
