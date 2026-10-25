# Exact rational N-agent variance and Markov certificates (RQV-1)

## Algebraic identity

Let \(N>0\), let \(P\in M_N(\mathbb Q)\) have row sums 1, and let each oriented velocity \(v_i\in\mathbb Q^2\). For every row \(i\), the purely polynomial Jensen equality is

\[
\sum_j P_{ij}Q_b(v_j) - Q_b\!\left(\sum_j P_{ij}v_j\right)
=\sum_{j<k}P_{ij}P_{ik}Q_b(v_j-v_k),
\]

where \(Q_b(x,y)=x^2+y^2\). This equality **does not** require positivity or column sums.

If additionally \(\sum_iP_{ij}=1\) for every column \(j\), summing over rows yields

\[
\sum_jQ_b(v_j)-\sum_iQ_b((Pv)_i)
=\sum_i\sum_{j<k}P_{ij}P_{ik}Q_b(v_j-v_k).
\]

The exact arithmetic mean \(\bar v=N^{-1}\sum_jv_j\) is invariant under a doubly unital matrix. Therefore the same identity holds for the finite rational disagreement/variance potential \(V(v)=\sum_iQ_b(v_i-\bar v)\):

\[
\boxed{V(v)-V(Pv)=\sum_i\sum_{j<k}P_{ij}P_{ik}Q_b(v_j-v_k).}
\]

This is a finite polynomial equality, not a limiting assertion.

## Ordered certificate

If all rational weights are nonnegative, every term on the right is nonnegative because \(Q_b\) is a sum of rational squares. Thus

\[
V(Pv)\le V(v).
\]

This one-step weak Lyapunov inequality does **not** prove strict contraction, a uniform decay constant, asymptotic consensus, or Cucker–Smale's continuum flocking statements. A permutation matrix is a convex doubly stochastic counterexample to strict descent: \(V(Pv)=V(v)\).

The column-sum condition is independent of the row-sum condition. A merely row-unital matrix does not preserve arbitrary population means or certify the above global variance equality. A signed doubly unital matrix satisfies the polynomial identity but can increase variance: \(P=[[-1/2,3/2],[3/2,-1/2]]\) multiplies two-agent disagreement energy by 4.

## Implementation boundaries

- `reference/rational_variance.py`: independent exact Python `Fraction` oracle; N-agent finite Jensen witness, mean/column-sum checks, exact variance certificate, and a separate true rational Markov transition operator whose rows consist of nonnegative probabilities summing to one.
- `kernel/swarm_models/rational_variance.mojo`: compiled domain-specific consumer of the **canonical** `QField`, `Q`, `ChromoVec2`, and the existing field-generic alignment update. It fails closed on invalid row sums, dimensions, and rejected rational inputs. It never promotes a signed or non-column-unital matrix to a nonincrease certificate.
- `test_rational_variance.py` and `tests/mojo/test_rational_variance.mojo`: exact three-agent convex averaging, signed growth counterexample, non-column-unital refutation, denominator and dimension rejection, permutation equality, and rational Markov conservation. The Mojo test compiles using the upstream pinned toolchain.

**Status of proof:** The displayed identity has a standard direct algebraic proof by expanding the square and collecting pairs. The independent implementations verify the identity exactly for their tested inputs; this PR does **not** claim a general theorem checked by Lean. That is a separate formal milestone.

## Next general formalization

A Lean proof should quantify over an arbitrary finite agent index set and velocities in a quadratic module over an ordered field (specializing to \(\mathbb Q\)); it should express the rowwise identity without an ordering assumption, then use nonnegative weights and positivity of blue quadrance for the inequality. The finite-field specialization retains the polynomial identity but not the inequality.
