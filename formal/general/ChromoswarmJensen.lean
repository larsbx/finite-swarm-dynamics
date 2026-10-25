import Mathlib

/-!
# Exact finite N-agent Jensen and variance inequalities over ℚ

The index set is an arbitrary Finset. The proof assumes separate row/column
unitality and nonnegative weights. No probability or asymptotic hypotheses are
silently inferred from algebraic row sums.
-/
namespace ChromoswarmJensen

variable {ι : Type*} [DecidableEq ι]

/-- Sum of weights times the exact displacement from a center. -/
def weightedMean (s : Finset ι) (w v : ι → ℚ) : ℚ :=
  ∑ j ∈ s, w j * v j

/-- Exact Jensen gap identity for any rational weights summing to one.
    Positivity is not needed for the *equality*. -/
theorem weighted_square_identity
    (s : Finset ι) (w v : ι → ℚ)
    (hw : (∑ j ∈ s, w j) = 1) :
    (∑ j ∈ s, w j * v j ^ 2) -
      (weightedMean s w v) ^ 2 =
      ∑ j ∈ s, w j * (v j - weightedMean s w v) ^ 2 := by
  let m : ℚ := weightedMean s w v
  have hm : (∑ j ∈ s, w j * v j) = m := rfl
  have hexpand :
      (∑ j ∈ s, w j * (v j - m) ^ 2) =
      (∑ j ∈ s, w j * v j ^ 2) -
          2 * m * (∑ j ∈ s, w j * v j) +
          m ^ 2 * (∑ j ∈ s, w j) := by
    calc
      (∑ j ∈ s, w j * (v j - m) ^ 2) =
          ∑ j ∈ s, (w j * v j ^ 2 - (2 * m) * (w j * v j) +
              m ^ 2 * w j) := by
            apply Finset.sum_congr rfl
            intro j _
            ring
      _ = _ := by
        simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib]
        rw [← Finset.mul_sum, ← Finset.mul_sum]
  have hcenter :
      (∑ j ∈ s, w j * (v j - m) ^ 2) =
        (∑ j ∈ s, w j * v j ^ 2) - m ^ 2 := by
    rw [hexpand, hm, hw]
    ring
  change (∑ j ∈ s, w j * v j ^ 2) - m ^ 2 =
    ∑ j ∈ s, w j * (v j - m) ^ 2
  exact hcenter.symm

/-- Finite rational Jensen inequality, with the *separate* positivity guard. -/
theorem weighted_square_le
    (s : Finset ι) (w v : ι → ℚ)
    (hw : (∑ j ∈ s, w j) = 1)
    (hn : ∀ j ∈ s, 0 ≤ w j) :
    (weightedMean s w v) ^ 2 ≤ ∑ j ∈ s, w j * v j ^ 2 := by
  have heq := weighted_square_identity s w v hw
  have hpos : 0 ≤ ∑ j ∈ s, w j * (v j - weightedMean s w v) ^ 2 := by
    apply Finset.sum_nonneg
    intro j hj
    exact mul_nonneg (hn j hj) (sq_nonneg _)
  linarith

/-- A row-unital exact rational linear update on an arbitrary finite index set. -/
def apply (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ) (i : ι) : ℚ :=
  ∑ j ∈ s, P i j * v j

/-- Exact conservation of the total scalar velocity requires column sums. -/
theorem total_preserved
    (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ)
    (hcol : ∀ j ∈ s, (∑ i ∈ s, P i j) = 1) :
    (∑ i ∈ s, apply s P v i) = ∑ j ∈ s, v j := by
  dsimp [apply]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j hj
  calc
    (∑ i ∈ s, P i j * v j) = (∑ i ∈ s, P i j) * v j := by
      simp only [Finset.sum_mul]
    _ = v j := by rw [hcol j hj]; ring

/-- The centered mean after one row-unital step equals an updated
    weighted mean of the old centered data. -/
theorem centered_apply
    (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ) (c : ℚ)
    (i : ι) (hrow : (∑ j ∈ s, P i j) = 1) :
    apply s P v i - c =
      ∑ j ∈ s, P i j * (v j - c) := by
  dsimp [apply]
  calc
    (∑ j ∈ s, P i j * v j) - c =
        (∑ j ∈ s, P i j * v j) -
          (∑ j ∈ s, P i j) * c := by
            rw [hrow]
            ring
    _ = (∑ j ∈ s, P i j * v j) -
          (∑ j ∈ s, P i j * c) := by
            simp only [Finset.sum_mul]
    _ = ∑ j ∈ s, P i j * (v j - c) := by
            rw [← Finset.sum_sub_distrib]
            apply Finset.sum_congr rfl
            intro j _
            ring

/-- N-agent weak rational Lyapunov inequality around *any* common center.
    The column-unital and nonnegative hypotheses are not consequences of
    row-unitality. -/
theorem centered_energy_nonincrease
    (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ) (c : ℚ)
    (hrow : ∀ i ∈ s, (∑ j ∈ s, P i j) = 1)
    (hcol : ∀ j ∈ s, (∑ i ∈ s, P i j) = 1)
    (hnonneg : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j) :
    (∑ i ∈ s, (apply s P v i - c) ^ 2) ≤
        ∑ j ∈ s, (v j - c) ^ 2 := by
  have hterm (i : ι) (hi : i ∈ s) :
      (apply s P v i - c) ^ 2 ≤
        ∑ j ∈ s, P i j * (v j - c) ^ 2 := by
    rw [centered_apply s P v c i (hrow i hi)]
    exact weighted_square_le s (P i) (fun j => v j - c)
      (hrow i hi) (hnonneg i hi)
  calc
    (∑ i ∈ s, (apply s P v i - c) ^ 2) ≤
        ∑ i ∈ s, ∑ j ∈ s, P i j * (v j - c) ^ 2 := by
          apply Finset.sum_le_sum
          intro i hi
          exact hterm i hi
    _ = ∑ j ∈ s, ∑ i ∈ s, P i j * (v j - c) ^ 2 := by
          rw [Finset.sum_comm]
    _ = ∑ j ∈ s, (v j - c) ^ 2 := by
          apply Finset.sum_congr rfl
          intro j hj
          calc
            (∑ i ∈ s, P i j * (v j - c) ^ 2) =
                (∑ i ∈ s, P i j) * (v j - c) ^ 2 := by
                  simp only [Finset.sum_mul]
            _ = (v j - c) ^ 2 := by
                  rw [hcol j hj]
                  ring

/-- Genuine finite rational population variance (sum about arithmetic mean).
    Nonemptiness makes its rational mean interpretation explicit. -/
def variance (s : Finset ι) (v : ι → ℚ) : ℚ :=
  let m := (∑ i ∈ s, v i) / (s.card : ℚ)
  ∑ i ∈ s, (v i - m)^2

theorem variance_nonincrease
    (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ)
    (hn : s.Nonempty)
    (hrow : ∀ i ∈ s, (∑ j ∈ s, P i j) = 1)
    (hcol : ∀ j ∈ s, (∑ i ∈ s, P i j) = 1)
    (hnonneg : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j) :
    variance s (apply s P v) ≤ variance s v := by
  have htotal := total_preserved s P v hcol
  unfold variance
  simp only [htotal]
  exact centered_energy_nonincrease s P v
    ((∑ i ∈ s, v i) / (s.card : ℚ)) hrow hcol hnonneg

end ChromoswarmJensen
