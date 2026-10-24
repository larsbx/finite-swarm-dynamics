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

end Chromoswarm
