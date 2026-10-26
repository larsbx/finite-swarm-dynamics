import ChromoswarmContraction
import ChromoswarmStrictVectors

/-! Generated from fixed rational expectations, without calculating them.
The kernel checker also retains the earlier strictness regression imports. -/
namespace ChromoswarmContractionVectors
open ChromoswarmJensen ChromoswarmPlanar ChromoswarmStrict ChromoswarmContraction
set_option maxRecDepth 8192
set_option maxHeartbeats 2000000

def singleton_P : Fin 1 → Fin 1 → ℚ := ![![(1 / 1 : ℚ)]]
def singleton_v : Fin 1 → ℚ × ℚ := ![((3 / 1 : ℚ), (-2 / 1 : ℚ))]

theorem singleton_certified : Certified Finset.univ singleton_P (1 / 1 : ℚ) := by
  norm_num [Certified, overlapBound, overlap, singleton_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

theorem singleton_values :
    1 - (1 : ℚ) * (1 / 1 : ℚ) = (0 / 1 : ℚ) ∧
    blueVariance Finset.univ singleton_v = (0 / 1 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ singleton_P singleton_v 2) = (0 / 1 : ℚ) ∧
    (0 / 1 : ℚ)^2 * (0 / 1 : ℚ) = (0 / 1 : ℚ) := by
  norm_num [singleton_P, singleton_v, evolve, blueVariance, variance,
    applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

-- Instantiate the general finite-horizon theorem, independently of evaluation.
theorem singleton_bound :
    blueVariance Finset.univ (evolve Finset.univ singleton_P singleton_v 2) ≤
      (1 - ((Finset.univ : Finset (Fin 1)).card : ℚ) * (1 / 1 : ℚ))^2 * blueVariance Finset.univ singleton_v :=
  finite_horizon_bound Finset.univ singleton_P singleton_v _ (by simp) singleton_certified 2

def swap_P : Fin 2 → Fin 2 → ℚ := ![![(0 / 1 : ℚ), (1 / 1 : ℚ)], ![(1 / 1 : ℚ), (0 / 1 : ℚ)]]
def swap_v : Fin 2 → ℚ × ℚ := ![((0 / 1 : ℚ), (0 / 1 : ℚ)), ((2 / 1 : ℚ), (1 / 1 : ℚ))]

theorem swap_certified : Certified Finset.univ swap_P (0 / 1 : ℚ) := by
  norm_num [Certified, overlapBound, overlap, swap_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

theorem swap_values :
    1 - (2 : ℚ) * (0 / 1 : ℚ) = (1 / 1 : ℚ) ∧
    blueVariance Finset.univ swap_v = (5 / 2 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ swap_P swap_v 3) = (5 / 2 : ℚ) ∧
    (1 / 1 : ℚ)^3 * (5 / 2 : ℚ) = (5 / 2 : ℚ) := by
  norm_num [swap_P, swap_v, evolve, blueVariance, variance,
    applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

-- Instantiate the general finite-horizon theorem, independently of evaluation.
theorem swap_bound :
    blueVariance Finset.univ (evolve Finset.univ swap_P swap_v 3) ≤
      (1 - ((Finset.univ : Finset (Fin 2)).card : ℚ) * (0 / 1 : ℚ))^3 * blueVariance Finset.univ swap_v :=
  finite_horizon_bound Finset.univ swap_P swap_v _ (by simp) swap_certified 3

def complete_average_P : Fin 2 → Fin 2 → ℚ := ![![(1 / 2 : ℚ), (1 / 2 : ℚ)], ![(1 / 2 : ℚ), (1 / 2 : ℚ)]]
def complete_average_v : Fin 2 → ℚ × ℚ := ![((0 / 1 : ℚ), (0 / 1 : ℚ)), ((0 / 1 : ℚ), (2 / 1 : ℚ))]

theorem complete_average_certified : Certified Finset.univ complete_average_P (1 / 2 : ℚ) := by
  norm_num [Certified, overlapBound, overlap, complete_average_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

theorem complete_average_values :
    1 - (2 : ℚ) * (1 / 2 : ℚ) = (0 / 1 : ℚ) ∧
    blueVariance Finset.univ complete_average_v = (2 / 1 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ complete_average_P complete_average_v 1) = (0 / 1 : ℚ) ∧
    (0 / 1 : ℚ)^1 * (2 / 1 : ℚ) = (0 / 1 : ℚ) := by
  norm_num [complete_average_P, complete_average_v, evolve, blueVariance, variance,
    applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

-- Instantiate the general finite-horizon theorem, independently of evaluation.
theorem complete_average_bound :
    blueVariance Finset.univ (evolve Finset.univ complete_average_P complete_average_v 1) ≤
      (1 - ((Finset.univ : Finset (Fin 2)).card : ℚ) * (1 / 2 : ℚ))^1 * blueVariance Finset.univ complete_average_v :=
  finite_horizon_bound Finset.univ complete_average_P complete_average_v _ (by simp) complete_average_certified 1

def thirds_P : Fin 2 → Fin 2 → ℚ := ![![(2 / 3 : ℚ), (1 / 3 : ℚ)], ![(1 / 3 : ℚ), (2 / 3 : ℚ)]]
def thirds_v : Fin 2 → ℚ × ℚ := ![((0 / 1 : ℚ), (0 / 1 : ℚ)), ((2 / 1 : ℚ), (0 / 1 : ℚ))]

theorem thirds_certified : Certified Finset.univ thirds_P (4 / 9 : ℚ) := by
  norm_num [Certified, overlapBound, overlap, thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

theorem thirds_values :
    1 - (2 : ℚ) * (4 / 9 : ℚ) = (1 / 9 : ℚ) ∧
    blueVariance Finset.univ thirds_v = (2 / 1 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ thirds_P thirds_v 4) = (2 / 6561 : ℚ) ∧
    (1 / 9 : ℚ)^4 * (2 / 1 : ℚ) = (2 / 6561 : ℚ) := by
  norm_num [thirds_P, thirds_v, evolve, blueVariance, variance,
    applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

-- Instantiate the general finite-horizon theorem, independently of evaluation.
theorem thirds_bound :
    blueVariance Finset.univ (evolve Finset.univ thirds_P thirds_v 4) ≤
      (1 - ((Finset.univ : Finset (Fin 2)).card : ℚ) * (4 / 9 : ℚ))^4 * blueVariance Finset.univ thirds_v :=
  finite_horizon_bound Finset.univ thirds_P thirds_v _ (by simp) thirds_certified 4

def three_cycle_P : Fin 3 → Fin 3 → ℚ := ![![(1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ)], ![(1 / 2 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ)]]
def three_cycle_v : Fin 3 → ℚ × ℚ := ![((0 / 1 : ℚ), (0 / 1 : ℚ)), ((2 / 1 : ℚ), (0 / 1 : ℚ)), ((0 / 1 : ℚ), (2 / 1 : ℚ))]

theorem three_cycle_certified : Certified Finset.univ three_cycle_P (1 / 4 : ℚ) := by
  norm_num [Certified, overlapBound, overlap, three_cycle_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

theorem three_cycle_values :
    1 - (3 : ℚ) * (1 / 4 : ℚ) = (1 / 4 : ℚ) ∧
    blueVariance Finset.univ three_cycle_v = (16 / 3 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ three_cycle_P three_cycle_v 3) = (1 / 12 : ℚ) ∧
    (1 / 4 : ℚ)^3 * (16 / 3 : ℚ) = (1 / 12 : ℚ) := by
  norm_num [three_cycle_P, three_cycle_v, evolve, blueVariance, variance,
    applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

-- Instantiate the general finite-horizon theorem, independently of evaluation.
theorem three_cycle_bound :
    blueVariance Finset.univ (evolve Finset.univ three_cycle_P three_cycle_v 3) ≤
      (1 - ((Finset.univ : Finset (Fin 3)).card : ℚ) * (1 / 4 : ℚ))^3 * blueVariance Finset.univ three_cycle_v :=
  finite_horizon_bound Finset.univ three_cycle_P three_cycle_v _ (by simp) three_cycle_certified 3

def asymmetric_columns_P : Fin 3 → Fin 3 → ℚ := ![![(1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ)], ![(1 / 3 : ℚ), (1 / 6 : ℚ), (1 / 2 : ℚ)], ![(1 / 6 : ℚ), (1 / 3 : ℚ), (1 / 2 : ℚ)]]
def asymmetric_columns_v : Fin 3 → ℚ × ℚ := ![((0 / 1 : ℚ), (0 / 1 : ℚ)), ((2 / 1 : ℚ), (0 / 1 : ℚ)), ((0 / 1 : ℚ), (2 / 1 : ℚ))]

theorem asymmetric_columns_certified : Certified Finset.univ asymmetric_columns_P (1 / 4 : ℚ) := by
  norm_num [Certified, overlapBound, overlap, asymmetric_columns_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

theorem asymmetric_columns_values :
    1 - (3 : ℚ) * (1 / 4 : ℚ) = (1 / 4 : ℚ) ∧
    blueVariance Finset.univ asymmetric_columns_v = (16 / 3 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ asymmetric_columns_P asymmetric_columns_v 2) = (5 / 81 : ℚ) ∧
    (1 / 4 : ℚ)^2 * (16 / 3 : ℚ) = (1 / 3 : ℚ) := by
  norm_num [asymmetric_columns_P, asymmetric_columns_v, evolve, blueVariance, variance,
    applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

-- Instantiate the general finite-horizon theorem, independently of evaluation.
theorem asymmetric_columns_bound :
    blueVariance Finset.univ (evolve Finset.univ asymmetric_columns_P asymmetric_columns_v 2) ≤
      (1 - ((Finset.univ : Finset (Fin 3)).card : ℚ) * (1 / 4 : ℚ))^2 * blueVariance Finset.univ asymmetric_columns_v :=
  finite_horizon_bound Finset.univ asymmetric_columns_P asymmetric_columns_v _ (by simp) asymmetric_columns_certified 2

theorem asymmetric_columns_orientation :
    overlap Finset.univ asymmetric_columns_P 0 1 = (13 / 36 : ℚ) ∧
    (∑ j, asymmetric_columns_P 0 j * asymmetric_columns_P 1 j) = (1 / 4 : ℚ) := by
  norm_num [overlap, asymmetric_columns_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

def consensus_P : Fin 2 → Fin 2 → ℚ := ![![(2 / 3 : ℚ), (1 / 3 : ℚ)], ![(1 / 3 : ℚ), (2 / 3 : ℚ)]]
def consensus_v : Fin 2 → ℚ × ℚ := ![((1 / 3 : ℚ), (-2 / 5 : ℚ)), ((1 / 3 : ℚ), (-2 / 5 : ℚ))]

theorem consensus_certified : Certified Finset.univ consensus_P (4 / 9 : ℚ) := by
  norm_num [Certified, overlapBound, overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

theorem consensus_values :
    1 - (2 : ℚ) * (4 / 9 : ℚ) = (1 / 9 : ℚ) ∧
    blueVariance Finset.univ consensus_v = (0 / 1 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ consensus_P consensus_v 2) = (0 / 1 : ℚ) ∧
    (1 / 9 : ℚ)^2 * (0 / 1 : ℚ) = (0 / 1 : ℚ) := by
  norm_num [consensus_P, consensus_v, evolve, blueVariance, variance,
    applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

-- Instantiate the general finite-horizon theorem, independently of evaluation.
theorem consensus_bound :
    blueVariance Finset.univ (evolve Finset.univ consensus_P consensus_v 2) ≤
      (1 - ((Finset.univ : Finset (Fin 2)).card : ℚ) * (4 / 9 : ℚ))^2 * blueVariance Finset.univ consensus_v :=
  finite_horizon_bound Finset.univ consensus_P consensus_v _ (by simp) consensus_certified 2

def block_equality_P : Fin 4 → Fin 4 → ℚ := ![![(1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ)], ![(1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ)], ![(0 / 1 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ)]]
def block_equality_v : Fin 4 → ℚ × ℚ := ![((0 / 1 : ℚ), (0 / 1 : ℚ)), ((0 / 1 : ℚ), (0 / 1 : ℚ)), ((2 / 1 : ℚ), (1 / 1 : ℚ)), ((2 / 1 : ℚ), (1 / 1 : ℚ))]

theorem block_equality_certified : Certified Finset.univ block_equality_P (0 / 1 : ℚ) := by
  norm_num [Certified, overlapBound, overlap, block_equality_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

theorem block_equality_values :
    1 - (4 : ℚ) * (0 / 1 : ℚ) = (1 / 1 : ℚ) ∧
    blueVariance Finset.univ block_equality_v = (5 / 1 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ block_equality_P block_equality_v 2) = (5 / 1 : ℚ) ∧
    (1 / 1 : ℚ)^2 * (5 / 1 : ℚ) = (5 / 1 : ℚ) := by
  norm_num [block_equality_P, block_equality_v, evolve, blueVariance, variance,
    applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

-- Instantiate the general finite-horizon theorem, independently of evaluation.
theorem block_equality_bound :
    blueVariance Finset.univ (evolve Finset.univ block_equality_P block_equality_v 2) ≤
      (1 - ((Finset.univ : Finset (Fin 4)).card : ℚ) * (0 / 1 : ℚ))^2 * blueVariance Finset.univ block_equality_v :=
  finite_horizon_bound Finset.univ block_equality_P block_equality_v _ (by simp) block_equality_certified 2

def zero_overlap_descent_P : Fin 4 → Fin 4 → ℚ := ![![(1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ)], ![(1 / 2 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ)]]
def zero_overlap_descent_v : Fin 4 → ℚ × ℚ := ![((0 / 1 : ℚ), (0 / 1 : ℚ)), ((1 / 1 : ℚ), (0 / 1 : ℚ)), ((0 / 1 : ℚ), (1 / 1 : ℚ)), ((1 / 1 : ℚ), (1 / 1 : ℚ))]

theorem zero_overlap_descent_certified : Certified Finset.univ zero_overlap_descent_P (0 / 1 : ℚ) := by
  norm_num [Certified, overlapBound, overlap, zero_overlap_descent_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

theorem zero_overlap_descent_values :
    1 - (4 : ℚ) * (0 / 1 : ℚ) = (1 / 1 : ℚ) ∧
    blueVariance Finset.univ zero_overlap_descent_v = (2 / 1 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ zero_overlap_descent_P zero_overlap_descent_v 2) = (1 / 4 : ℚ) ∧
    (1 / 1 : ℚ)^2 * (2 / 1 : ℚ) = (2 / 1 : ℚ) := by
  norm_num [zero_overlap_descent_P, zero_overlap_descent_v, evolve, blueVariance, variance,
    applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

-- Instantiate the general finite-horizon theorem, independently of evaluation.
theorem zero_overlap_descent_bound :
    blueVariance Finset.univ (evolve Finset.univ zero_overlap_descent_P zero_overlap_descent_v 2) ≤
      (1 - ((Finset.univ : Finset (Fin 4)).card : ℚ) * (0 / 1 : ℚ))^2 * blueVariance Finset.univ zero_overlap_descent_v :=
  finite_horizon_bound Finset.univ zero_overlap_descent_P zero_overlap_descent_v _ (by simp) zero_overlap_descent_certified 2

-- Overstated overlap fails even though its proposed rate would be in [0,1].
theorem overstated_overlap_rejected : ¬ Certified Finset.univ thirds_P (1/2) := by
  norm_num [Certified, overlapBound, overlap, thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

-- A singleton still needs the explicit rate guard (pair overlap is vacuous).
theorem negative_rate_rejected : ¬ Certified Finset.univ singleton_P 2 := by
  norm_num [Certified, overlapBound, overlap, singleton_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]

theorem signed_weights_rejected (η : ℚ) :
    ¬ Certified Finset.univ ChromoswarmStrictVectors.signed_growth_P η := by
  intro h
  apply ChromoswarmStrictVectors.signed_growth_nonnegative
  intro i j
  exact h.2.2.1 i (by simp) j (by simp)

theorem missing_columns_rejected (η : ℚ) :
    ¬ Certified Finset.univ ChromoswarmStrictVectors.missing_column_P η := by
  intro h
  apply ChromoswarmStrictVectors.missing_column_column_unital
  intro j
  exact h.2.1 j (by simp)

end ChromoswarmContractionVectors
