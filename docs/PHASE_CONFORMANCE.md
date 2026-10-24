# Exact finite phase and modal conformance, v1

Two deliberately finite, complete configurations over the algebraic *oriented*
blue-unit conic of F_7. Its eight elements are enumerated by increasing
canonical coordinate residues in the data encoding (not by a field ordering).

- **PHASE7v1:** all 8² = 64 ordered pairs of rotor headings. Symmetric
  interaction weights, zero diagonal, coupling 1, identity phase lag and
  natural rotation. Eight coefficients represent two input and two output
  headings. This includes antipodal pairs and synchronized pairs.
- **MODAL7v1:** all 8³ = 512 ordered three-agent heading triples, with
  all-to-all observation excluding self, self included by the update,
  identical zero positions, speed 0, and identity supplied finite noise
  rotors. Twelve coefficients represent three input and three output
  oriented headings.

The 576 lines of `conformance/phase_F7_v1.txt` are versioned, deterministic
and complete over **these specific parameterized families**. The compiled
pinned upstream Mojo implementation independently enumerates all inputs and
prints actual outputs. The checker compares every line with an independent
exact Python model and the immutable corpus. It refuses a missing final
newline, truncation, invalid ordering, duplicate/mutated rows and model
disagreement. It never extrapolates to arbitrary weights, agents, other
fields, noise processes, or real/complex classical model equivalence.

Run `python -m unittest discover -s . -v` for the Python oracle corpus,
and the `canonical-mojo` Actions job for the compiled differential replay.
