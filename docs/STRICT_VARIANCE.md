# Exact one-step strict rational variance descent

For a finite nonempty agent set `s`, velocities `v : ι → ℚ × ℚ`, and rational
matrix `P`, use the existing synchronous update `applyVec s P v`. The potential
`blueVariance` is the **sum**, not average, of squared distances from the
arithmetic mean. Every mean denominator is a positive finite cardinality.

## Formal statements and dependencies

`formal/general/ChromoswarmStrict.lean` imports the existing scalar Jensen and
planar libraries. Its algebraic proofs proceed through:

1. `row_pair_identity`: expand a row's squared weighted mean. Only its sum-one
   hypothesis is needed; signed weights are allowed.
2. `centered_energy_loss`: sum the row identities about any common center,
   using column sums one to recover the original energy.
3. `variance_loss`: use `total_preserved` to identify the original and updated
   arithmetic means. Nonemptiness explicitly guards the denominator.
4. `blue_variance_loss`: add the two scalar identities, yielding

   \[
   V(v)-V(Pv)=\frac12\sum_{i,j,k\in s}
   P_{ij}P_{ik}\big((v_{j,x}-v_{k,x})^2+(v_{j,y}-v_{k,y})^2\big).
   \]

The ordered pair sum counts each unequal pair twice and includes zero diagonal
terms. It needs no ordering on the agent type. The identity requires row and
column sums one, independently; it does not require nonnegative entries.

With the **additional explicit hypothesis** `0 ≤ P i j` on `s × s`, each loss
term is nonnegative. Blue squared distance is positive exactly when its planar
arguments differ. Positivity of a finite nonnegative sum then gives both
directions of `blue_variance_strict_iff`:

\[
V(Pv)<V(v)\quad\Longleftrightarrow\quad
\exists i,j,k\in s:\ P_{ij}>0,\ P_{ik}>0,\ v_j\ne v_k.
\]

The separate `blue_variance_eq_iff` uses the existing planar weak-descent
theorem to establish

\[
V(Pv)=V(v)\quad\Longleftrightarrow\quad
\forall i,j,k\in s:\ (P_{ij}>0\land P_{ik}>0)\Rightarrow v_j=v_k.
\]

Equality means constant velocity **within each positive row support**. It need
not imply the same velocity across all rows or across the whole population.

## Exact regression and hypothesis boundaries

`conformance/strict_variance_Q_v1.json` fixes ten rational vectors.
`ChromoswarmStrictVectors.lean` proves their values and hypothesis flags with
ordinary proof-producing tactics. Its renderer only quotes those fixed
expectations. `test_strict_variance.py` independently recomputes variance by
pairwise squared distances, compares against the existing centered-mean
`Fraction` oracle, and checks an additional 729 two-agent rational cases.

| Case | Old variance | New variance | Pair loss | Interpretation |
|---|---:|---:|---:|---|
| Two-agent swap, velocities `(0,0),(2,1)` | 5/2 | 5/2 | 0 | All hypotheses hold; permutation equality |
| Averaging a consensus state | 0 | 0 | 0 | All hypotheses hold; no distinct supported velocities |
| Mixing only the second coordinate | 2 | 0 | 2 | All hypotheses hold; strict planar descent |
| Three-agent half-weight cycle | 16/3 | 4/3 | 4 | All hypotheses hold; strict descent |
| Two separately averaged constant blocks | 5 | 5 | 0 | All hypotheses hold; equality without consensus |
| Signed matrix `[[-1/2,3/2],[3/2,-1/2]]` | 2 | 8 | −6 | Both normalizations hold; nonnegativity fails |
| Row-unital matrix `[[1,0,0],[0,1,0],[0,3/4,1/4]]` | 1/2 | 19/32 | 3/64 | Nonnegative and mixes distinct velocities; column sums fail |
| Matrix `2I` | 1/2 | 2 | 0 | Both normalizations fail |

The last three rows are **outside the strictness/equality theorem's
hypotheses**, rather than equality counterexamples. The signed example retains
the algebraic loss identity. The missing-column example loses the global
variance identity itself: its positive pair witness cannot certify descent.
The dataset also includes the singleton and a fully rational nonintegral state.

## Acceptance and scope

Run `python -m unittest discover -s . -v` and
`python -m tools.strict_variance_vectors --check`. In `formal/general`, run
`lake build`. The general Lean workflow builds all libraries, checks vector
freshness and the independent rational tests, refuses proof bypasses and runs
the independent Lean kernel checker on `ChromoswarmStrictVectors` and its
imported strictness, planar and Jensen dependencies. Existing finite Lean and
pinned canonical Mojo acceptance lanes remain active.

Weak descent, state-dependent strict descent, uniform contraction and eventual
consensus are separate statements. This work establishes the first two and
the equality case. It supplies no uniform rational decay factor over all
states or time-varying matrices, and no eventual-consensus, real-limit,
asymptotic or classical flocking convergence theorem. It also does not claim
program refinement between the Lean model and the Mojo implementation.
