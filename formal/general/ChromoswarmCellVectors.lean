import ChromoswarmCells
import Mathlib

/-! Kernel-checked consumer tests for generic SGC-2 cell geometry and Stokes.
These examples intentionally import a previously nonexistent proof module
before its implementation is committed (red-first TDD). -/
namespace ChromoswarmCellVectors
open ChromoswarmCells

example (R : Type*) [CommRing R] (a b c d : R) :
    (b - a) + (d - b) + (c - d) + (a - c) = 0 :=
  quadrilateral_boundary_closed a b c d

example (a b c : ℚ × ℚ) :
    wedge (minus b a) (minus (plus (minus b a) c) c) = 0 ∧
    wedge (minus c a) (minus (plus (minus b a) c) b) = 0 :=
  parallelogram_zero_wedges a b c

example (a b c d : ℚ × ℚ)
    (hn : wedge (minus b a) (minus c a) ≠ 0) :
    (wedge (minus b a) (minus d c) = 0 ∧
     wedge (minus c a) (minus d b) = 0) ↔
       d = plus (minus b a) c :=
  parallelogram_iff a b c d hn

example {K : Type*} [CommRing K]
    (d₂ : Fin 4 → Fin 2 → K)
    (j : Fin 4 → K) (f : Fin 2 → K) :
    (∑ face : Fin 2, (∑ edge : Fin 4, j edge * d₂ edge face) * f face) =
      ∑ edge : Fin 4, j edge * (∑ face : Fin 2, d₂ edge face * f face) :=
  cellular_stokes d₂ j f

end ChromoswarmCellVectors
