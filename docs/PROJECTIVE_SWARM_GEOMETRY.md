# SGC-1: guarded Cayley–Klein swarm cells and exact chain certificates

**Status (2026-10-27):** compiled finite-field Mojo geometry/cellular diagnostics with independent Python oracle and pinned conformance regressions. These are **configuration and chain invariants**, not a proof of convergence, persistence barcodes, or physical vorticity. Reusable field/RT arithmetic comes exclusively from pinned `finite-math-kernels`.

## 1. Geometric domain

In a quadratic plane `V=F²` of odd characteristic choose the blue form
`Q(x,y)=x²+y²`, `B(u,v)=u_x v_x+u_y v_y`. The absolute in the
projective line at infinity is `Ω={[u]:Q(u)=0}`. For nonisotropic
`u,v`, rational-trigonometric spread is

```
s_Q([u],[v]) = 1 - B(u,v)^2/(Q(u) Q(v))
             = det(u,v)^2/(Q(u) Q(v)).
```

The second identity uses the planar Gram determinant. The spread
is invariant under rescaling either representative; it is **not**
an oriented angle, and `[u]=[-u]`. Zero spread means exactly equal
projective directions in this nondegenerate quadratic **plane**,
but not in every higher-dimensional quadratic space.

For distinct independent `[u],[v]` with two distinct absolute
intersections, the ordinary Cayley–Klein cross-ratio formula is
`s=(2-(ρ+ρ⁻¹))/4`. The **algebraic** spread extends across tangent
lines where the ordinary cross-ratio construction degenerates.
Concrete higher-dimensional F5 tangent counterexample:
`u=(1,0,0), v=(1,1,2)`, `Q(u)=Q(v)=B(u,v)=1`,
`s=0` but `[u] != [v]`.

An isotropic direction is **invalid**, not zero spread.
No finite-field `<=` or concept of positive/negative angle is used.

## 2. Quad cell predicate (SGC-1)

Vertices are in affine `F²`. Candidate boundary is the oriented
cycle `A -> B -> D -> C -> A` and must exist as four interaction
edges `AB, BD, DC, CA`. Input order to the compiled kernel is
`check_quad_cell(a,b,c,d,boundary_edges,permitted_spreads)`.

Admissibility requires: odd-characteristic field, accepted scalars,
exactly four edge flags, distinct vertices, noncollinear `A,B,C`,
no three collinear among `A,B,C,D` (to make the admission\nindependent of cyclic re-rooting), and nonisotropic vectors `AB, CD, AC, BD`. Failure returns
`ok=false` and **never** attaches a cell. For an admissible
candidate compute

```
c1 = s_Q(B-A,D-C),  c2 = s_Q(C-A,D-B).
attach iff all four graph edges exist AND c1,c2 in S.
```

Missing graph edges or failed membership give `ok=true, attaches=false`.
An empty permitted set attaches no cells. A nested family
`S_0 subseteq S_1 subseteq ...` defines a face filtration **only
when the graph/candidate set is fixed**. The caller must avoid
duplicate faces unless multiple cell attachments are intended.

**Exact planar parallelogram theorem.** On the admissible noncollinear
domain, `c1=c2=0` if and only if `D=B+C-A`. Proof: zero
spread gives `D-C=lambda(B-A)` and `D-B=mu(C-A)`.
Independence of `B-A,C-A` forces `lambda=mu=1`.
Nonzero filtered spread has no intrinsic metric approximation meaning.

## 3. Cellular topology (SGC-1)

`inspect_complex(boundary1,boundary2)` consumes oriented chain
matrices `d1:C1->C0`, `d2:C2->C1` over one `ExactField`.
Each edge must have one `-1` and one `+1` in `d1`.
Rows must be rectangular and every entry accepted. The implementation
verifies `d1*d2=0`; invalid data fail closed with `ok=false`.

The exact Gaussian elimination returns `r1=rank(d1)`,
`r2=rank(d2)`, and

```
beta0 = |V| - r1
beta1 = |E| - r1 - r2
beta2 = |F| - r2
beta0 - beta1 + beta2 = |V| - |E| + |F|.
```

**Crucial scope:** `inspect_complex` validates an **abstract chain complex**.\nThe equation `d1*d2=0` alone does not prove the columns of `d2` are\nattaching maps of geometric 2-cells. A single column equal to the sum\nof cycles in distinct connected graph components is a valid algebraic\ncycle, but cannot be the image of one connected attaching loop.\n\nThe geometric bridge is `certify_quad_face(positions,tails,heads,quad,S)`:\nit checks a simple graph, admissible planar coordinates, available\ncycle edges, and returns exactly the signed oriented chain\n`e_AB + e_BD + e_DC + e_CA` in the supplied edge basis, verifying\n`d1*d2=0`. `build_quad_complex` assembles these certificates\ninto oriented boundary matrices and deduplicates repeated or reversed\ncycle boundaries. The abstract analyzer remains available for legitimate\nnon-geometrically sourced chain complexes; do not call them\n**geometrically certified** without a provenance witness.\nThese are CW-style cellular attaching loops, **not** proofs of an\nembedded, non-self-intersecting polygon in the affine plane.\n\nThese are Betti numbers **over the chosen coefficient field**, not
counts of flow vortices. With fixed graph, adding faces cannot
increase `beta1` because `im d2` can only increase; it need not
strictly decrease. Adding an independent second identical face to a
filled four-cycle leaves `beta1=0` and creates `beta2=1`.

For a changing 1-skeleton, `beta1` need not be monotone.
The kernel computes snapshots; it does not infer the filtration
or produce persistence intervals. The independent leader-coverage
module (`docs/LEADER_PLACEMENT.md`) consumes such boundary matrices
but its image-membership theorem is separate.

## 4. Edge cochains are not homology

`cycle_circulation(d1,cycle,edge_flow)` requires `d1*cycle=0`
and evaluates the oriented cochain/chain pairing
`sum_e cycle[e]*edge_flow[e]`.
A filled boundary may have **nonzero** circulation when
`d(edge_flow)!=0`, although its homology class is zero.
The compiled `verify_cellular_stokes(d1,d2,j,f)` validates the\nchain complex, exact cochain/chain dimensions and the finite-field identity\n`<d j,f> = <j,d2 f>`. A closed cochain has zero circulation on all\nface boundaries; an arbitrary flow need not be closed.\nThus `beta1` alone cannot diagnose vorticity. Nonzero field values
have no intrinsic positive norm.

Heading coincidence, projective alignment, formation-face admission,
and dynamical synchronization are distinct predicates. No coupling,
Lyapunov descent, consensus or finite-state stabilization follows
from an accepted cell.

## 5. TDD evidence, scope and obligations

A red-first compiled test (`tests/mojo/test_projective_cells.mojo`)
was committed before the kernel. The tests cover F7/F13 exact square,
skew cell and widened filter, missing edge, malformed dimension,
coincident/collinear input, rejected scalar, unfilled/filled/double-filled
homology, invalid boundary composition, stationary/nonzero circulation,
noncycle rejection, and F5 isotropic guards. The builder tests verified face boundary\ncolumns, duplicate/reverse elimination, disconnected components and\npositive/nonzero cochain coboundaries.

The independent standard-library Python test
`test_projective_cells_reference.py` exhaustively enumerates
bounded planar configurations over F3 and F5 and independently
calculates modular ranks/flow. It also checks the higher-dimensional
tangent counterexample without asserting the Mojo plane kernel
implements higher dimensions.

**Unproved/unfinished obligations:** proof that every accepted cell boundary\ncomes from the declared oriented attaching loop at the generic field\nlevel; proof that cyclic relabeling preserves the filtered decision;\nidentification of any actual planar embedding (not currently claimed); Lean general-field proof of the
cross-ratio equivalence on the regular locus; Lean refinement of the
compiled cell/rank kernels; persistence maps and representative tracking;
orientation-lift dynamics; any invariant/descent theorem for an actual
swarm update. Do not merge in interpretations as “synchronization” or
“vorticity” without additional transition/flow hypotheses.
