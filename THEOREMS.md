# Proof notes — chromogeometric kernel

The polynomial identities below hold over every field of characteristic other than two. Division claims require nonzero denominators. The executable tests cover finite prime-field samples; this document is a mathematical proof outline and not a completed Lean formalization.

## T01 — Polarization

For symmetric M, put Q(u)=uᵀMu. Expansion gives Q(u+v)-Q(u)-Q(v)=2uᵀMv. Thus b(u,v)=(Q(u+v)-Q(u)-Q(v))/2 is well-defined in odd characteristic.

## T02 — Gram determinant and colored spread

Let C=[u v] and G=CᵀMC. Then det(G)=det(M)det(C)². As G=[[Q(u),b(u,v)],[b(u,v),Q(v)]],

    Q(u)Q(v)-b(u,v)²=det(M)det(u,v)².

The determinants of the blue, red and green matrices are respectively 1, -1 and -1. Divide only if Q(u)Q(v)!=0 to get the colored spread identity. If one quadrance vanishes the polynomial identity still holds but spread is undefined.

## T03 — Chromatic quadrance identity

The polynomial identity

    (x²+y²)²=(x²-y²)²+(2xy)²

gives Q_b(u)²=Q_r(u)²+Q_g(u)² directly.

## T04 — Mixed identity and harmonic chromatic spread

Writing u=(a,b), v=(c,d), expand:

    Q_b(u)Q_b(v)-Q_r(u)Q_r(v)
      = 2(a²d²+b²c²),
    Q_g(u)Q_g(v)=4abcd.

Their difference is 2(ad-bc)². Hence

    Q_b(u)Q_b(v)-Q_r(u)Q_r(v)-Q_g(u)Q_g(v)=2det(u,v)².

If all six quadrances are nonzero and det(u,v)!=0, T02 gives

    1/s_b = Q_b(u)Q_b(v)/det(u,v)²,
    1/s_r = -Q_r(u)Q_r(v)/det(u,v)²,
    1/s_g = -Q_g(u)Q_g(v)/det(u,v)².

Summing and using the mixed identity gives 1/s_b+1/s_r+1/s_g=2. No inverse-spread statement is made outside the guards.

## T05 — Quadrea

For affine points A,B,C let u=B-A and v=C-A. Their side quadrances can be expressed as Q(u), Q(v), Q(u-v), with Q(u-v)=Q(u)+Q(v)-2b(u,v). Expand the quadrea polynomial:

    (q1+q2+q3)² - 2(q1²+q2²+q3²)
       = 4(Q(u)Q(v)-b(u,v)²).

T02 converts this to 4det(M)det(u,v)², positive for blue and negative for red/green. Because the quadratic forms have nonsingular 2x2 matrices, this planar expression vanishes exactly when u and v are linearly dependent. That converse is not asserted in higher-dimensional indefinite spaces.

## T06 — Blue rotation and covariance

For R=[[c,-s],[s,c]] satisfying c²+s²=1, matrix multiplication yields RᵀR=I and det R=1. Consequently Q_b(Ru)=Q_b(u) and det(Ru,Rv)=det(u,v).

Expanding x'=cx-sy and y'=sx+cy yields

    Q_r(Ru)=(c²-s²)Q_r(u)-2cs Q_g(u),
    Q_g(Ru)=2cs Q_r(u)+(c²-s²)Q_g(u).

Also (c²-s²)²+(2cs)²=(c²+s²)²=1. Rational Cayley parameters satisfy the unit identity whenever the denominator is nonzero. At a pole the implementation chooses -I; this is another valid blue rotation, but is not an algebraic continuation.

## T07 — Common exact stabilizer

Suppose AᵀM_cA=M_c for each color. Preservation of (M_b+M_r)/2=diag(1,0) and (M_b-M_r)/2=diag(0,1) forces A diagonal with diagonal entries a,d satisfying a²=d²=1. The green matrix additionally forces ad=1. Thus A=I or A=-I. This is exact preservation of labeled forms, not the stabilizer up to scale nor any group of color permutations.

## T08 — Transition invariants

Given t_i=kappa Σ_(j!=i) A_ij det(u_i,u_j), u_i⁺=R(t_i)u_i, x_i⁺=x_i+nu u_i⁺:

1. Blue heading quadrance is preserved by T06, including the pole branch.
2. Translating all positions by h preserves offsets, colored quadrance memberships and hence A_ij, t_i, u_i⁺; new positions shift by h.
3. Negating all positions and headings preserves each colored quadrance Q_c(-d)=Q_c(d) and determinant det(-u_i,-u_j)=det(u_i,u_j). Couplings and rotation parameters are unchanged, so the update commutes with simultaneous negation.
4. If all headings equal u, then all determinants vanish, t_i=0 and R(0)=I. Every output heading is u, and every position changes by the common displacement nu*u.
5. Pair differences and all their chromatic quadrances are invariant under the common translation.
6. If nu*u is nonzero in characteristic p, repeated additive translation by that vector has exact order p. Thus unanimous moving swarms have exact period p; if nu=0 they are fixed.
7. Every orbit of the total deterministic transition on a finite state space enters a periodic cycle by the pigeonhole principle. This statement does not establish heading consensus.

Proof obligations for future formal verification: typed NonNull spread guards, projective quotient, characteristic !=2 assumptions, exact field extension implementation, equivariance under all declared symmetries, full finite transition graph analysis, and explicit correspondence or non-equivalence proofs against classical swarm models.
