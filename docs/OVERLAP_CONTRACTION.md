# Exact rational overlap contraction and finite-horizon bounds

The earlier strictness theorem depends on the current state. This extension
gives a **sufficient, matrix-dependent bound valid for every planar rational
state**, using an explicit overlap certificate. It does not characterize all
contracting matrices or establish eventual consensus.

## Computable hypothesis and rate

Let `s` be a nonempty finite agent set of size `N`, and `P` a rational matrix
with nonnegative entries and row and column sums one. Define the **column**
overlap of original agents `j,k` by

\[
C_{jk}=\sum_{i\in s}P_{ij}P_{ik}.
\]

The two columns share an update row, so the index orientation matters. This
is not a row-dot-product certificate. Supply a rational number `η` satisfying

\[
0\le\eta,\qquad N\eta\le1,\qquad
\eta\le C_{jk}\quad(j,k\in s,\ j\ne k).
\]

Then `r = 1 − Nη` is in `[0,1]`, and

\[
\boxed{V(Pv)\le r V(v).}
\]

For `η>0`, the rate is strictly below one; every state of positive variance
strictly descends. The bound also covers `η=0`, producing only weak descent.

The independent Python reference chooses
`η = min(1/N, min_{j<k} C_jk)` by default. Explicit supplied values are checked
and rejected if invalid, never silently reduced. A singleton uses `η=1/N=1`:
its off-diagonal condition is vacuous, its variance is zero and the rate is
zero. No empty population is admitted and no mean denominator is zero.

## Kernel-checked proof chain

`formal/general/ChromoswarmContraction.lean` imports the accepted strictness
module and proves:

1. `scalar_pairwise_variance` and `blue_pairwise_variance`:
   the ordered-pair distance sum equals `2 N V(v)`. The scalar proof reuses
   both the exact row-pair identity and the existing weighted-square identity
   with weights `1/N`, explicitly proving `N≠0`.
2. `pairLoss_overlap`: reindex the previously proved loss as
   `½ Σ_j,k C_jk Q_b(v_j−v_k)`.
3. `pairLoss_lower_bound`: use nonnegative blue quadrance and the pair bound
   to obtain `Nη V(v) ≤ loss`. Diagonal pairs have zero distance.
4. `blue_variance_overlap_bound`: combine this with the existing loss identity.
   This algebraic bound itself needs the two normalizations and the overlap
   lower bound, rather than a separate sign hypothesis. The `Certified`
   wrapper additionally enforces nonnegative weights and the rate range for
   the ordered consensus model and repeated-step estimate.
5. `certified_rate`, `certified_strict_rate`, `certified_strict_descent`:
   guard the rate and the positive-variance strictness conclusion.
6. `finite_horizon_bound`: for any finite natural number `k`, the recursively
   updated state obeys

   \[
   V(P^k v)\le (1-N\eta)^k V(v).
   \]

The finite-horizon proof is induction using a nonnegative multiplier. At
`k=0` the bound is exactly the original variance, including a zero rate.
It introduces no real scalars, analytic limits or asymptotic assumptions.

## Exact witnesses and limits of the certificate

| Operator / state | η | Rate | Finite observation |
|---|---:|---:|---|
| Two-agent complete averaging | 1/2 | 0 | Variance 2 becomes 0 in one step |
| Two-agent matrix `[[2/3,1/3],[1/3,2/3]]` | 4/9 | 1/9 | Variance 2 becomes 2/6561 after four steps |
| Three-agent cyclic half-weight averaging | 1/4 | 1/4 | Variance 16/3 becomes 1/12 after three steps |
| Two-agent swap | 0 | 1 | Positive variance 5/2 is preserved |
| Two constant independently averaged blocks | 0 | 1 | Positive variance 5 is preserved |
| Four-agent cyclic half-weight averaging | 0 | 1 | Fixture variance 2 decreases to 1/4 after two steps |

The last case shows that a zero minimum overlap does **not** imply absence of
strict descent. This certificate is sufficient; failure to obtain a positive
`η` is not a converse theorem. A connected-support/path-based rate would need
a separate proof. The thirds example retains positive variance at the tested
horizon, so its contraction estimate is not an exact finite-consensus result.

The nine fixed vectors also cover a singleton, a rational consensus state and
an asymmetric matrix with unequal column- and row-dot-product values.
Lean proves certificate validity, exact finite values and instantiates the
general finite-horizon theorem for each vector. Separate Lean examples reject
an overstated overlap, a negative rate, signed weights and missing columns.

## Executable and acceptance boundary

`reference/rational_contraction.py` is a research oracle using exact `Fraction`
arithmetic. Its immutable certificate snapshots and revalidates matrix rows;
signed weights, failed normalization, invalid overlap claims and negative or
nonintegral horizons are rejected. This is not a new production Mojo API or a
Lean-to-Mojo refinement result.

`conformance/rational_contraction_Q_v1.json` stores fixed rational expectations.
`tools/contraction_vectors.py` quotes those expectations into Lean, without
calculating them. `test_rational_contraction.py` independently replays them
using pairwise variance, compares with the centered-mean reference, and checks
180 exact convex combinations of three-agent permutations on five planar
states through horizons zero to three. These finite tests are regression
evidence; the Lean theorems supply the arbitrary-finite-population proof.

Run `python -m unittest discover -s . -v`, both vector-renderer `--check`
commands, and `lake build` in `formal/general`. The general Lean lane checks
the new root and retains all earlier strictness-vector imports for independent
kernel verification. Existing finite Lean and canonical Mojo lanes remain
active. Eventual consensus, exact finite-time consensus criteria and program
refinement remain separate obligations.
