import ChromoswarmStrict

/-!
# Rational overlap certificates and finite-horizon variance bounds

All bounds concern a nonempty finite population. A positive overlap lower
bound is a sufficient, computable condition, not a characterization of all
contracting matrices. No limiting or eventual-consensus assertion is made.
-/
namespace ChromoswarmContraction

open ChromoswarmJensen ChromoswarmPlanar ChromoswarmStrict

variable {ι : Type*} [DecidableEq ι]

/-- Scalar pairwise representation of finite variance, with a guarded mean. -/
theorem scalar_pairwise_variance (s : Finset ι) (v : ι → ℚ) (hn : s.Nonempty) :
    (∑ j ∈ s, ∑ k ∈ s, (v j - v k)^2) = 2 * (s.card : ℚ) * variance s v := by
  let n : ℚ := s.card
  have hcard : (s.card : ℚ) ≠ 0 := by exact_mod_cast hn.card_pos.ne'
  have hn0 : n ≠ 0 := hcard
  have hw : (∑ _j ∈ s, (1 / n : ℚ)) = 1 := by
    simp only [Finset.sum_const, nsmul_eq_mul]
    change n * (1 / n) = 1
    field_simp
  have hm : weightedMean s (fun _ => 1 / n) v = (∑ j ∈ s, v j) / n := by
    unfold weightedMean
    rw [← Finset.mul_sum]
    ring
  have h := row_pair_identity s (fun _ => 1 / n) v hw
  rw [weighted_square_identity s (fun _ => 1 / n) v hw, hm] at h
  have hpairs :
      (∑ j ∈ s, ∑ k ∈ s, (1 / n : ℚ) * (1 / n) * (v j - v k)^2) =
        (1 / n)^2 * (∑ j ∈ s, ∑ k ∈ s, (v j - v k)^2) := by
    simp only [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    apply Finset.sum_congr rfl
    intro k _
    ring
  have hvar : (∑ j ∈ s, (1 / n : ℚ) * (v j - (∑ k ∈ s, v k) / n)^2) =
      (1 / n) * variance s v := by
    unfold variance
    rw [← Finset.mul_sum]
  rw [hpairs, hvar] at h
  field_simp [hn0] at h
  change _ = 2 * n * variance s v
  nlinarith

/-- Exact ordered-pair formula for blue planar variance. -/
theorem blue_pairwise_variance (s : Finset ι) (v : ι → ℚ × ℚ) (hn : s.Nonempty) :
    (∑ j ∈ s, ∑ k ∈ s, blueDistance (v j) (v k)) =
      2 * (s.card : ℚ) * blueVariance s v := by
  have hx := scalar_pairwise_variance s (fun j => (v j).1) hn
  have hy := scalar_pairwise_variance s (fun j => (v j).2) hn
  unfold blueDistance blueVariance
  simp only [Finset.sum_add_distrib]
  linarith

/-- Column overlap: two old agents contribute to a common update row. -/
def overlap (s : Finset ι) (P : ι → ι → ℚ) (j k : ι) : ℚ :=
  ∑ i ∈ s, P i j * P i k

/-- Reindex the existing loss identity by old-agent pairs. -/
theorem pairLoss_overlap (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ) :
    pairLoss s P v =
      (∑ j ∈ s, ∑ k ∈ s, overlap s P j k * blueDistance (v j) (v k)) / 2 := by
  unfold pairLoss lossTerm overlap
  congr 1
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro k _
  exact (Finset.sum_mul ..).symm

/-- A common lower bound is needed only for distinct agent indices. -/
def overlapBound (s : Finset ι) (P : ι → ι → ℚ) (η : ℚ) : Prop :=
  ∀ j ∈ s, ∀ k ∈ s, j ≠ k → η ≤ overlap s P j k

theorem pairLoss_lower_bound (s : Finset ι) (P : ι → ι → ℚ)
    (v : ι → ℚ × ℚ) (η : ℚ) (hn : s.Nonempty)
    (hover : overlapBound s P η) :
    (s.card : ℚ) * η * blueVariance s v ≤ pairLoss s P v := by
  have hsum :
      (∑ j ∈ s, ∑ k ∈ s, η * blueDistance (v j) (v k)) ≤
        ∑ j ∈ s, ∑ k ∈ s, overlap s P j k * blueDistance (v j) (v k) := by
    apply Finset.sum_le_sum
    intro j hj
    apply Finset.sum_le_sum
    intro k hk
    by_cases heq : j = k
    · subst k
      simp [blueDistance]
    · exact mul_le_mul_of_nonneg_right (hover j hj k hk heq) (blueDistance_nonneg _ _)
  have hleft : (∑ j ∈ s, ∑ k ∈ s, η * blueDistance (v j) (v k)) =
      η * (2 * (s.card : ℚ) * blueVariance s v) := by
    simp_rw [← Finset.mul_sum]
    rw [blue_pairwise_variance s v hn]
  rw [hleft] at hsum
  rw [pairLoss_overlap]
  linarith

/-- State-independent one-step bound with explicit row/column hypotheses.
    The algebraic estimate itself does not need a sign assumption. -/
theorem blue_variance_overlap_bound (s : Finset ι) (P : ι → ι → ℚ)
    (v : ι → ℚ × ℚ) (η : ℚ) (hn : s.Nonempty)
    (hrow : ∀ i ∈ s, (∑ j ∈ s, P i j) = 1)
    (hcol : ∀ j ∈ s, (∑ i ∈ s, P i j) = 1)
    (hover : overlapBound s P η) :
    blueVariance s (applyVec s P v) ≤ (1 - (s.card : ℚ) * η) * blueVariance s v := by
  have hloss := blue_variance_loss s P v hn hrow hcol
  have hbound := pairLoss_lower_bound s P v η hn hover
  linarith

/-- Certificate hypotheses separately guard signs and the rational rate. -/
def Certified (s : Finset ι) (P : ι → ι → ℚ) (η : ℚ) : Prop :=
  (∀ i ∈ s, (∑ j ∈ s, P i j) = 1) ∧
  (∀ j ∈ s, (∑ i ∈ s, P i j) = 1) ∧
  (∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j) ∧
  0 ≤ η ∧ (s.card : ℚ) * η ≤ 1 ∧ overlapBound s P η

theorem certified_rate (s : Finset ι) (P : ι → ι → ℚ) (η : ℚ)
    (h : Certified s P η) :
    0 ≤ 1 - (s.card : ℚ) * η ∧ 1 - (s.card : ℚ) * η ≤ 1 := by
  have hn : (0 : ℚ) ≤ s.card := Nat.cast_nonneg _
  have hmul := mul_nonneg hn h.2.2.2.1
  constructor <;> linarith [h.2.2.2.2.1]

theorem certified_strict_rate (s : Finset ι) (P : ι → ι → ℚ) (η : ℚ)
    (hn : s.Nonempty) (h : Certified s P η) (hη : 0 < η) :
    0 ≤ 1 - (s.card : ℚ) * η ∧ 1 - (s.card : ℚ) * η < 1 := by
  have hnpos : (0 : ℚ) < s.card := by exact_mod_cast hn.card_pos
  have := mul_pos hnpos hη
  exact ⟨(certified_rate s P η h).1, by linarith⟩

/-- Positive overlap gives strict descent for any state of positive variance. -/
theorem certified_strict_descent (s : Finset ι) (P : ι → ι → ℚ)
    (v : ι → ℚ × ℚ) (η : ℚ) (hn : s.Nonempty)
    (h : Certified s P η) (hη : 0 < η) (hv : 0 < blueVariance s v) :
    blueVariance s (applyVec s P v) < blueVariance s v := by
  have hb := blue_variance_overlap_bound s P v η hn h.1 h.2.1 h.2.2.2.2.2
  have hr := (certified_strict_rate s P η hn h hη).2
  have hm := mul_lt_mul_of_pos_right hr hv
  linarith

/-- A finite recursive update; k is an arbitrary finite natural number. -/
def evolve (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ) : ℕ → ι → ℚ × ℚ
  | 0 => v
  | k + 1 => applyVec s P (evolve s P v k)

/-- Exact rational finite-horizon bound. Even η=0 is allowed (rate one). -/
theorem finite_horizon_bound (s : Finset ι) (P : ι → ι → ℚ)
    (v : ι → ℚ × ℚ) (η : ℚ) (hn : s.Nonempty)
    (h : Certified s P η) (k : ℕ) :
    blueVariance s (evolve s P v k) ≤
      (1 - (s.card : ℚ) * η)^k * blueVariance s v := by
  induction k with
  | zero => simp [evolve]
  | succ k ih =>
    have hstep := blue_variance_overlap_bound s P (evolve s P v k) η hn h.1 h.2.1 h.2.2.2.2.2
    have hr := (certified_rate s P η h).1
    calc
      _ ≤ (1 - (s.card : ℚ) * η) * blueVariance s (evolve s P v k) := hstep
      _ ≤ (1 - (s.card : ℚ) * η) *
          ((1 - (s.card : ℚ) * η)^k * blueVariance s v) := mul_le_mul_of_nonneg_left ih hr
      _ = _ := by rw [pow_succ]; ring

end ChromoswarmContraction
