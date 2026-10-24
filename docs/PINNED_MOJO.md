# Pinned canonical Mojo dependency

The canonical reusable Mojo chromogeometry lives in `larsbx/finite-math-kernels` at commit `8fc4c7b3e0f7bb643a38124c99af9c397a868650` (merged PR #79). This consumer does not fork or reimplement that production geometry.

`UPSTREAM.toml` pins the upstream revision. CI checks out precisely that commit, verifies the resolved HEAD, and executes `tests/mojo/chromogeometry_consumer.mojo` against its compiled source through the upstream pinned Pixi toolchain. The smoke checks F_7 quadrances, spreads, determinant, Gram laws, and null guards.

Python modules under `reference/` remain independent exact reference oracles. This is a compiled consumer test, not an assertion of Python/Mojo full state-transition equivalence or universal Lean proof. See `docs/CONSUMER_BOUNDARY.md` and the upstream `docs/chromogeometry.md`.
