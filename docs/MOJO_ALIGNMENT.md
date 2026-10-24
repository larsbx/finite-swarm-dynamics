# Compiled finite-field swarm alignment in Mojo

The domain-specific algorithm is `kernel/swarm_models/linear_alignment.mojo`. Scalar arithmetic (`ExactField`, `FpField`) and planar vectors (`ChromoVec2`) are imported **directly** from the pinned, canonical `finite-math-kernels` source. No copy of the field or chromogeometry kernel is maintained here.

Two exact entry points:

- `alignment_step(rows, velocities)`: computes `P V` for an algebraic row-unital `P` (every row sums to field unity). The function validates dimensions, acceptance and row sums, returning `ok=False` with no partial output on failure.
- `flock_step(rows, positions, velocities, speed)`: advances velocities simultaneously then advances positions with the *new* velocities.

The model's field arithmetic has no notion of nonnegative stochastic weights, real-valued convergence or energy dissipation. Universal finite-time consensus is characterized mathematically by nilpotence on the consensus quotient (see `docs/LINEAR_ALIGNMENT.md`). The Mojo implementation is a compiled model, **not** yet a general verifier of that theorem.

The Mojo regression exercises the three-agent directed chain over F_7 and F_13 (consensus in two steps), synchronized position updates, invalid dimensions, non-unital matrices and rejected field scalars. It is CI-gated through the exact `UPSTREAM.toml` commit and upstream Pixi toolchain.

The independent Python oracle remains under `reference/linear_alignment.py`, including exhaustive scalar-state census, and is not discarded.
