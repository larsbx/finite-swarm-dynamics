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

/-- The Gram discriminant of the blue quadratic plane is the
negative square of the join/wedge determinant. -/
theorem blue_gram_determinant (u v : K × K) :
    (u.1*v.1 + u.2*v.2)^2 -
      (u.1^2 + u.2^2)*(v.1^2 + v.2^2) =
        -(u.1*v.2 - u.2*v.1)^2 := by
  ring

/-- Independent planar directions cannot be tangent to the blue absolute.
This does not claim that the quadratic splits in the base field. -/
theorem blue_independent_discriminant_ne_zero (u v : K × K)
    (hdet : u.1*v.2 - u.2*v.1 ≠ 0) :
    (u.1*v.1 + u.2*v.2)^2 -
      (u.1^2 + u.2^2)*(v.1^2 + v.2^2) ≠ 0 := by
  rw [blue_gram_determinant]
  exact neg_ne_zero.mpr (pow_ne_zero 2 hdet)

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


/-- The regular blue-plane CK ratio is the guarded squared wedge
rather than an analytic angle. This composes the field-general Vieta
identity with the planar Gram determinant. No root splitting is claimed. -/
theorem blue_planar_ck_from_vieta (u v : K × K) (r s : K)
    (hu : u.1^2 + u.2^2 ≠ 0) (hv : v.1^2 + v.2^2 ≠ 0)
    (hr : r ≠ 0) (hs : s ≠ 0) (hfour : (4 : K) ≠ 0)
    (hsum : (v.1^2 + v.2^2)*(r+s) =
      -2*(u.1*v.1 + u.2*v.2))
    (hprod : (v.1^2 + v.2^2)*(r*s) =
      u.1^2 + u.2^2) :
    (2 - (r/s + s/r))/4 =
      (u.1*v.2 - u.2*v.1)^2 /
        ((u.1^2 + u.2^2)*(v.1^2 + v.2^2)) := by
  calc
    (2 - (r/s + s/r))/4 =
        1 - (u.1*v.1 + u.2*v.2)^2 /
          ((u.1^2 + u.2^2)*(v.1^2 + v.2^2)) :=
      cross_ratio_from_vieta
        (u.1^2 + u.2^2) (u.1*v.1 + u.2*v.2)
        (v.1^2 + v.2^2) r s
        hu hv hr hs hfour hsum hprod
    _ = (u.1*v.2 - u.2*v.1)^2 /
          ((u.1^2 + u.2^2)*(v.1^2 + v.2^2)) := by
      have hgram := blue_gram_determinant u v
      field_simp [hu, hv] <;> linear_combination -hgram

/-- Independent blue-plane directions cannot give a repeated
absolute root in odd characteristic when the Vieta identities hold.
The conclusion applies in any splitting field; it does not claim
the absolute roots already lie in the original field. -/
theorem blue_independent_roots_distinct (u v : K × K) (r s : K)
    (hdet : u.1*v.2 - u.2*v.1 ≠ 0)
    (hfour : (4 : K) ≠ 0)
    (hsum : (v.1^2 + v.2^2)*(r+s) =
      -2*(u.1*v.1 + u.2*v.2))
    (hprod : (v.1^2 + v.2^2)*(r*s) =
      u.1^2 + u.2^2) : r ≠ s := by
  intro hrs
  subst s
  have hsumSq := congrArg (fun x : K => x^2) hsum
  have hprodC := congrArg
    (fun x : K => x * (v.1^2 + v.2^2)) hprod
  have hzero :
      (4 : K) *
        ((u.1*v.1 + u.2*v.2)^2 -
         (u.1^2 + u.2^2)*(v.1^2 + v.2^2)) = 0 := by
    linear_combination -hsumSq + 4*hprodC
  have hdisc_zero :
      (u.1*v.1 + u.2*v.2)^2 -
        (u.1^2 + u.2^2)*(v.1^2 + v.2^2) = 0 :=
    (mul_eq_zero.mp hzero).resolve_left hfour
  exact (blue_independent_discriminant_ne_zero u v hdet) hdisc_zero


/-- Alternating determinant of two homogeneous representatives
on a projective line. This uses no choice of an affine chart. -/
def det2 (u v : K × K) : K := u.1*v.2 - u.2*v.1

/-- A common invertible change of homogeneous coordinates, written
as a 2-by-2 matrix with explicit scalar entries. -/
def linearFrame2 (m11 m12 m21 m22 : K) (u : K × K) : K × K :=
  (m11*u.1 + m12*u.2, m21*u.1 + m22*u.2)

/-- The determinant scales by the determinant of a frame change. -/
theorem det2_frame (m11 m12 m21 m22 : K) (u v : K × K) :
    det2 (linearFrame2 m11 m12 m21 m22 u)
      (linearFrame2 m11 m12 m21 m22 v) =
        (m11*m22 - m12*m21) * det2 u v := by
  dsimp [det2, linearFrame2]
  ring

/-- The declared determinant convention for four ordered homogeneous
vertices; a geometric interpretation requires nonzero denominators
and pairwise distinct projective vertices. -/
def cr2 (a b c d : K × K) : K :=
  (det2 a c * det2 b d) / (det2 a d * det2 b c)

/-- Intrinsic projective frame invariance, under the exact denominator
guards and a nonzero determinant of the coordinate transformation. -/
theorem cr2_frame_invariant (m11 m12 m21 m22 : K)
    (a b c d : K × K)
    (hm : m11*m22 - m12*m21 ≠ 0)
    (had : det2 a d ≠ 0)
    (hbc : det2 b c ≠ 0) :
    cr2 (linearFrame2 m11 m12 m21 m22 a)
      (linearFrame2 m11 m12 m21 m22 b)
      (linearFrame2 m11 m12 m21 m22 c)
      (linearFrame2 m11 m12 m21 m22 d) =
        cr2 a b c d := by
  simp only [cr2, det2_frame]
  have ht : ((m11*m22-m12*m21)*det2 a d) *
      ((m11*m22-m12*m21)*det2 b c) ≠ 0 :=
    mul_ne_zero (mul_ne_zero hm had) (mul_ne_zero hm hbc)
  have hb : det2 a d * det2 b c ≠ 0 := mul_ne_zero had hbc
  apply (div_eq_div_iff ht hb).2
  ring

/-- The homogeneous cross-ratio agrees with the declared root-ratio
coordinate (0,infinity;r,s) when s is nonzero. -/
theorem cr2_absolute_coordinate (r s : K) (hs : s ≠ 0) :
    cr2 (1, 0) (0, 1) (1, r) (1, s) = r/s := by
  dsimp [cr2, det2]
  field_simp [hs] <;> ring


end Algebra

end ChromoswarmCrossRatio
