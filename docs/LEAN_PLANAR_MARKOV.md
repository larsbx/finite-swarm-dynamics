# Formally checked planar rational consensus and finite Markov semantics

The prior Jensen theorem applies to arbitrary agent sets and scalar rational velocities. This module composes its scalar results into a blue-quadrance planar variance theorem with no restriction on agent count.

**Planar rational update**: each coordinate of each oriented velocity is updated by the same matrix P. If P has both row and column sums one and nonnegative rational entries, then exact blue disagreement variance never increases. Column unitality also preserves the two exact coordinate sums and arithmetic means. The proof does not use ℝ, limits, positivity over finite fields, or an unproved contraction theorem.

**Finite rational Markov update**: probability vectors advance as μP with nonnegative rational entries and row sums one. The formally checked transition preserves both nonnegativity and total mass one. Unlike the consensus update Pv, it requires no column sums: vector orientation matters, and accidental matrix-transposition is not allowed.

This extension remains inside the pinned Mathlib companion and imports the arbitrary-N Jensen library. The previous finite-field and compiled Mojo checks remain independent. This is *weak* variance nonincrease, not an assertion of eventual consensus. A permutation matrix can preserve variance exactly.

`ChromoswarmStrict.lean` now extends this weak theorem with exact planar loss, a necessary-and-sufficient one-step strictness criterion and a separate equality characterization. See [strict variance](STRICT_VARIANCE.md). The Markov convention and hypotheses are unchanged.
