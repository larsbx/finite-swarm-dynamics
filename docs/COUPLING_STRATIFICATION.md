# Complete F7 coupling stratification

This experiment evaluates the **actual compiled finite-field phase model**
for all 7 coupling values and all 64 ordered pairs of oriented unit-blue
headings over F7. The update is

    d = det(u,v)
    F_k(u,v) = (R(k*d)u, R(-k*d)v)

where R is the exact guarded Cayley rotation, both natural rotors and the
lag rotor are identity, and the off-diagonal weights are one.

Each of the 448 records in `conformance/coupling_F7_v1.txt` is generated
independently by pinned compiled Mojo and rechecked using Python's exact
finite-field implementation and the versioned corpus.

| Coupling | Cycles | Fixed points | Transient states | (Period, basin, tail, count) |
| --- | ---: | ---: | ---: | --- |
| 0 | 64 | 64 | 0 | (1,1,0,64) |
| 1,6 | 32 | 16 | 16 | (1,1,0,16); (2,2,0,8); (2,4,1,8) |
| 2,5 | 24 | 16 | 24 | (1,1,0,8); (1,3,1,8); (2,4,1,8) |
| 3,4 | 32 | 16 | 16 | (1,1,0,8); (1,3,1,8); (2,2,0,16) |

All cycle basins for each parameter cover 64 states. In this specific
finite family, F_k^3=F_k, so the maximal transient length is 1 and every
cycle has period at most 2. These are **bounded exact facts**, not claims
about classical real Kuramoto models or all finite fields.

The sign symmetry is algebraic. Write T(u,v)=(u,-v). Then T²=identity,
det(u,-v)=-det(u,v), and rotations commute with vector negation.
Consequently

    T(F_k(u,v)) = F_(-k)(T(u,v)).

This proves parameter sign conjugacy for the specified symmetric
zero-lag algebraic update and explains k and -k having the same orbit
structure. The checker also tests all 448 instances of this conjugacy and
all 7*8*64=3584 instances of equivariance under simultaneous unit-blue
rotation. No order or real-number distance is imposed on field elements.

No result from a truncated search is accepted. The complete Mojo stream
is checked first, and both its field-domain closure and census coverage
are subsequently verified. General-field Lean verification is a separate
milestone.
