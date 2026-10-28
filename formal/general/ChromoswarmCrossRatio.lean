import Mathlib

/-!
# SGC-3: Exact Cayley–Klein root-ratio algebra

Let Q(u+t v)=a+2bt+ct². Over a splitting field the two absolute
intersections have nonzero root parameters r,s provided a,c≠0.
With the affine coordinate sending [u] to 0 and [v] to infinity,
rho=cr(0,infinity;r,s)=r/s, under the declared cross-ratio convention.

Theorems below prove the symmetric ratio identity using Vieta data.
They do not identify a geometric point at infinity with an oriented
heading, introduce an order on finite fields, or require a square root.
Ordinary cross-ratio interpretation is restricted to distinct roots.
-/

namespace ChromoswarmCrossRatio

section Algebra
variable {K : Type*} [Field K]

/-- Interchanging the two roots inverts their nonzero cross-ratio
parameter. This is the symmetry that can arise from Galois exchange
when the quadratic is nonsplit over the base field. -/
theorem swapped_root_ratios_multiply_one (r s : K)
    (hr : r ≠ 0) (hs : s ≠ 0) :
    (r/s) * (s/r) = 1 := by
  field_simp [hr, hs]

/-- The symmetric normalized ratio is the algebraic spread.
Assumptions are exactly the two Vieta relations and guarded division
in the quadratic field, with 4≠0 (characteristic not two).
No distinct-roots assumption is needed for this *rational identity*. -/
theorem cross_ratio_from_vieta (a b c r s : K)
    (ha : a ≠ 0) (hc : c ≠ 0)
    (hr : r ≠ 0) (hs : s ≠ 0)
    (hfour : (4 : K) ≠ 0)
    (hsum : c*(r+s) = -2*b)
    (hprod : c*(r*s) = a) :
    (2 - (r/s + s/r))/4 = 1 - b^2/(a*c) := by
  have hsumsq : c^2*(r+s)^2 = 4*b^2 := by
    calc
      c^2*(r+s)^2 = (c*(r+s))^2 := by ring
      _ = (-2*b)^2 := by rw [hsum]
      _ = 4*b^2 := by ring
  have hkey : a*c*(r+s)^2 = 4*b^2*(r*s) := by
    calc
      a*c*(r+s)^2 = (c*(r*s))*c*(r+s)^2 := by rw [hprod]
      _ = (c^2*(r+s)^2)*(r*s) := by ring
      _ = 4*b^2*(r*s) := by rw [hsumsq]
  have hratio :
      (2 - (r/s + s/r))/4 =
        (4*r*s-(r+s)^2)/(4*r*s) := by
    field_simp [hr, hs, hfour]
    ring
  have hmain :
      (4*r*s-(r+s)^2)/(4*r*s) =
        (a*c-b^2)/(a*c) := by
    field_simp [ha, hc, hr, hs, hfour]
    linear_combination -hkey
  calc
    (2 - (r/s + s/r))/4 =
        (4*r*s-(r+s)^2)/(4*r*s) := hratio
    _ = (a*c-b^2)/(a*c) := hmain
    _ = 1 - b^2/(a*c) := by
      field_simp [ha, hc]
      ring

/-- On the regular distinct-absolute-intersection locus the same
ratio is the ordinary four-distinct-points Cayley–Klein expression.
The distinctness hypothesis is intentionally absent from the
underlying algebraic extension theorem. -/
theorem ordinary_cross_ratio_spread (a b c r s : K)
    (ha : a ≠ 0) (hc : c ≠ 0)
    (hr : r ≠ 0) (hs : s ≠ 0) (hrs : r ≠ s)
    (hfour : (4 : K) ≠ 0)
    (hsum : c*(r+s) = -2*b)
    (hprod : c*(r*s) = a) :
    (2 - (r/s + s/r))/4 = 1 - b^2/(a*c) :=
  cross_ratio_from_vieta a b c r s ha hc hr hs hfour hsum hprod


/-- Vieta conditions follow from two *distinct* roots of
a+2bt+ct². This is an exact field identity, not a claim about
splitting over the base field. -/
theorem vieta_from_distinct_quadratic_roots (a b c r s : K)
    (hrs : r ≠ s)
    (hrootr : a + 2*b*r + c*r^2 = 0)
    (hroots : a + 2*b*s + c*s^2 = 0) :
    c*(r+s) = -2*b ∧ c*(r*s) = a := by
  have hfactor : (r-s)*(2*b+c*(r+s)) = 0 := by
    calc
      (r-s)*(2*b+c*(r+s)) =
          (a+2*b*r+c*r^2)-(a+2*b*s+c*s^2) := by ring
      _ = 0 := by rw [hrootr, hroots]; ring
  have hcoef : 2*b+c*(r+s) = 0 :=
    (mul_eq_zero.mp hfactor).resolve_left (sub_ne_zero.mpr hrs)
  constructor
  · linear_combination hcoef
  · linear_combination -hrootr + r*hcoef

/-- CK spread directly from two distinct quadratic absolute roots.
This turns the Vieta interface into a derived theorem on the regular
split locus (over whichever field contains both absolute roots). -/
theorem regular_ck_from_quadratic_roots (a b c r s : K)
    (ha : a ≠ 0) (hc : c ≠ 0)
    (hr : r ≠ 0) (hs : s ≠ 0)
    (hrs : r ≠ s) (hfour : (4 : K) ≠ 0)
    (hrootr : a + 2*b*r + c*r^2 = 0)
    (hroots : a + 2*b*s + c*s^2 = 0) :
    (2 - (r/s+s/r))/4 = 1 - b^2/(a*c) := by
  obtain ⟨hsum,hprod⟩ :=
    vieta_from_distinct_quadratic_roots a b c r s hrs hrootr hroots
  exact ordinary_cross_ratio_spread a b c r s
    ha hc hr hs hrs hfour hsum hprod


end Algebra

end ChromoswarmCrossRatio
