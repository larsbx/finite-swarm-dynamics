import ChromoswarmGeneral
import Mathlib

/-!
# SGC-2: General-field certificates for certified planar four-cells

Theorems are exact field/ring identities, not floating point limits.
Geometry follows the oriented A→B→D→C→A edge word in the Mojo
`certify_quad_face` consumer. Face construction, geometric admissibility,
and the algebraic chain complex remain separate input contracts.

This file proves the universal geometric and cochain equations. It does
not prove executable refinement of the Mojo implementation or infer
synchronization or vorticity from homology.
-/

namespace ChromoswarmCells

section Boundary

/-- The signed vertices of the oriented A→B→D→C→A walk cancel. -/
theorem quadrilateral_boundary_closed {R : Type*} [CommRing R]
    (a b c d : R) :
    (b - a) + (d - b) + (c - d) + (a - c) = 0 := by
  ring

end Boundary

section Geometry

variable {K : Type*} [Field K]

/-- Join/wedge determinant of two planar directions. -/
def wedge (u v : K × K) : K := u.1 * v.2 - u.2 * v.1

/-- Affine displacement `u-v` in a quadratic plane. -/
def minus (u v : K × K) : K × K := (u.1 - v.1, u.2 - v.2)

/-- Vector addition, independent of any Euclidean order. -/
def plus (u v : K × K) : K × K := (u.1 + v.1, u.2 + v.2)

/-- Two independent direction constraints have only the zero solution. -/
theorem independent_wedges_force_zero (x y z : K × K)
    (hxy : wedge x y ≠ 0)
    (hxz : wedge x z = 0)
    (hyz : wedge y z = 0) :
    z = (0, 0) := by
  have h₁ : wedge x y * z.1 = 0 := by
    calc
      wedge x y * z.1 =
          -(wedge y z) * x.1 + (wedge x z) * y.1 := by
            dsimp [wedge]
            ring
      _ = 0 := by rw [hyz, hxz]; ring
  have h₂ : wedge x y * z.2 = 0 := by
    calc
      wedge x y * z.2 =
          -(wedge y z) * x.2 + (wedge x z) * y.2 := by
            dsimp [wedge]
            ring
      _ = 0 := by rw [hyz, hxz]; ring
  have hz₁ : z.1 = 0 := (mul_eq_zero.mp h₁).resolve_left hxy
  have hz₂ : z.2 = 0 := (mul_eq_zero.mp h₂).resolve_left hxy
  exact Prod.ext hz₁ hz₂

/-- Two parallel-opposite-side tests force the fourth vertex. -/
theorem parallelogram_of_zero_wedges (a b c d : K × K)
    (hbase : wedge (minus b a) (minus c a) ≠ 0)
    (h₁ : wedge (minus b a) (minus d c) = 0)
    (h₂ : wedge (minus c a) (minus d b) = 0) :
    d = plus (minus b a) c := by
  have hxz :
      wedge (minus b a) (minus d (plus (minus b a) c)) = 0 := by
    calc
      wedge (minus b a) (minus d (plus (minus b a) c)) =
          wedge (minus b a) (minus d c) := by
            dsimp [wedge, minus, plus]
            ring
      _ = 0 := h₁
  have hyz :
      wedge (minus c a) (minus d (plus (minus b a) c)) = 0 := by
    calc
      wedge (minus c a) (minus d (plus (minus b a) c)) =
          wedge (minus c a) (minus d b) := by
            dsimp [wedge, minus, plus]
            ring
      _ = 0 := h₂
  have hz := independent_wedges_force_zero
    (minus b a) (minus c a) (minus d (plus (minus b a) c))
    hbase hxz hyz
  have hz₁ : (minus d (plus (minus b a) c)).1 = 0 := by
    simpa using congrArg Prod.fst hz
  have hz₂ : (minus d (plus (minus b a) c)).2 = 0 := by
    simpa using congrArg Prod.snd hz
  apply Prod.ext
  · dsimp [minus, plus] at hz₁ ⊢
    linear_combination hz₁
  · dsimp [minus, plus] at hz₂ ⊢
    linear_combination hz₂

/-- The explicit affine parallelogram completion has both zero wedges. -/
theorem parallelogram_zero_wedges (a b c : K × K) :
    wedge (minus b a) (minus (plus (minus b a) c) c) = 0 ∧
    wedge (minus c a) (minus (plus (minus b a) c) b) = 0 := by
  constructor
  · dsimp [wedge, minus, plus]
    ring
  · dsimp [wedge, minus, plus]
    ring

/-- Exact planar zero-spread *numerator* characterization, with a
noncollinear basis. Isotropic direction guards are separately required
to interpret the numerators as guarded rational-trig spreads. -/
theorem parallelogram_iff (a b c d : K × K)
    (hbase : wedge (minus b a) (minus c a) ≠ 0) :
    (wedge (minus b a) (minus d c) = 0 ∧
     wedge (minus c a) (minus d b) = 0) ↔
       d = plus (minus b a) c := by
  constructor
  · intro h
    exact parallelogram_of_zero_wedges a b c d hbase h.1 h.2
  · intro hd
    rw [hd]
    exact parallelogram_zero_wedges a b c

end Geometry

section Cochains

variable {R : Type*} [CommRing R]
variable {ne nf : ℕ}

/-- Finite exact Stokes: evaluating the coboundary of an edge
cochain on a face chain equals evaluating the edge cochain on the
face-chain boundary. No topology, order, or analytic integration. -/
theorem cellular_stokes
    (d₂ : Fin ne → Fin nf → R)
    (j : Fin ne → R) (f : Fin nf → R) :
    (∑ face : Fin nf, (∑ edge : Fin ne,
          j edge * d₂ edge face) * f face) =
      ∑ edge : Fin ne, j edge *
        (∑ face : Fin nf, d₂ edge face * f face) := by
  calc
    (∑ face : Fin nf, (∑ edge : Fin ne,
          j edge * d₂ edge face) * f face) =
        ∑ face : Fin nf, ∑ edge : Fin ne,
          j edge * (d₂ edge face * f face) := by
            apply Finset.sum_congr rfl
            intro face hf
            rw [Finset.sum_mul]
            apply Finset.sum_congr rfl
            intro edge he
            ring
    _ = ∑ edge : Fin ne, ∑ face : Fin nf,
          j edge * (d₂ edge face * f face) := by
            rw [Finset.sum_comm]
    _ = ∑ edge : Fin ne, j edge *
          (∑ face : Fin nf, d₂ edge face * f face) := by
            apply Finset.sum_congr rfl
            intro edge he
            rw [Finset.mul_sum]

/-- A closed edge cochain evaluates to zero on every cellular
boundary, but this does not force the cochain itself to vanish. -/
theorem closed_cochain_zero_on_boundaries
    (d₂ : Fin ne → Fin nf → R)
    (j : Fin ne → R) (f : Fin nf → R)
    (hclosed : ∀ face : Fin nf,
       (∑ edge : Fin ne, j edge * d₂ edge face) = 0) :
    (∑ edge : Fin ne, j edge *
       (∑ face : Fin nf, d₂ edge face * f face)) = 0 := by
  rw [← cellular_stokes d₂ j f]
  simp [hclosed]

end Cochains
end ChromoswarmCells
