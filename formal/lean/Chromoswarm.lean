import Lean

/-!
# Chromoswarm: kernel-checked finite certificates, stage L0

These are theorems for explicitly named *small modular arithmetic domains*,
not general theorems for every finite field. All computations use Lean's
trusted decision procedure on finite types, with no `sorry`, extra axioms,
native_decide, or external test oracle.

Universal odd-characteristic algebraic proofs remain separate obligations.
-/

namespace Chromoswarm

abbrev F3 := Fin 3
abbrev F7 := Fin 7

/-- The blue, red and green planar quadrances in F_7. -/
def blue7 (x y : F7) : F7 := x*x + y*y
def red7 (x y : F7) : F7 := x*x - y*y
def green7 (x y : F7) : F7 := (2 : F7)*x*y

/-- Chromatic Pythagoras for every one of the 49 vectors over F_7. -/
theorem chromatic_pythagoras_F7 :
    ∀ x y : F7,
      blue7 x y * blue7 x y =
        red7 x y * red7 x y + green7 x y * green7 x y := by
  decide

/-- Null green quadrance does not mean vector equality to zero. -/
theorem distinct_null_green_F7 :
    green7 1 0 = 0 ∧ ((1 : F7), (0 : F7)) ≠ ((0 : F7), (0 : F7)) := by
  decide

/-- Antipodal oriented headings are distinct modulo seven. -/
theorem opposite_heading_distinct_F7 :
    ((1 : F7), (0 : F7)) ≠ ((6 : F7), (0 : F7)) := by
  decide

/-- A quarter turn represented entirely in modular arithmetic. -/
def quarterTurn7 (v : F7 × F7) : F7 × F7 := (-v.2, v.1)

/-- Every quarter turn preserves blue quadrance on F_7². -/
theorem quarter_turn_blue_invariant_F7 :
    ∀ x y : F7,
      blue7 (quarterTurn7 (x,y)).1 (quarterTurn7 (x,y)).2 = blue7 x y := by
  decide

/-- Four quarter turns equal the identity for every state over F_7. -/
theorem quarter_turn_fourth_F7 :
    ∀ x y : F7,
      quarterTurn7 (quarterTurn7 (quarterTurn7 (quarterTurn7 (x,y)))) = (x,y) := by
  decide

/-- Two-agent one-step finite alignment example over F_3. -/
def align3 (v : F3 × F3) : F3 × F3 := (v.2, v.2)

/-- All initial states reach a consensus vector in one exact update. -/
theorem align_consensus_F3 (v : F3 × F3) :
    (align3 v).1 = (align3 v).2 := rfl

/-- The consensus projection is idempotent. -/
theorem align_idempotent_F3 (v : F3 × F3) :
    align3 (align3 v) = align3 v := rfl

/-- The blue Gram determinant law over all 3^4 input quadruples. -/
def blue3 (x y : F3) : F3 := x*x+y*y
def polarBlue3 (a b c d : F3) : F3 := a*c+b*d
def determinant3 (a b c d : F3) : F3 := a*d-b*c

theorem blue_gram_F3 :
    ∀ a b c d : F3,
      blue3 a b * blue3 c d -
        polarBlue3 a b c d * polarBlue3 a b c d =
        determinant3 a b c d * determinant3 a b c d := by
  decide


/-!
## F₇ two-oscillator phase certificates, the actual formula

The eight oriented blue-unit headings are Fin 8; proof obligations check
both exhaustive coverage and the field-arithmetic dynamics (no lookup table).
Cayley denominators use their Fermat inverse d^5 when d is nonzero.
-/
abbrev Phase7Heading := F7 × F7
abbrev Phase7State := Phase7Heading × Phase7Heading

def unitHeading7 (i : Fin 8) : Phase7Heading :=
  match i.val with
  | 0 => (0, 1)
  | 1 => (0, 6)
  | 2 => (1, 0)
  | 3 => (2, 2)
  | 4 => (2, 5)
  | 5 => (5, 2)
  | 6 => (5, 5)
  | _ => (6, 0)

def norm7 (u : Phase7Heading) : F7 := u.1*u.1 + u.2*u.2

def determinant7 (u v : Phase7Heading) : F7 :=
  u.1*v.2 - u.2*v.1

def rotateByCayley7 (u : Phase7Heading) (t : F7) : Phase7Heading :=
  let den := (1 : F7) + t*t
  if den = 0 then (-u.1, -u.2)
  else
    let c := ((1 : F7) - t*t)*den^5
    let s := (2 : F7)*t*den^5
    (c*u.1 - s*u.2, s*u.1 + c*u.2)

def phaseStep7 (state : Phase7State) : Phase7State :=
  let t := determinant7 state.1 state.2
  (rotateByCayley7 state.1 t, rotateByCayley7 state.2 (-t))

/-- Every enumerated heading has unit blue quadrance. -/
theorem unitHeading7_sound :
    ∀ i : Fin 8, norm7 (unitHeading7 i) = 1 := by
  decide

/-- The eight headings exhaust the unit-blue conic of F₇². -/
theorem unitHeading7_complete :
    ∀ x y : F7, x*x + y*y = 1 →
      ∃ i : Fin 8, unitHeading7 i = (x,y) := by
  decide

/-- Each exact nonlinear phase update retains unit-blue headings. -/
theorem phaseStep7_preserves_units :
    ∀ i j : Fin 8,
      let output := phaseStep7 (unitHeading7 i, unitHeading7 j)
      norm7 output.1 = 1 ∧ norm7 output.2 = 1 := by
  decide

/-- Exhaustive nonlinear F₇ phase certificate: F³ = F. -/
theorem phaseStep7_three_eq_one :
    ∀ i j : Fin 8,
      let initial := (unitHeading7 i, unitHeading7 j)
      phaseStep7 (phaseStep7 (phaseStep7 initial)) = phaseStep7 initial := by
  decide

/-- Zero alternating coupling characterizes the exact fixed states. -/
theorem phaseStep7_fixed_iff_det_zero :
    ∀ i j : Fin 8,
      let u := unitHeading7 i
      let v := unitHeading7 j
      (phaseStep7 (u,v) = (u,v)) ↔ determinant7 u v = 0 := by
  decide

end Chromoswarm
