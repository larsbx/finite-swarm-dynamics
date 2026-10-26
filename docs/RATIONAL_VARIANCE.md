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

This one-step weak Lyapunov inequality alone does **not** prove strict descent, a uniform decay constant, asymptotic consensus, or Cucker–Smale's continuum flocking statements. A permutation matrix is a convex doubly stochastic counterexample to strict descent: \(V(Pv)=V(v)\).

The column-sum condition is independent of the row-sum condition. A merely row-unital matrix does not preserve arbitrary population means or certify the above global variance equality. A signed doubly unital matrix satisfies the polynomial identity but can increase variance: \(P=[[-1/2,3/2],[3/2,-1/2]]\) multiplies two-agent disagreement energy by 4.

## Implementation boundaries

- `reference/rational_variance.py`: independent exact Python `Fraction` oracle; N-agent finite Jensen witness, mean/column-sum checks, exact variance certificate, and a separate true rational Markov transition operator whose rows consist of nonnegative probabilities summing to one.
- `kernel/swarm_models/rational_variance.mojo`: compiled domain-specific consumer of the **canonical** `QField`, `Q`, `ChromoVec2`, and the existing field-generic alignment update. It fails closed on invalid row sums, dimensions, and rejected rational inputs. It never promotes a signed or non-column-unital matrix to a nonincrease certificate.
- `test_rational_variance.py` and `tests/mojo/test_rational_variance.mojo`: exact three-agent convex averaging, signed growth counterexample, non-column-unital refutation, denominator and dimension rejection, permutation equality, and rational Markov conservation. The Mojo test compiles using the upstream pinned toolchain.

**Status of proof:** The arbitrary-finite-agent scalar Jensen and weak variance theorems are kernel checked in `formal/general/ChromoswarmJensen.lean`; `ChromoswarmPlanar.lean` establishes planar weak variance nonincrease and rational Markov conservation. `ChromoswarmStrict.lean` proves the row-pair identity, centered-energy loss, scalar variance loss and planar variance loss. It uses half the ordered pair sum, equivalent to the unordered-pair sum above, without requiring an order on the agent type. The identity needs row and column sums one, but no sign hypothesis. The nonempty finite set explicitly guards the rational population mean.

Under the additional nonnegative-weight hypothesis, `blue_variance_strict_iff` proves strict descent **if and only if** some row has positive weights on two distinct original planar velocities. Separately, `blue_variance_eq_iff` proves equality **if and only if** each row's positive support contains only one velocity value. Different rows may retain different velocities, so equality need not mean global consensus.

See [strictness specification and exact counterexamples](STRICT_VARIANCE.md). The fixed rational vectors are independently recomputed in Python and checked as Lean theorems; neither these tests nor the formal mathematical results establish executable Mojo/Lean program refinement. The subsequent [overlap contraction theorem](OVERLAP_CONTRACTION.md) supplies a sufficient uniform rational rate and finite-horizon bound under additional explicit overlap hypotheses. Eventual consensus remains a separate obligation. The finite-field polynomial analogue does not carry an ordered descent interpretation.
