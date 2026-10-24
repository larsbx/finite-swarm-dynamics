# Batched exact Mojo alignment: correctness-first CPU baseline

A single algebraically row-unital N×N finite-field matrix is applied to B
independent length-N affine position/velocity states. The batched result
reuses the canonical `ExactField`, `ChromoVec2`, and local `FlockStep`
contracts. Its observable transition is precisely

    Vᵇ⁺ = P Vᵇ
    Xᵇ⁺ = Xᵇ + ν Vᵇ⁺

for every batch b. All supplied row sums equal field unity. That does not
imply stochastic or positive weights.

The implementation validates field acceptance, dimensions, row sums, speed
and all input coordinates across *all* batches before computing outputs.
It refuses malformed input rather than returning a truncated or partially
successful result. The compiled smoke covers five simultaneous trajectories
for each of F₇ and F₁₃, compares every coordinate against the existing serial
Mojo implementation, confirms two-step directed-chain consensus, and verifies
all-or-nothing rejection of one malformed trajectory.

This is **batched CPU Mojo**, not a MAX/GPU backend and not a measured
speedup. A later MAX backend may fuse arithmetic and memory operations,
but must first reproduce this exact-field interface and the conformance
datasets and report actual benchmarks separately. Non-power-of-two field
modular arithmetic, guards, and deterministic replay remain mandatory.
