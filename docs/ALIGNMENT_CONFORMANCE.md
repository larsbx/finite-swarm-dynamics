# Exact F_7 alignment conformance corpus

`conformance/alignment_F7_v1.txt` contains exactly 343 canonical lines. Each line is one scalar velocity input `(a,b,c) ∈ F_7³` followed by one output of the row-unital directed chain `P=[[0,1,0],[0,0,1],[0,0,1]]`. Canonical format:

    ALIGN7v1 a b c next_a next_b next_c

All field elements are base-10 canonical residues in `0..6`. Records follow lexicographic **enumeration order**, which is a file-format convention, not an order on field scalars.

The data contract is checked against the independent Python `ConsensusOperator` on all 343 inputs. The **compiled, pinned upstream Mojo kernel** executes its own enumeration and emits actual output; `tools/check_alignment_conformance.py` compares every generated line with the file and independent exact Python result, rejecting truncation, mutation, duplicate rows, mismatched output and noncanonical line endings.

No equivalence is asserted beyond the enumerated finite family, and no capped result is reported as an exhaustive proof outside this explicit domain. The all-state coverage here is a computational statement; it is not a Lean universal consensus theorem.
