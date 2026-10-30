import ChromoswarmCrossRatio
import Mathlib

/-! SGC-3 examples: explicit split quadratic roots and the involution.
Independent consumer root committed before the theorem module. -/

namespace ChromoswarmCrossRatioVectors
open ChromoswarmCrossRatio

-- ZMod has a field instance only once primality of the modulus is supplied.
-- Keep this as an explicit, kernel-checked finite-field input.
local instance : Fact (Nat.Prime 7) := ⟨by decide⟩

/-- In F7: Q(u+t v) = 1 + 2t + t² has a repeated root,
but root-ratio algebra remains defined. This is not an ordinary
four-distinct-points cross-ratio. -/
example :
    (((2 : ZMod 7) -
      (((6 : ZMod 7) / (6 : ZMod 7)) +
       ((6 : ZMod 7) / (6 : ZMod 7)))) / (4 : ZMod 7) : ZMod 7) =
      (1 : ZMod 7) - (1 : ZMod 7)^2 / ((1 : ZMod 7) * (1 : ZMod 7)) := by
  decide

/-- Nondegenerate example with two distinct nonzero split roots. -/
example :
    (((2 : ZMod 7) -
      (((1 : ZMod 7) / (2 : ZMod 7)) +
       ((2 : ZMod 7) / (1 : ZMod 7)))) / (4 : ZMod 7) : ZMod 7) =
      (1 : ZMod 7) - (2 : ZMod 7)^2 / ((2 : ZMod 7) * (1 : ZMod 7)) := by
  decide

example (a b c r s : ℚ)
    (ha : a ≠ 0) (hc : c ≠ 0) (hr : r ≠ 0) (hs : s ≠ 0)
    (hadd : c * (r+s) = -2*b) (hmul : c * (r*s) = a) :
    (2 - (r/s + s/r))/4 = 1 - b^2/(a*c) :=
  cross_ratio_from_vieta a b c r s ha hc hr hs (by norm_num) hadd hmul

/-- A nonzero planar wedge forces a regular blue discriminant. -/
example (u v : (ZMod 7) × (ZMod 7))
    (hdet : u.1*v.2 - u.2*v.1 ≠ 0) :
    (u.1*v.1 + u.2*v.2)^2 -
      (u.1^2 + u.2^2)*(v.1^2 + v.2^2) ≠ 0 :=
  blue_independent_discriminant_ne_zero u v hdet


/-- Separate consumer of the combined planar wedge/rational CK theorem. -/
example {K : Type*} [Field K] (u v : K × K) (r s : K)
    (hu : u.1^2 + u.2^2 ≠ 0) (hv : v.1^2 + v.2^2 ≠ 0)
    (hr : r ≠ 0) (hs : s ≠ 0) (hfour : (4 : K) ≠ 0)
    (hsum : (v.1^2 + v.2^2)*(r+s) =
      -2*(u.1*v.1 + u.2*v.2))
    (hprod : (v.1^2 + v.2^2)*(r*s) =
      u.1^2 + u.2^2) :
    (2 - (r/s + s/r))/4 =
      (u.1*v.2 - u.2*v.1)^2 /
        ((u.1^2 + u.2^2)*(v.1^2 + v.2^2)) :=
  blue_planar_ck_from_vieta u v r s
    hu hv hr hs hfour hsum hprod

/-- Regular blue-planar roots are distinct even after field extension. -/
example {K : Type*} [Field K] (u v : K × K) (r s : K)
    (hdet : u.1*v.2 - u.2*v.1 ≠ 0)
    (hfour : (4 : K) ≠ 0)
    (hsum : (v.1^2 + v.2^2)*(r+s) =
      -2*(u.1*v.1 + u.2*v.2))
    (hprod : (v.1^2 + v.2^2)*(r*s) =
      u.1^2 + u.2^2) : r ≠ s :=
  blue_independent_roots_distinct u v r s hdet hfour hsum hprod

end ChromoswarmCrossRatioVectors
