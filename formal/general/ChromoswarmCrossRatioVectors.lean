import ChromoswarmCrossRatio
import Mathlib

/-! SGC-3 examples: explicit split quadratic roots and the involution.
Independent consumer root committed before the theorem module. -/

namespace ChromoswarmCrossRatioVectors
open ChromoswarmCrossRatio

/-- In F7: Q(u+t v) = 1 + 2t + t² has a repeated root,
but root-ratio algebra remains defined. This is not an ordinary
four-distinct-points cross-ratio. -/
example :
    ((2 : ZMod 7) -
      (((6 : ZMod 7) / (6 : ZMod 7)) +
       ((6 : ZMod 7) / (6 : ZMod 7)))) / (4 : ZMod 7) =
      (1 : ZMod 7) - (1 : ZMod 7)^2 / ((1 : ZMod 7) * (1 : ZMod 7)) := by
  decide

/-- Nondegenerate example with two distinct nonzero split roots. -/
example :
    ((2 : ZMod 7) -
      (((1 : ZMod 7) / (2 : ZMod 7)) +
       ((2 : ZMod 7) / (1 : ZMod 7)))) / (4 : ZMod 7) =
      (1 : ZMod 7) - (2 : ZMod 7)^2 / ((2 : ZMod 7) * (1 : ZMod 7)) := by
  decide

example (a b c r s : ℚ)
    (ha : a ≠ 0) (hc : c ≠ 0) (hr : r ≠ 0) (hs : s ≠ 0)
    (hadd : c * (r+s) = -2*b) (hmul : c * (r*s) = a) :
    (2 - (r/s + s/r))/4 = 1 - b^2/(a*c) :=
  cross_ratio_from_vieta a b c r s ha hc hr hs (by norm_num) hadd hmul

end ChromoswarmCrossRatioVectors
