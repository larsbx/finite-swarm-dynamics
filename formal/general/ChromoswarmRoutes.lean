import ChromoswarmContraction

/-!
# Finite positive-overlap routes

An explicit finite route between each pair replaces the direct all-pairs
overlap hypothesis. Rates are conservative rational bounds, without limits.
Only finite prefixes of route functions are used.
-/
namespace ChromoswarmRoutes

open ChromoswarmJensen ChromoswarmPlanar ChromoswarmStrict ChromoswarmContraction

variable {ι : Type*} [DecidableEq ι]

/-- A finite route prefix stays in the population and uses guarded overlaps. -/
def Routes (s : Finset ι) (P : ι → ι → ℚ) (η : ℚ) (L : ℕ) : Prop :=
  ∀ j ∈ s, ∀ k ∈ s, ∃ l ≤ L, ∃ p : ℕ → ι,
    p 0 = j ∧ p l = k ∧ (∀ t ≤ l, p t ∈ s) ∧
      ∀ t < l, η ≤ overlap s P (p t) (p (t+1))

/-- Any value constant on guarded edges is constant along a finite route.
    This also supplies separation-based negative controls for disconnected supports. -/
theorem routes_propagate {α : Type*} (s : Finset ι) (P : ι → ι → ℚ)
    (η : ℚ) (L : ℕ) (f : ι → α) (hroutes : Routes s P η L)
    (hedge : ∀ a ∈ s, ∀ b ∈ s, η ≤ overlap s P a b → f a = f b)
    (j k : ι) (hj : j ∈ s) (hk : k ∈ s) : f j = f k := by
  obtain ⟨l, _, p, hstart, hend, hmem, hstep⟩ := hroutes j hj k hk
  have hc (t : ℕ) : t ≤ l → f (p 0) = f (p t) := by
    induction t with
    | zero => intro _; rfl
    | succ t ih =>
      intro ht
      exact (ih (by omega)).trans
        (hedge (p t) (hmem t (by omega)) (p (t+1)) (hmem (t+1) ht)
          (hstep t (by omega)))
  simpa only [hstart, hend] using hc l le_rfl

/-- A finite rational sum-of-squares estimate for a scalar chain. -/
theorem scalar_chain_energy (f : ℕ → ℚ) (l : ℕ) :
    (f 0 - f l)^2 ≤ (l : ℚ) * ∑ t ∈ Finset.range l, (f t - f (t+1))^2 := by
  have htel : (∑ t ∈ Finset.range l, (f t - f (t+1))) = f 0 - f l := by
    induction l with
    | zero => simp
    | succ l ih => rw [Finset.sum_range_succ, ih]; ring
  have h := Finset.sum_mul_sq_le_sq_mul_sq (Finset.range l)
    (fun _ => (1 : ℚ)) (fun t => f t - f (t+1))
  simpa [htel] using h

theorem blue_chain_energy (f : ℕ → ℚ × ℚ) (l : ℕ) :
    blueDistance (f 0) (f l) ≤
      (l : ℚ) * ∑ t ∈ Finset.range l, blueDistance (f t) (f (t+1)) := by
  have hx := scalar_chain_energy (fun t => (f t).1) l
  have hy := scalar_chain_energy (fun t => (f t).2) l
  unfold blueDistance
  simp only [Finset.sum_add_distrib]
  linarith

/-- Per-edge weighted bounds give a finite length-squared endpoint bound. -/
theorem weighted_chain_bound (f : ℕ → ℚ × ℚ) (l : ℕ) (η B : ℚ)
    (hη : 0 ≤ η)
    (hedge : ∀ t < l, η * blueDistance (f t) (f (t+1)) ≤ B) :
    η * blueDistance (f 0) (f l) ≤ (l : ℚ)^2 * B := by
  have hs : (∑ t ∈ Finset.range l, η * blueDistance (f t) (f (t+1))) ≤
      (l : ℚ) * B := by
    calc
      _ ≤ ∑ _t ∈ Finset.range l, B := by
        apply Finset.sum_le_sum
        intro t ht
        exact hedge t (Finset.mem_range.mp ht)
      _ = _ := by simp
  have hc := mul_le_mul_of_nonneg_left (blue_chain_energy f l) hη
  have hl : (0 : ℚ) ≤ l := Nat.cast_nonneg _
  have hm := mul_le_mul_of_nonneg_left hs hl
  simp only [← Finset.mul_sum] at hm
  nlinarith

theorem overlap_nonneg (s : Finset ι) (P : ι → ι → ℚ)
    (hp : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j)
    (j k : ι) (hj : j ∈ s) (hk : k ∈ s) : 0 ≤ overlap s P j k := by
  apply Finset.sum_nonneg
  intro i hi
  exact mul_nonneg (hp i hi j hj) (hp i hi k hk)

/-- Each ordered edge term is at most twice the full pair loss. -/
theorem edge_loss_bound (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ)
    (η : ℚ) (hp : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j)
    (j k : ι) (hj : j ∈ s) (hk : k ∈ s) (he : η ≤ overlap s P j k) :
    η * blueDistance (v j) (v k) ≤ 2 * pairLoss s P v := by
  have ht (a) (ha : a ∈ s) (b) (hb : b ∈ s) :
      0 ≤ overlap s P a b * blueDistance (v a) (v b) :=
    mul_nonneg (overlap_nonneg s P hp a b ha hb) (blueDistance_nonneg _ _)
  have hi := Finset.single_le_sum (ht j hj) hk
  have ho := Finset.single_le_sum (fun a ha => Finset.sum_nonneg (ht a ha)) hj
  have hmul := mul_le_mul_of_nonneg_right he (blueDistance_nonneg (v j) (v k))
  have heq := pairLoss_overlap s P v
  linarith

theorem pairLoss_nonneg (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ)
    (hp : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j) : 0 ≤ pairLoss s P v := by
  rw [pairLoss_overlap]
  apply div_nonneg _ (by norm_num)
  apply Finset.sum_nonneg
  intro j hj
  apply Finset.sum_nonneg
  intro k hk
  exact mul_nonneg (overlap_nonneg s P hp j k hj hk) (blueDistance_nonneg _ _)

/-- Route every old-agent pair, using only its finite prefix. -/
theorem routed_pair_bound (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ)
    (η : ℚ) (L : ℕ) (hη : 0 ≤ η)
    (hp : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j) (hroutes : Routes s P η L)
    (j k : ι) (hj : j ∈ s) (hk : k ∈ s) :
    η * blueDistance (v j) (v k) ≤ (L : ℚ)^2 * (2 * pairLoss s P v) := by
  obtain ⟨l, hl, p, hstart, hend, hmem, hedge⟩ := hroutes j hj k hk
  have hc := weighted_chain_bound (fun t => v (p t)) l η (2 * pairLoss s P v) hη
    (fun t ht => edge_loss_bound s P v η hp (p t) (p (t+1))
      (hmem t (by omega)) (hmem (t+1) (by omega)) (hedge t ht))
  dsimp only at hc
  rw [hstart, hend] at hc
  have hcast : (l : ℚ) ≤ L := by exact_mod_cast hl
  have hl0 : (0 : ℚ) ≤ l := Nat.cast_nonneg _
  have hL0 : (0 : ℚ) ≤ L := Nat.cast_nonneg _
  have hsq : (l : ℚ)^2 ≤ (L : ℚ)^2 := by nlinarith
  have hpos := pairLoss_nonneg s P v hp
  exact le_trans hc (mul_le_mul_of_nonneg_right hsq (by linarith))

def coefficient (s : Finset ι) (η : ℚ) (L : ℕ) : ℚ :=
  η / ((s.card : ℚ) * (L : ℚ)^2)

/-- Finite paths produce a state-independent loss lower bound. -/
theorem routed_loss_lower_bound (s : Finset ι) (P : ι → ι → ℚ)
    (v : ι → ℚ × ℚ) (η : ℚ) (L : ℕ) (hn : s.Nonempty) (hL : 1 ≤ L)
    (hη : 0 ≤ η) (hp : ∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j)
    (hroutes : Routes s P η L) :
    coefficient s η L * blueVariance s v ≤ pairLoss s P v := by
  have hnpos : (0 : ℚ) < s.card := by exact_mod_cast hn.card_pos
  have hLpos : (0 : ℚ) < L := by exact_mod_cast (show 0 < L by omega)
  have hden : 0 < (s.card : ℚ) * (L : ℚ)^2 := mul_pos hnpos (sq_pos_of_pos hLpos)
  have hs :
      (∑ j ∈ s, ∑ k ∈ s, η * blueDistance (v j) (v k)) ≤
        (s.card : ℚ) * ((s.card : ℚ) * ((L : ℚ)^2 * (2 * pairLoss s P v))) := by
    calc
      _ ≤ ∑ _j ∈ s, ∑ _k ∈ s, (L : ℚ)^2 * (2 * pairLoss s P v) := by
        apply Finset.sum_le_sum
        intro j hj
        apply Finset.sum_le_sum
        intro k hk
        exact routed_pair_bound s P v η L hη hp hroutes j k hj hk
      _ = _ := by simp
  simp_rw [← Finset.mul_sum] at hs
  rw [blue_pairwise_variance s v hn] at hs
  have hc : η * blueVariance s v ≤
      (s.card : ℚ) * (L : ℚ)^2 * pairLoss s P v := by
    apply (mul_le_mul_iff_right₀ (show 0 < 2 * (s.card : ℚ) by positivity)).mp
    nlinarith [hs]
  unfold coefficient
  rw [div_mul_eq_mul_div]
  exact (div_le_iff₀ hden).mpr (by nlinarith [hc])

def Certified (s : Finset ι) (P : ι → ι → ℚ) (η : ℚ) (L : ℕ) : Prop :=
  (∀ i ∈ s, (∑ j ∈ s, P i j) = 1) ∧
  (∀ j ∈ s, (∑ i ∈ s, P i j) = 1) ∧
  (∀ i ∈ s, ∀ j ∈ s, 0 ≤ P i j) ∧
  0 < η ∧ η ≤ 1 ∧ 1 ≤ L ∧ Routes s P η L

theorem coefficient_range (s : Finset ι) (η : ℚ) (L : ℕ) (hn : s.Nonempty)
    (hη : 0 < η) (hη1 : η ≤ 1) (hL : 1 ≤ L) :
    0 < coefficient s η L ∧ coefficient s η L ≤ 1 := by
  have hn1 : (1 : ℚ) ≤ s.card := by exact_mod_cast hn.card_pos
  have hL1 : (1 : ℚ) ≤ L := by exact_mod_cast hL
  have hden1 : (1 : ℚ) ≤ (s.card : ℚ) * (L : ℚ)^2 := by nlinarith
  have hden : 0 < (s.card : ℚ) * (L : ℚ)^2 := by linarith
  constructor
  · exact div_pos hη hden
  · exact (div_le_iff₀ hden).mpr (by linarith)

theorem one_step_bound (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ)
    (η : ℚ) (L : ℕ) (hn : s.Nonempty) (h : Certified s P η L) :
    blueVariance s (applyVec s P v) ≤ (1 - coefficient s η L) * blueVariance s v := by
  have hloss := blue_variance_loss s P v hn h.1 h.2.1
  have hb := routed_loss_lower_bound s P v η L hn h.2.2.2.2.2.1
    (le_of_lt h.2.2.2.1) h.2.2.1 h.2.2.2.2.2.2
  linarith

theorem rate_range (s : Finset ι) (P : ι → ι → ℚ) (η : ℚ) (L : ℕ)
    (hn : s.Nonempty) (h : Certified s P η L) :
    0 ≤ 1 - coefficient s η L ∧ 1 - coefficient s η L < 1 := by
  have hc := coefficient_range s η L hn h.2.2.2.1 h.2.2.2.2.1 h.2.2.2.2.2.1
  constructor <;> linarith [hc.1, hc.2]

theorem blue_variance_pos_iff (s : Finset ι) (v : ι → ℚ × ℚ) (hn : s.Nonempty) :
    0 < blueVariance s v ↔ ∃ j ∈ s, ∃ k ∈ s, v j ≠ v k := by
  have hnpos : (0 : ℚ) < s.card := by exact_mod_cast hn.card_pos
  have hi (j : ι) : 0 ≤ ∑ k ∈ s, blueDistance (v j) (v k) :=
    Finset.sum_nonneg (fun k _ => blueDistance_nonneg _ _)
  have hpairs := blue_pairwise_variance s v hn
  constructor
  · intro hv
    have hs : 0 < ∑ j ∈ s, ∑ k ∈ s, blueDistance (v j) (v k) := by
      rw [hpairs]
      exact mul_pos (mul_pos (by norm_num) hnpos) hv
    obtain ⟨j, hj, hinner⟩ := (Finset.sum_pos_iff_of_nonneg (fun j _ => hi j)).mp hs
    obtain ⟨k, hk, hd⟩ := (Finset.sum_pos_iff_of_nonneg
      (fun k _ => blueDistance_nonneg (v j) (v k))).mp hinner
    exact ⟨j, hj, k, hk, (blueDistance_pos_iff _ _).mp hd⟩
  · rintro ⟨j, hj, k, hk, hne⟩
    have hinner := (Finset.sum_pos_iff_of_nonneg
      (fun k _ => blueDistance_nonneg (v j) (v k))).mpr
        ⟨k, hk, (blueDistance_pos_iff _ _).mpr hne⟩
    have hs := (Finset.sum_pos_iff_of_nonneg (fun j _ => hi j)).mpr ⟨j, hj, hinner⟩
    rw [hpairs] at hs
    by_contra hnot
    have := mul_nonpos_of_nonneg_of_nonpos
      (show 0 ≤ 2 * (s.card : ℚ) by positivity) (le_of_not_gt hnot)
    linarith

/-- Routed positive support gives strict descent exactly off consensus states. -/
theorem strict_iff_distinct (s : Finset ι) (P : ι → ι → ℚ) (v : ι → ℚ × ℚ)
    (η : ℚ) (L : ℕ) (hn : s.Nonempty) (h : Certified s P η L) :
    blueVariance s (applyVec s P v) < blueVariance s v ↔
      ∃ j ∈ s, ∃ k ∈ s, v j ≠ v k := by
  constructor
  · intro hstrict
    obtain ⟨i, hi, j, hj, k, hk, _, _, hne⟩ :=
      (blue_variance_strict_iff s P v hn h.1 h.2.1 h.2.2.1).mp hstrict
    exact ⟨j, hj, k, hk, hne⟩
  · intro hdistinct
    have hv := (blue_variance_pos_iff s v hn).mpr hdistinct
    have hb := one_step_bound s P v η L hn h
    have hr := (rate_range s P η L hn h).2
    have hm := mul_lt_mul_of_pos_right hr hv
    linarith

theorem finite_horizon_bound (s : Finset ι) (P : ι → ι → ℚ)
    (v : ι → ℚ × ℚ) (η : ℚ) (L : ℕ) (hn : s.Nonempty)
    (h : Certified s P η L) (k : ℕ) :
    blueVariance s (evolve s P v k) ≤
      (1 - coefficient s η L)^k * blueVariance s v := by
  induction k with
  | zero => simp [evolve]
  | succ k ih =>
    have hs := one_step_bound s P (evolve s P v k) η L hn h
    have hr := (rate_range s P η L hn h).1
    calc
      _ ≤ (1 - coefficient s η L) * blueVariance s (evolve s P v k) := hs
      _ ≤ (1 - coefficient s η L) *
          ((1 - coefficient s η L)^k * blueVariance s v) := mul_le_mul_of_nonneg_left ih hr
      _ = _ := by rw [pow_succ]; ring

end ChromoswarmRoutes
