import Mathlib

/-! General exact chromogeometry and rational symmetric two-agent consensus.
All results are polynomial or ordered rational identities, without analytic limits. -/
namespace ChromoswarmGeneral

section Chromatic
variable {R : Type*} [CommRing R]

def blue (x y : R) : R := x*x + y*y
def red (x y : R) : R := x*x - y*y
def green (x y : R) : R := 2*x*y
def wedge (x y u v : R) : R := x*v-y*u

theorem chromatic_pythagoras (x y : R) :
    (blue x y)^2 = (red x y)^2 + (green x y)^2 := by
  dsimp [blue, red, green]
  ring

theorem blue_gram (x y u v : R) :
    blue x y * blue u v - (x*u+y*v)^2 = (wedge x y u v)^2 := by
  dsimp [blue, wedge]
  ring

theorem red_gram (x y u v : R) :
    red x y * red u v - (x*u-y*v)^2 = -(wedge x y u v)^2 := by
  dsimp [red, wedge]
  ring

theorem green_gram (x y u v : R) :
    green x y * green u v - (x*v+y*u)^2 = -(wedge x y u v)^2 := by
  dsimp [green, wedge]
  ring

theorem mixed_chromatic (x y u v : R) :
    blue x y * blue u v - red x y * red u v -
      green x y * green u v = 2*(wedge x y u v)^2 := by
  dsimp [blue, red, green, wedge]
  ring
end Chromatic

section RationalConsensus
def average2 (a v w : ℚ) : ℚ × ℚ :=
  ((1-a)*v+a*w, a*v+(1-a)*w)

theorem average2_sum (a v w : ℚ) :
    (average2 a v w).1 + (average2 a v w).2 = v+w := by
  dsimp [average2]
  ring

theorem average2_difference (a v w : ℚ) :
    (average2 a v w).1 - (average2 a v w).2 = (1-2*a)*(v-w) := by
  dsimp [average2]
  ring

theorem average2_energy (a v w : ℚ) :
    ((average2 a v w).1-(average2 a v w).2)^2 =
      (1-2*a)^2*(v-w)^2 := by
  rw [average2_difference]
  ring

theorem rational_factor_le_one (a : ℚ) (ha : 0 ≤ a) (hb : a ≤ 1) :
    (1-2*a)^2 ≤ 1 := by
  have h : 0 ≤ a*(1-a) := mul_nonneg ha (sub_nonneg.mpr hb)
  nlinarith

theorem average2_energy_nonincrease (a v w : ℚ)
    (ha : 0 ≤ a) (hb : a ≤ 1) :
    ((average2 a v w).1-(average2 a v w).2)^2 ≤ (v-w)^2 := by
  rw [average2_energy]
  have hf := rational_factor_le_one a ha hb
  have hv : 0 ≤ (v-w)^2 := sq_nonneg _
  nlinarith

def averageVec (a : ℚ) (v w : ℚ × ℚ) : (ℚ × ℚ) × (ℚ × ℚ) :=
  (((average2 a v.1 w.1).1, (average2 a v.2 w.2).1),
   ((average2 a v.1 w.1).2, (average2 a v.2 w.2).2))

def blueDisagreement (v w : ℚ × ℚ) : ℚ :=
  (v.1-w.1)^2+(v.2-w.2)^2

theorem averageVec_energy (a : ℚ) (v w : ℚ × ℚ) :
    blueDisagreement (averageVec a v w).1 (averageVec a v w).2 =
      (1-2*a)^2 * blueDisagreement v w := by
  dsimp [blueDisagreement, averageVec, average2]
  ring

theorem averageVec_energy_nonincrease (a : ℚ) (v w : ℚ × ℚ)
    (ha : 0 ≤ a) (hb : a ≤ 1) :
    blueDisagreement (averageVec a v w).1 (averageVec a v w).2 ≤
      blueDisagreement v w := by
  rw [averageVec_energy]
  have hf := rational_factor_le_one a ha hb
  have hd : 0 ≤ blueDisagreement v w := by
    dsimp [blueDisagreement]
    positivity
  nlinarith
end RationalConsensus

/-! ### Guarded rational trigonometry over exact fields -/
section GuardedGeometry
variable {K : Type*} [Field K]

theorem blue_spread_guard (x y u v : K)
    (h : blue x y * blue u v ≠ 0) :
    (1:K) - (x*u+y*v)^2/(blue x y * blue u v) =
      (wedge x y u v)^2/(blue x y * blue u v) := by
  calc
    (1:K) - (x*u+y*v)^2/(blue x y * blue u v)
        = (blue x y * blue u v - (x*u+y*v)^2)/(blue x y * blue u v) := by
          rw [sub_div, div_self h]
    _ = (wedge x y u v)^2/(blue x y * blue u v) := by
      rw [blue_gram]

theorem red_spread_guard (x y u v : K)
    (h : red x y * red u v ≠ 0) :
    (1:K) - (x*u-y*v)^2/(red x y * red u v) =
      -(wedge x y u v)^2/(red x y * red u v) := by
  calc
    (1:K) - (x*u-y*v)^2/(red x y * red u v)
        = (red x y * red u v - (x*u-y*v)^2)/(red x y * red u v) := by
          rw [sub_div, div_self h]
    _ = -(wedge x y u v)^2/(red x y * red u v) := by
      rw [red_gram]

theorem green_spread_guard (x y u v : K)
    (h : green x y * green u v ≠ 0) :
    (1:K) - (x*v+y*u)^2/(green x y * green u v) =
      -(wedge x y u v)^2/(green x y * green u v) := by
  calc
    (1:K) - (x*v+y*u)^2/(green x y * green u v)
        = (green x y * green u v-(x*v+y*u)^2)/(green x y * green u v) := by
          rw [sub_div, div_self h]
    _ = -(wedge x y u v)^2/(green x y * green u v) := by
      rw [green_gram]

def cayleyC (t : K) : K := (1-t^2)/(1+t^2)
def cayleyS (t : K) : K := (2*t)/(1+t^2)

theorem cayley_unit (t : K) (h : (1:K)+t^2 ≠ 0) :
    (cayleyC t)^2+(cayleyS t)^2=1 := by
  dsimp [cayleyC, cayleyS]
  field_simp [h]
  ring
end GuardedGeometry

section ChromaticCovariance
variable {R : Type*} [CommRing R]

theorem red_rotation_covariant (c s x y : R) :
    red (c*x-s*y) (s*x+c*y) =
      (c^2-s^2)*red x y - (2*c*s)*green x y := by
  dsimp [red,green]
  ring

theorem green_rotation_covariant (c s x y : R) :
    green (c*x-s*y) (s*x+c*y) =
      (2*c*s)*red x y + (c^2-s^2)*green x y := by
  dsimp [red,green]
  ring
end ChromaticCovariance

theorem rational_cayley_den_nonzero (t : ℚ) :
    (1:ℚ)+t^2 ≠ 0 := by
  have h : 0 < (1:ℚ)+t^2 := by positivity
  exact ne_of_gt h

theorem rational_cayley_unit (t : ℚ) :
    (cayleyC t)^2+(cayleyS t)^2=1 :=
  cayley_unit t (rational_cayley_den_nonzero t)

end ChromoswarmGeneral
