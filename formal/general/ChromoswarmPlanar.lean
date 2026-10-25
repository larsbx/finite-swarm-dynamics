import ChromoswarmJensen
import Mathlib

/-!
# Exact planar variance and rational Markov conservation

This extends the arbitrary-N scalar Jensen theorem coordinatewise to
planar blue quadrance, and proves that a finite nonnegative rational
row-unital transition preserves probability mass. No analytic limits.
-/

namespace ChromoswarmPlanar

open ChromoswarmJensen

variable {ι : Type*} [DecidableEq ι]

def applyVec (s : Finset ι) (P : ι → ι → ℚ)
    (v : ι → ℚ × ℚ) (i : ι) : ℚ × ℚ :=
  (apply s P (fun j => (v j).1) i, apply s P (fun j => (v j).2) i)

/-- Finite blue variance is exactly the sum of coordinate variances. -/
def blueVariance (s : Finset ι) (v : ι → ℚ × ℚ) : ℚ :=
  variance s (fun i => (v i).1) + variance s (fun i => (v i).2)

/-- The rational planar velocity sum is preserved under column-unitality. -/
theorem planar_total_preserved
    (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ)
    (hcol : ∀ j ∈ s, (∑ i ∈ s, P i j) = 1) :
    (∑ i ∈ s, (applyVec s P v i).1,
      ∑ i ∈ s, (applyVec s P v i).2) =
    (∑ i ∈ s, (v i).1, ∑ i ∈ s, (v i).2) := by
  apply Prod.ext
  · exact total_preserved s P (fun i => (v i).1) hcol
  · exact total_preserved s P (fun i => (v i).2) hcol

/-- Arbitrary-N, planar, exact rational weak Lyapunov nonincrease. -/
theorem blue_variance_nonincrease
    (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ)
    (hn : s.Nonempty)
    (hrow : ∀ i ∈ s, (∑ j ∈ s, P i j) = 1)
    (hcol : ∀ j ∈ s, (∑ i ∈ s, P i j) = 1)
    (hp : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j) :
    blueVariance s (applyVec s P v) ≤ blueVariance s v := by
  have hx := variance_nonincrease s P (fun i => (v i).1)
    hn hrow hcol hp
  have hy := variance_nonincrease s P (fun i => (v i).2)
    hn hrow hcol hp
  change variance s (apply s P (fun j => (v j).1)) +
    variance s (apply s P (fun j => (v j).2)) ≤
    variance s (fun j => (v j).1) + variance s (fun j => (v j).2)
  exact add_le_add hx hy

/-- The row-oriented finite rational Markov convention:
    an initial probability mass μ_i moves along row P_i,j. -/
def markovAdvance (s : Finset ι) (P : ι → ι → ℚ)
    (μ : ι → ℚ) (j : ι) : ℚ :=
  ∑ i ∈ s, μ i * P i j

/-- Row-unitality, not column-unitality, preserves mass for μP. -/
theorem markov_total_preserved
    (s : Finset ι) (P : ι → ι → ℚ) (μ : ι → ℚ)
    (hrow : ∀ i ∈ s, (∑ j ∈ s, P i j) = 1) :
    (∑ j ∈ s, markovAdvance s P μ j) = ∑ i ∈ s, μ i := by
  dsimp [markovAdvance]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i hi
  calc
    (∑ j ∈ s, μ i * P i j) =
        μ i * (∑ j ∈ s, P i j) := by
          simp only [Finset.mul_sum]
    _ = μ i := by rw [hrow i hi]; ring

/-- Exact rational probabilities remain nonnegative under a Markov kernel. -/
theorem markov_nonnegative
    (s : Finset ι) (P : ι → ι → ℚ) (μ : ι → ℚ)
    (hm : ∀ i ∈ s, 0 ≤ μ i)
    (hp : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j) :
    ∀ j ∈ s, 0 ≤ markovAdvance s P μ j := by
  intro j hj
  dsimp [markovAdvance]
  apply Finset.sum_nonneg
  intro i hi
  exact mul_nonneg (hm i hi) (hp i hi j hj)

/-- A nonnegative rational distribution retains total mass one. -/
theorem markov_probability_preserved
    (s : Finset ι) (P : ι → ι → ℚ) (μ : ι → ℚ)
    (hrow : ∀ i ∈ s, (∑ j ∈ s, P i j) = 1)
    (hm : ∀ i ∈ s, 0 ≤ μ i)
    (hp : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j)
    (hunit : (∑ i ∈ s, μ i) = 1) :
    (∑ j ∈ s, markovAdvance s P μ j) = 1 ∧
      ∀ j ∈ s, 0 ≤ markovAdvance s P μ j := by
  constructor
  · rw [markov_total_preserved s P μ hrow]
    exact hunit
  · exact markov_nonnegative s P μ hm hp

end ChromoswarmPlanar
