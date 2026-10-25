# N-agent exact rational Jensen and variance formalization

This companion defines an arbitrary `Finset ι` of agents and a rational matrix `P : ι → ι → ℚ`. No fixed agent count, float, continuum axiom, or numerical bound appears in the statements.

The formal scope separates four obligations:

1. **Row-unit exact identity:** for rational weights summing to one, the quadratic moment gap is an exact finite sum of nonnegative squares *if* the weights are nonnegative. The polynomial identity holds even for signed weights.
2. **Column sums and mass:** column-unitality separately gives exact preservation of the sum of scalar velocities, hence the arithmetic mean for any nonempty finite index set.
3. **One-step Jensen inequality:** nonnegative row weights allow exact squared-mean ≤ mean-square, with no real analysis.
4. **N-agent variance descent:** if P is row-unital, column-unital and entrywise nonnegative, finite rational variance about the exact arithmetic mean never increases.

The concrete scalar theorem applies coordinatewise to planar velocities, giving the blue two-coordinate sum of variances. These are **weak** finite-step Lyapunov inequalities: a permutation matrix preserves variance without mixing, and no asymptotic flocking theorem follows from one-step nonincrease.

All declarations compile in the pinned Mathlib companion and are independently kernel checked by the general-proof lane. Program equivalence against Python/Mojo is distinct; existing runtime rational Jensen checks remain CI-gated.
