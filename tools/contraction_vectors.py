"""Quote fixed overlap-certificate vectors as ordinary Lean proofs."""
import argparse
import json
from pathlib import Path

from tools.strict_variance_vectors import rat, vector

ROOT = Path(__file__).resolve().parents[1]
VECTORS = ROOT / "conformance/rational_contraction_Q_v1.json"
TARGET = ROOT / "formal/general/ChromoswarmContractionVectors.lean"
FINITE = "Fin.forall_fin_succ, Fin.exists_fin_succ, Fin.sum_univ_succ, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail"


def render():
    data = json.loads(VECTORS.read_text())
    assert data["schema"] == "rational_contraction_Q_v1"
    parts = ["""import ChromoswarmContraction
import ChromoswarmStrictVectors

/-! Generated from fixed rational expectations, without calculating them.
The kernel checker also retains the earlier strictness regression imports. -/
namespace ChromoswarmContractionVectors
open ChromoswarmJensen ChromoswarmPlanar ChromoswarmStrict ChromoswarmContraction
set_option maxRecDepth 8192
set_option maxHeartbeats 2000000
"""]
    for c in data["cases"]:
        name = c["id"]
        assert name.replace("_", "").isalnum()
        n = len(c["matrix"])
        matrix = vector([vector([rat(x) for x in row]) for row in c["matrix"]])
        state = vector(["(" + ", ".join(rat(x) for x in row) + ")" for row in c["velocities"]])
        step = c["steps"]
        assert type(step) is int and step >= 0
        parts.append(f"""
def {name}_P : Fin {n} → Fin {n} → ℚ := {matrix}
def {name}_v : Fin {n} → ℚ × ℚ := {state}

theorem {name}_certified : Certified Finset.univ {name}_P {rat(c['eta'])} := by
  norm_num [Certified, overlapBound, overlap, {name}_P, {FINITE}]

theorem {name}_values :
    1 - ({n} : ℚ) * {rat(c['eta'])} = {rat(c['rate'])} ∧
    blueVariance Finset.univ {name}_v = {rat(c['initial_variance'])} ∧
    blueVariance Finset.univ (evolve Finset.univ {name}_P {name}_v {step}) = {rat(c['final_variance'])} ∧
    {rat(c['rate'])}^{step} * {rat(c['initial_variance'])} = {rat(c['bound'])} := by
  norm_num [{name}_P, {name}_v, evolve, blueVariance, variance,
    applyVec, apply, {FINITE}]

-- Instantiate the general finite-horizon theorem, independently of evaluation.
theorem {name}_bound :
    blueVariance Finset.univ (evolve Finset.univ {name}_P {name}_v {step}) ≤
      (1 - ((Finset.univ : Finset (Fin {n})).card : ℚ) * {rat(c['eta'])})^{step} * blueVariance Finset.univ {name}_v :=
  finite_horizon_bound Finset.univ {name}_P {name}_v _ (by simp) {name}_certified {step}
""")
        if "overlap_0_1" in c:
            parts.append(f"""
theorem {name}_orientation :
    overlap Finset.univ {name}_P 0 1 = {rat(c['overlap_0_1'])} ∧
    (∑ j, {name}_P 0 j * {name}_P 1 j) = {rat(c['row_dot_0_1'])} := by
  norm_num [overlap, {name}_P, {FINITE}]
""")
    parts.append(f"""
-- Overstated overlap fails even though its proposed rate would be in [0,1].
theorem overstated_overlap_rejected : ¬ Certified Finset.univ thirds_P (1/2) := by
  norm_num [Certified, overlapBound, overlap, thirds_P, {FINITE}]

-- A singleton still needs the explicit rate guard (pair overlap is vacuous).
theorem negative_rate_rejected : ¬ Certified Finset.univ singleton_P 2 := by
  norm_num [Certified, overlapBound, overlap, singleton_P, {FINITE}]

theorem signed_weights_rejected (η : ℚ) :
    ¬ Certified Finset.univ ChromoswarmStrictVectors.signed_growth_P η := by
  intro h
  apply ChromoswarmStrictVectors.signed_growth_nonnegative
  intro i j
  exact h.2.2.1 i (by simp) j (by simp)

theorem missing_columns_rejected (η : ℚ) :
    ¬ Certified Finset.univ ChromoswarmStrictVectors.missing_column_P η := by
  intro h
  apply ChromoswarmStrictVectors.missing_column_column_unital
  intro j
  exact h.2.1 j (by simp)

end ChromoswarmContractionVectors
""")
    return "".join(parts)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = render()
    if args.check:
        if TARGET.read_text() != expected:
            raise SystemExit("Lean vectors are stale; run python -m tools.contraction_vectors")
    else:
        TARGET.write_text(expected)
