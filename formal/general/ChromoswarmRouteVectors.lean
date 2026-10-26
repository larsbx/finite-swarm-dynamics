import ChromoswarmRoutes
import ChromoswarmContractionVectors

/-! Generated from finite route witnesses and fixed exact expectations.
Each route is verified in Lean; the renderer does not prove connectivity. -/
namespace ChromoswarmRouteVectors
open ChromoswarmJensen ChromoswarmPlanar ChromoswarmStrict ChromoswarmContraction
set_option maxRecDepth 8192
set_option maxHeartbeats 3000000

def cycle4_P : Fin 4 → Fin 4 → ℚ := ![![(1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ)], ![(1 / 2 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ)]]
def cycle4_v : Fin 4 → ℚ × ℚ := ![((0 / 1 : ℚ), (0 / 1 : ℚ)), ((1 / 1 : ℚ), (0 / 1 : ℚ)), ((0 / 1 : ℚ), (1 / 1 : ℚ)), ((1 / 1 : ℚ), (1 / 1 : ℚ))]

theorem cycle4_routes : ChromoswarmRoutes.Routes Finset.univ cycle4_P (1 / 4 : ℚ) 2 := by
  intro j _ k _
  fin_cases j <;> fin_cases k
  · refine ⟨0, by norm_num, (fun t => 0), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 0 else (1)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 0 else (if t = 1 then 1 else (2))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 0 else (3)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 1 else (0)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 1), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 1 else (2)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 1 else (if t = 1 then 0 else (3))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 2 else (if t = 1 then 1 else (0))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 2 else (1)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 2), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 2 else (3)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 3 else (0)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 3 else (if t = 1 then 0 else (1))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 3 else (2)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 3), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega

theorem cycle4_certified : ChromoswarmRoutes.Certified Finset.univ cycle4_P (1 / 4 : ℚ) 2 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, cycle4_routes⟩ <;>
    norm_num [cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem cycle4_values :
    ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 4)) (1 / 4 : ℚ) 2 = (1 / 64 : ℚ) ∧
    1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 4)) (1 / 4 : ℚ) 2 = (63 / 64 : ℚ) ∧
    blueVariance Finset.univ cycle4_v = (2 / 1 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ cycle4_P cycle4_v 2) = (1 / 4 : ℚ) ∧
    (63 / 64 : ℚ)^2 * (2 / 1 : ℚ) = (3969 / 2048 : ℚ) := by
  norm_num [ChromoswarmRoutes.coefficient, cycle4_P, cycle4_v,
    evolve, blueVariance, variance, applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem cycle4_bound :
    blueVariance Finset.univ (evolve Finset.univ cycle4_P cycle4_v 2) ≤
    (1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 4)) (1 / 4 : ℚ) 2)^2 *
      blueVariance Finset.univ cycle4_v :=
  ChromoswarmRoutes.finite_horizon_bound Finset.univ cycle4_P cycle4_v _ _
    (by simp) cycle4_certified 2

def cycle4_thirds_P : Fin 4 → Fin 4 → ℚ := ![![(2 / 3 : ℚ), (1 / 3 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (2 / 3 : ℚ), (1 / 3 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (0 / 1 : ℚ), (2 / 3 : ℚ), (1 / 3 : ℚ)], ![(1 / 3 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ), (2 / 3 : ℚ)]]
def cycle4_thirds_v : Fin 4 → ℚ × ℚ := ![((1 / 3 : ℚ), (-2 / 5 : ℚ)), ((1 / 1 : ℚ), (0 / 1 : ℚ)), ((0 / 1 : ℚ), (1 / 1 : ℚ)), ((3 / 4 : ℚ), (1 / 2 : ℚ))]

theorem cycle4_thirds_routes : ChromoswarmRoutes.Routes Finset.univ cycle4_thirds_P (2 / 9 : ℚ) 2 := by
  intro j _ k _
  fin_cases j <;> fin_cases k
  · refine ⟨0, by norm_num, (fun t => 0), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 0 else (1)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 0 else (if t = 1 then 1 else (2))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 0 else (3)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 1 else (0)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 1), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 1 else (2)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 1 else (if t = 1 then 0 else (3))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 2 else (if t = 1 then 1 else (0))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 2 else (1)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 2), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 2 else (3)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 3 else (0)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 3 else (if t = 1 then 0 else (1))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 3 else (2)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 3), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega

theorem cycle4_thirds_certified : ChromoswarmRoutes.Certified Finset.univ cycle4_thirds_P (2 / 9 : ℚ) 2 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, cycle4_thirds_routes⟩ <;>
    norm_num [cycle4_thirds_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem cycle4_thirds_values :
    ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 4)) (2 / 9 : ℚ) 2 = (1 / 72 : ℚ) ∧
    1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 4)) (2 / 9 : ℚ) 2 = (71 / 72 : ℚ) ∧
    blueVariance Finset.univ cycle4_thirds_v = (8141 / 4800 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ cycle4_thirds_P cycle4_thirds_v 2) = (48479 / 129600 : ℚ) ∧
    (71 / 72 : ℚ)^2 * (8141 / 4800 : ℚ) = (41038781 / 24883200 : ℚ) := by
  norm_num [ChromoswarmRoutes.coefficient, cycle4_thirds_P, cycle4_thirds_v,
    evolve, blueVariance, variance, applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem cycle4_thirds_bound :
    blueVariance Finset.univ (evolve Finset.univ cycle4_thirds_P cycle4_thirds_v 2) ≤
    (1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 4)) (2 / 9 : ℚ) 2)^2 *
      blueVariance Finset.univ cycle4_thirds_v :=
  ChromoswarmRoutes.finite_horizon_bound Finset.univ cycle4_thirds_P cycle4_thirds_v _ _
    (by simp) cycle4_thirds_certified 2

def cycle5_P : Fin 5 → Fin 5 → ℚ := ![![(1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ)], ![(1 / 2 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ)]]
def cycle5_v : Fin 5 → ℚ × ℚ := ![((0 / 1 : ℚ), (0 / 1 : ℚ)), ((1 / 1 : ℚ), (0 / 1 : ℚ)), ((0 / 1 : ℚ), (1 / 1 : ℚ)), ((1 / 1 : ℚ), (1 / 1 : ℚ)), ((2 / 1 : ℚ), (-1 / 1 : ℚ))]

theorem cycle5_routes : ChromoswarmRoutes.Routes Finset.univ cycle5_P (1 / 4 : ℚ) 2 := by
  intro j _ k _
  fin_cases j <;> fin_cases k
  · refine ⟨0, by norm_num, (fun t => 0), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 0 else (1)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 0 else (if t = 1 then 1 else (2))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 0 else (if t = 1 then 4 else (3))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 0 else (4)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 1 else (0)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 1), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 1 else (2)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 1 else (if t = 1 then 2 else (3))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 1 else (if t = 1 then 0 else (4))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 2 else (if t = 1 then 1 else (0))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 2 else (1)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 2), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 2 else (3)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 2 else (if t = 1 then 3 else (4))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 3 else (if t = 1 then 4 else (0))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 3 else (if t = 1 then 2 else (1))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 3 else (2)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 3), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 3 else (4)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 4 else (0)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 4 else (if t = 1 then 0 else (1))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 4 else (if t = 1 then 3 else (2))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 4 else (3)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 4), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega

theorem cycle5_certified : ChromoswarmRoutes.Certified Finset.univ cycle5_P (1 / 4 : ℚ) 2 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, cycle5_routes⟩ <;>
    norm_num [cycle5_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem cycle5_values :
    ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 5)) (1 / 4 : ℚ) 2 = (1 / 80 : ℚ) ∧
    1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 5)) (1 / 4 : ℚ) 2 = (79 / 80 : ℚ) ∧
    blueVariance Finset.univ cycle5_v = (28 / 5 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ cycle5_P cycle5_v 2) = (49 / 40 : ℚ) ∧
    (79 / 80 : ℚ)^2 * (28 / 5 : ℚ) = (43687 / 8000 : ℚ) := by
  norm_num [ChromoswarmRoutes.coefficient, cycle5_P, cycle5_v,
    evolve, blueVariance, variance, applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem cycle5_bound :
    blueVariance Finset.univ (evolve Finset.univ cycle5_P cycle5_v 2) ≤
    (1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 5)) (1 / 4 : ℚ) 2)^2 *
      blueVariance Finset.univ cycle5_v :=
  ChromoswarmRoutes.finite_horizon_bound Finset.univ cycle5_P cycle5_v _ _
    (by simp) cycle5_certified 2

def complete_average_P : Fin 2 → Fin 2 → ℚ := ![![(1 / 2 : ℚ), (1 / 2 : ℚ)], ![(1 / 2 : ℚ), (1 / 2 : ℚ)]]
def complete_average_v : Fin 2 → ℚ × ℚ := ![((0 / 1 : ℚ), (0 / 1 : ℚ)), ((2 / 1 : ℚ), (0 / 1 : ℚ))]

theorem complete_average_routes : ChromoswarmRoutes.Routes Finset.univ complete_average_P (1 / 2 : ℚ) 1 := by
  intro j _ k _
  fin_cases j <;> fin_cases k
  · refine ⟨0, by norm_num, (fun t => 0), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 0 else (1)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, complete_average_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 1 else (0)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, complete_average_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 1), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega

theorem complete_average_certified : ChromoswarmRoutes.Certified Finset.univ complete_average_P (1 / 2 : ℚ) 1 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, complete_average_routes⟩ <;>
    norm_num [complete_average_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem complete_average_values :
    ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 2)) (1 / 2 : ℚ) 1 = (1 / 4 : ℚ) ∧
    1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 2)) (1 / 2 : ℚ) 1 = (3 / 4 : ℚ) ∧
    blueVariance Finset.univ complete_average_v = (2 / 1 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ complete_average_P complete_average_v 1) = (0 / 1 : ℚ) ∧
    (3 / 4 : ℚ)^1 * (2 / 1 : ℚ) = (3 / 2 : ℚ) := by
  norm_num [ChromoswarmRoutes.coefficient, complete_average_P, complete_average_v,
    evolve, blueVariance, variance, applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem complete_average_bound :
    blueVariance Finset.univ (evolve Finset.univ complete_average_P complete_average_v 1) ≤
    (1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 2)) (1 / 2 : ℚ) 1)^1 *
      blueVariance Finset.univ complete_average_v :=
  ChromoswarmRoutes.finite_horizon_bound Finset.univ complete_average_P complete_average_v _ _
    (by simp) complete_average_certified 1

def singleton_P : Fin 1 → Fin 1 → ℚ := ![![(1 / 1 : ℚ)]]
def singleton_v : Fin 1 → ℚ × ℚ := ![((3 / 1 : ℚ), (-2 / 1 : ℚ))]

theorem singleton_routes : ChromoswarmRoutes.Routes Finset.univ singleton_P (1 / 1 : ℚ) 1 := by
  intro j _ k _
  fin_cases j <;> fin_cases k
  · refine ⟨0, by norm_num, (fun t => 0), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega

theorem singleton_certified : ChromoswarmRoutes.Certified Finset.univ singleton_P (1 / 1 : ℚ) 1 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, singleton_routes⟩ <;>
    norm_num [singleton_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem singleton_values :
    ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 1)) (1 / 1 : ℚ) 1 = (1 / 1 : ℚ) ∧
    1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 1)) (1 / 1 : ℚ) 1 = (0 / 1 : ℚ) ∧
    blueVariance Finset.univ singleton_v = (0 / 1 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ singleton_P singleton_v 2) = (0 / 1 : ℚ) ∧
    (0 / 1 : ℚ)^2 * (0 / 1 : ℚ) = (0 / 1 : ℚ) := by
  norm_num [ChromoswarmRoutes.coefficient, singleton_P, singleton_v,
    evolve, blueVariance, variance, applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem singleton_bound :
    blueVariance Finset.univ (evolve Finset.univ singleton_P singleton_v 2) ≤
    (1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 1)) (1 / 1 : ℚ) 1)^2 *
      blueVariance Finset.univ singleton_v :=
  ChromoswarmRoutes.finite_horizon_bound Finset.univ singleton_P singleton_v _ _
    (by simp) singleton_certified 2

def consensus_P : Fin 4 → Fin 4 → ℚ := ![![(1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ), (0 / 1 : ℚ)], ![(0 / 1 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ), (1 / 2 : ℚ)], ![(1 / 2 : ℚ), (0 / 1 : ℚ), (0 / 1 : ℚ), (1 / 2 : ℚ)]]
def consensus_v : Fin 4 → ℚ × ℚ := ![((1 / 3 : ℚ), (-2 / 5 : ℚ)), ((1 / 3 : ℚ), (-2 / 5 : ℚ)), ((1 / 3 : ℚ), (-2 / 5 : ℚ)), ((1 / 3 : ℚ), (-2 / 5 : ℚ))]

theorem consensus_routes : ChromoswarmRoutes.Routes Finset.univ consensus_P (1 / 4 : ℚ) 2 := by
  intro j _ k _
  fin_cases j <;> fin_cases k
  · refine ⟨0, by norm_num, (fun t => 0), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 0 else (1)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 0 else (if t = 1 then 1 else (2))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 0 else (3)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 1 else (0)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 1), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 1 else (2)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 1 else (if t = 1 then 0 else (3))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 2 else (if t = 1 then 1 else (0))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 2 else (1)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 2), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 2 else (3)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 3 else (0)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨2, by norm_num, (fun t => if t = 0 then 3 else (if t = 1 then 0 else (1))), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨1, by norm_num, (fun t => if t = 0 then 3 else (2)), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      interval_cases t
      all_goals norm_num [overlap, consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]
  · refine ⟨0, by norm_num, (fun t => 3), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      omega

theorem consensus_certified : ChromoswarmRoutes.Certified Finset.univ consensus_P (1 / 4 : ℚ) 2 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, consensus_routes⟩ <;>
    norm_num [consensus_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem consensus_values :
    ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 4)) (1 / 4 : ℚ) 2 = (1 / 64 : ℚ) ∧
    1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 4)) (1 / 4 : ℚ) 2 = (63 / 64 : ℚ) ∧
    blueVariance Finset.univ consensus_v = (0 / 1 : ℚ) ∧
    blueVariance Finset.univ (evolve Finset.univ consensus_P consensus_v 2) = (0 / 1 : ℚ) ∧
    (63 / 64 : ℚ)^2 * (0 / 1 : ℚ) = (0 / 1 : ℚ) := by
  norm_num [ChromoswarmRoutes.coefficient, consensus_P, consensus_v,
    evolve, blueVariance, variance, applyVec, apply, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four]

theorem consensus_bound :
    blueVariance Finset.univ (evolve Finset.univ consensus_P consensus_v 2) ≤
    (1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin 4)) (1 / 4 : ℚ) 2)^2 *
      blueVariance Finset.univ consensus_v :=
  ChromoswarmRoutes.finite_horizon_bound Finset.univ consensus_P consensus_v _ _
    (by simp) consensus_certified 2

theorem swap_disconnected (η : ℚ) (hη : 0 < η) (L : ℕ) :
    ¬ ChromoswarmRoutes.Routes Finset.univ ChromoswarmStrictVectors.permutation_P η L := by
  intro hr
  have he (a : Fin 2) (_ha : a ∈ Finset.univ) (b : Fin 2) (_hb : b ∈ Finset.univ)
      (hab : η ≤ overlap Finset.univ ChromoswarmStrictVectors.permutation_P a b) : a = b := by
    fin_cases a <;> fin_cases b
    all_goals first | rfl | (norm_num [overlap, ChromoswarmStrictVectors.permutation_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four] at hab; linarith)
  have hh := ChromoswarmRoutes.routes_propagate Finset.univ _ η L (fun a : Fin 2 => a)
    hr he 0 1 (by simp) (by simp)
  exact (by decide : (0 : Fin 2) ≠ 1) hh

theorem blocks_disconnected (η : ℚ) (hη : 0 < η) (L : ℕ) :
    ¬ ChromoswarmRoutes.Routes Finset.univ ChromoswarmStrictVectors.block_equality_P η L := by
  intro hr
  have he (a : Fin 4) (_ha : a ∈ Finset.univ) (b : Fin 4) (_hb : b ∈ Finset.univ)
      (hab : η ≤ overlap Finset.univ ChromoswarmStrictVectors.block_equality_P a b) :
      a.val / 2 = b.val / 2 := by
    fin_cases a <;> fin_cases b <;>
      norm_num [overlap, ChromoswarmStrictVectors.block_equality_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four] at hab ⊢ <;> linarith
  have hh := ChromoswarmRoutes.routes_propagate Finset.univ _ η L (fun a : Fin 4 => a.val / 2)
    hr he 0 2 (by simp) (by simp)
  norm_num at hh

theorem cycle4_unit_budget_rejected :
    ¬ ChromoswarmRoutes.Routes Finset.univ cycle4_P (1/4) 1 := by
  intro hr
  obtain ⟨l, hl, p, hs, he, _hm, hedge⟩ := hr 0 (by simp) 2 (by simp)
  interval_cases l
  · exact (by decide : (0 : Fin 4) ≠ 2) (hs.symm.trans he)
  · have hb := hedge 0 (by norm_num)
    rw [hs, he] at hb
    norm_num [overlap, cycle4_P, Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail, Matrix.cons_val_four] at hb

end ChromoswarmRouteVectors
