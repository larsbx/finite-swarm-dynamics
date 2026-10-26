"""Quote finite route witnesses and expected rational values into Lean."""
import argparse
import json
from pathlib import Path

from tools.strict_variance_vectors import rat, vector
from tools.contraction_vectors import FINITE

ROOT = Path(__file__).resolve().parents[1]
VECTORS = ROOT / "conformance/rational_routes_Q_v1.json"
TARGET = ROOT / "formal/general/ChromoswarmRouteVectors.lean"
FINITE_ROUTES = FINITE + ", Matrix.cons_val_four"


def render():
    data = json.loads(VECTORS.read_text())
    assert data["schema"] == "rational_routes_Q_v1"
    parts = ["""import ChromoswarmRoutes
import ChromoswarmContractionVectors

/-! Generated from finite route witnesses and fixed exact expectations.
Each route is verified in Lean; the renderer does not prove connectivity. -/
namespace ChromoswarmRouteVectors
open ChromoswarmJensen ChromoswarmPlanar ChromoswarmStrict ChromoswarmContraction
set_option maxRecDepth 8192
set_option maxHeartbeats 3000000
"""]
    for c in data["cases"]:
        name = c["id"]
        assert name.replace("_", "").isalnum()
        n = len(c["matrix"])
        matrix = vector([vector([rat(x) for x in row]) for row in c["matrix"]])
        state = vector(["(" + ", ".join(rat(x) for x in row) + ")" for row in c["velocities"]])
        eta, length, steps = rat(c["eta"]), c["max_length"], c["steps"]
        assert type(length) is int and length >= 1
        assert type(steps) is int and steps >= 0
        parts.append(f"""
def {name}_P : Fin {n} → Fin {n} → ℚ := {matrix}
def {name}_v : Fin {n} → ℚ × ℚ := {state}

theorem {name}_routes : ChromoswarmRoutes.Routes Finset.univ {name}_P {eta} {length} := by
  intro j _ k _
  fin_cases j <;> fin_cases k
""")
        for j in range(n):
            for k in range(n):
                path = c["routes"][j][k]
                assert path and all(type(x) is int and 0 <= x < n for x in path)
                p = str(path[-1])
                for t in reversed(range(len(path)-1)):
                    p = f"if t = {t} then {path[t]} else ({p})"
                edge_tactic = ("omega" if len(path) == 1 else
                                f"interval_cases t\n      all_goals norm_num [overlap, {name}_P, {FINITE_ROUTES}]")
                parts.append(f"""  · refine ⟨{len(path)-1}, by norm_num, (fun t => {p}), ?_, ?_, ?_, ?_⟩
    · decide
    · decide
    · intro t ht; simp
    · intro t ht
      {edge_tactic}
""")
        parts.append(f"""
theorem {name}_certified : ChromoswarmRoutes.Certified Finset.univ {name}_P {eta} {length} := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, {name}_routes⟩ <;>
    norm_num [{name}_P, {FINITE_ROUTES}]

theorem {name}_values :
    ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin {n})) {eta} {length} = {rat(c['coefficient'])} ∧
    1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin {n})) {eta} {length} = {rat(c['rate'])} ∧
    blueVariance Finset.univ {name}_v = {rat(c['initial_variance'])} ∧
    blueVariance Finset.univ (evolve Finset.univ {name}_P {name}_v {steps}) = {rat(c['final_variance'])} ∧
    {rat(c['rate'])}^{steps} * {rat(c['initial_variance'])} = {rat(c['bound'])} := by
  norm_num [ChromoswarmRoutes.coefficient, {name}_P, {name}_v,
    evolve, blueVariance, variance, applyVec, apply, {FINITE_ROUTES}]

theorem {name}_bound :
    blueVariance Finset.univ (evolve Finset.univ {name}_P {name}_v {steps}) ≤
    (1 - ChromoswarmRoutes.coefficient (Finset.univ : Finset (Fin {n})) {eta} {length})^{steps} *
      blueVariance Finset.univ {name}_v :=
  ChromoswarmRoutes.finite_horizon_bound Finset.univ {name}_P {name}_v _ _
    (by simp) {name}_certified {steps}
""")
    parts.append(f"""
theorem swap_disconnected (η : ℚ) (hη : 0 < η) (L : ℕ) :
    ¬ ChromoswarmRoutes.Routes Finset.univ ChromoswarmStrictVectors.permutation_P η L := by
  intro hr
  have he (a : Fin 2) (_ha : a ∈ Finset.univ) (b : Fin 2) (_hb : b ∈ Finset.univ)
      (hab : η ≤ overlap Finset.univ ChromoswarmStrictVectors.permutation_P a b) : a = b := by
    fin_cases a <;> fin_cases b
    all_goals first | rfl | (norm_num [overlap, ChromoswarmStrictVectors.permutation_P, {FINITE_ROUTES}] at hab; linarith)
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
      norm_num [overlap, ChromoswarmStrictVectors.block_equality_P, {FINITE_ROUTES}] at hab ⊢ <;> linarith
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
    norm_num [overlap, cycle4_P, {FINITE_ROUTES}] at hb

end ChromoswarmRouteVectors
""")
    return "".join(parts)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = render()
    if args.check:
        if TARGET.read_text() != expected:
            raise SystemExit("Lean route vectors are stale; run python -m tools.route_vectors")
    else:
        TARGET.write_text(expected)
