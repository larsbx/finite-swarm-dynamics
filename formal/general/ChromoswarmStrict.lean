import ChromoswarmPlanar

/-!
# Exact one-step planar variance loss over ℚ

Ordered pairs avoid choosing an ordering of the finite agent type. The loss
is half their sum. Identities allow signed weights; order conclusions require
nonnegativity separately. No uniform contraction or eventual consensus claim.
-/
namespace ChromoswarmStrict

open ChromoswarmJensen ChromoswarmPlanar

variable {ι : Type*} [DecidableEq ι]

/-- The scalar rowwise pair identity, with no sign assumption. -/
theorem row_pair_identity (s : Finset ι) (w v : ι → ℚ)
    (hw : (∑ j ∈ s, w j) = 1) :
    (∑ j ∈ s, ∑ k ∈ s, w j * w k * (v j - v k)^2) =
      2 * ((∑ j ∈ s, w j * v j^2) - (weightedMean s w v)^2) := by
  have hexpand (j : ι) :
      (∑ k ∈ s, w j * w k * (v j - v k)^2) =
        w j * v j^2 * (∑ k ∈ s, w k) -
        2 * (w j * v j) * (∑ k ∈ s, w k * v k) +
        w j * (∑ k ∈ s, w k * v k^2) := by
    calc
      _ = ∑ k ∈ s, (w j * v j^2 * w k -
          2 * (w j * v j) * (w k * v k) + w j * (w k * v k^2)) := by
        apply Finset.sum_congr rfl
        intro k _
        ring
      _ = _ := by simp only [Finset.sum_add_distrib,
        Finset.sum_sub_distrib, ← Finset.mul_sum]
  simp_rw [hexpand, hw]
  simp only [mul_one, Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.sum_mul, ← Finset.mul_sum, hw, one_mul, weightedMean]
  ring

/-- Loss around any common center. Column normalization is essential. -/
theorem centered_energy_loss (s : Finset ι) (P : ι → ι → ℚ)
    (v : ι → ℚ) (c : ℚ)
    (hrow : ∀ i ∈ s, (∑ j ∈ s, P i j) = 1)
    (hcol : ∀ j ∈ s, (∑ i ∈ s, P i j) = 1) :
    (∑ i ∈ s, (v i - c)^2) - (∑ i ∈ s, (apply s P v i - c)^2) =
      (∑ i ∈ s, ∑ j ∈ s, ∑ k ∈ s,
        P i j * P i k * (v j - v k)^2) / 2 := by
  have hr (i : ι) (hi : i ∈ s) :
      (∑ j ∈ s, ∑ k ∈ s, P i j * P i k * (v j - v k)^2) =
        2 * ((∑ j ∈ s, P i j * (v j - c)^2) -
          (apply s P v i - c)^2) := by
    have h := row_pair_identity s (P i) (fun j => v j - c) (hrow i hi)
    rw [centered_apply s P v c i (hrow i hi)]
    simpa only [sub_sub_sub_cancel_right, weightedMean] using h
  have hsum :
      (∑ i ∈ s, ∑ j ∈ s, P i j * (v j - c)^2) =
        ∑ j ∈ s, (v j - c)^2 := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro j hj
    rw [← Finset.sum_mul, hcol j hj, one_mul]
  have h := Finset.sum_congr rfl hr
  simp only [← Finset.mul_sum, Finset.sum_sub_distrib] at h
  rw [hsum] at h
  linarith

/-- Exact finite scalar variance loss, including signed doubly unital weights. -/
theorem variance_loss (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ)
    (hn : s.Nonempty)
    (hrow : ∀ i ∈ s, (∑ j ∈ s, P i j) = 1)
    (hcol : ∀ j ∈ s, (∑ i ∈ s, P i j) = 1) :
    variance s v - variance s (apply s P v) =
      (∑ i ∈ s, ∑ j ∈ s, ∑ k ∈ s,
        P i j * P i k * (v j - v k)^2) / 2 := by
  have _hcard : (s.card : ℚ) ≠ 0 := by exact_mod_cast hn.card_pos.ne'
  unfold variance
  rw [total_preserved s P v hcol]
  exact centered_energy_loss s P v _ hrow hcol

def blueDistance (u v : ℚ × ℚ) : ℚ :=
  (u.1 - v.1)^2 + (u.2 - v.2)^2

def lossTerm (P : ι → ι → ℚ) (v : ι → ℚ × ℚ) (i j k : ι) : ℚ :=
  P i j * P i k * blueDistance (v j) (v k)

def pairLoss (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ) : ℚ :=
  (∑ i ∈ s, ∑ j ∈ s, ∑ k ∈ s, lossTerm P v i j k) / 2

/-- Exact planar loss is the sum of the two scalar losses. -/
theorem blue_variance_loss (s : Finset ι) (P : ι → ι → ℚ)
    (v : ι → ℚ × ℚ) (hn : s.Nonempty)
    (hrow : ∀ i ∈ s, (∑ j ∈ s, P i j) = 1)
    (hcol : ∀ j ∈ s, (∑ i ∈ s, P i j) = 1) :
    blueVariance s v - blueVariance s (applyVec s P v) = pairLoss s P v := by
  have hx := variance_loss s P (fun j => (v j).1) hn hrow hcol
  have hy := variance_loss s P (fun j => (v j).2) hn hrow hcol
  unfold pairLoss lossTerm blueDistance
  simp only [mul_add, Finset.sum_add_distrib]
  change variance s (fun j => (v j).1) + variance s (fun j => (v j).2) -
    (variance s (apply s P (fun j => (v j).1)) +
      variance s (apply s P (fun j => (v j).2))) = _
  linarith

theorem blueDistance_nonneg (u v : ℚ × ℚ) : 0 ≤ blueDistance u v :=
  add_nonneg (sq_nonneg _) (sq_nonneg _)

theorem blueDistance_pos_iff (u v : ℚ × ℚ) : 0 < blueDistance u v ↔ u ≠ v := by
  constructor
  · intro h heq
    subst v
    simp [blueDistance] at h
  · intro h
    have hn := blueDistance_nonneg u v
    by_contra hnot
    have hz : blueDistance u v = 0 := le_antisymm (le_of_not_gt hnot) hn
    have hx := sq_nonneg (u.1 - v.1)
    have hy := sq_nonneg (u.2 - v.2)
    unfold blueDistance at hz
    have hux : u.1 = v.1 := by nlinarith
    have huy : u.2 = v.2 := by nlinarith
    exact h (Prod.ext hux huy)

theorem lossTerm_nonneg (P : ι → ι → ℚ) (v : ι → ℚ × ℚ) (i j k : ι)
    (hj : 0 ≤ P i j) (hk : 0 ≤ P i k) : 0 ≤ lossTerm P v i j k :=
  mul_nonneg (mul_nonneg hj hk) (blueDistance_nonneg _ _)

theorem lossTerm_pos_iff (P : ι → ι → ℚ) (v : ι → ℚ × ℚ) (i j k : ι)
    (hj : 0 ≤ P i j) (hk : 0 ≤ P i k) :
    0 < lossTerm P v i j k ↔ 0 < P i j ∧ 0 < P i k ∧ v j ≠ v k := by
  unfold lossTerm
  constructor
  · intro h
    have hpj : 0 < P i j := by
      by_contra hh
      have hz := le_antisymm (le_of_not_gt hh) hj
      simp [hz] at h
    have hpk : 0 < P i k := by
      by_contra hh
      have hz := le_antisymm (le_of_not_gt hh) hk
      simp [hz] at h
    have hd : 0 < blueDistance (v j) (v k) := by
      rcases mul_pos_iff.mp h with hh | hh
      · exact hh.2
      · linarith [mul_nonneg hj hk]
    exact ⟨hpj, hpk, (blueDistance_pos_iff _ _).mp hd⟩
  · rintro ⟨hpj, hpk, hne⟩
    exact mul_pos (mul_pos hpj hpk) ((blueDistance_pos_iff _ _).mpr hne)

/-- Some row mixes two distinct old velocities with positive weights. -/
def mixesDistinct (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ) : Prop :=
  ∃ i ∈ s, ∃ j ∈ s, ∃ k ∈ s, 0 < P i j ∧ 0 < P i k ∧ v j ≠ v k

theorem pairLoss_pos_iff (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ)
    (hp : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j) :
    0 < pairLoss s P v ↔ mixesDistinct s P v := by
  have ht (i) (hi : i ∈ s) (j) (hj : j ∈ s) (k) (hk : k ∈ s) :=
    lossTerm_nonneg P v i j k (hp i hi j hj) (hp i hi k hk)
  have hj (i) (hi : i ∈ s) (j) (hj : j ∈ s) := Finset.sum_nonneg (ht i hi j hj)
  have hi (i) (hi : i ∈ s) := Finset.sum_nonneg (hj i hi)
  unfold pairLoss mixesDistinct
  have hhalf (a : ℚ) : 0 < a / 2 ↔ 0 < a := by constructor <;> intro h <;> linarith
  rw [hhalf, Finset.sum_pos_iff_of_nonneg hi]
  apply exists_congr
  intro i
  apply and_congr_right
  intro his
  rw [Finset.sum_pos_iff_of_nonneg (hj i his)]
  apply exists_congr
  intro j
  apply and_congr_right
  intro hjs
  rw [Finset.sum_pos_iff_of_nonneg (ht i his j hjs)]
  apply exists_congr
  intro k
  apply and_congr_right
  intro hks
  exact lossTerm_pos_iff P v i j k (hp i his j hjs) (hp i his k hks)

/-- Both directions of state-dependent, exact one-step strict descent. -/
theorem blue_variance_strict_iff (s : Finset ι) (P : ι → ι → ℚ)
    (v : ι → ℚ × ℚ) (hn : s.Nonempty)
    (hrow : ∀ i ∈ s, (∑ j ∈ s, P i j) = 1)
    (hcol : ∀ j ∈ s, (∑ i ∈ s, P i j) = 1)
    (hp : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j) :
    blueVariance s (applyVec s P v) < blueVariance s v ↔ mixesDistinct s P v := by
  rw [← pairLoss_pos_iff s P v hp, ← blue_variance_loss s P v hn hrow hcol]
  exact sub_pos.symm

/-- Equality holds precisely when every positive row support has one velocity. -/
theorem blue_variance_eq_iff (s : Finset ι) (P : ι → ι → ℚ)
    (v : ι → ℚ × ℚ) (hn : s.Nonempty)
    (hrow : ∀ i ∈ s, (∑ j ∈ s, P i j) = 1)
    (hcol : ∀ j ∈ s, (∑ i ∈ s, P i j) = 1)
    (hp : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j) :
    blueVariance s (applyVec s P v) = blueVariance s v ↔
      ∀ i ∈ s, ∀ j ∈ s, ∀ k ∈ s, 0 < P i j → 0 < P i k → v j = v k := by
  have hle := blue_variance_nonincrease s P v hn hrow hcol hp
  have hs := blue_variance_strict_iff s P v hn hrow hcol hp
  constructor
  · intro heq i hi j hj k hk hpj hpk
    by_contra hne
    have hlt := hs.mpr ⟨i, hi, j, hj, k, hk, hpj, hpk, hne⟩
    rw [heq] at hlt
    exact lt_irrefl _ hlt
  · intro h
    apply le_antisymm hle
    by_contra hnot
    obtain ⟨i, hi, j, hj, k, hk, hpj, hpk, hne⟩ := hs.mp (lt_of_not_ge hnot)
    exact hne (h i hi j hj k hk hpj hpk)

end ChromoswarmStrict
