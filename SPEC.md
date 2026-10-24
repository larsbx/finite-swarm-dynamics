# Chromoswarm kernel 0.1 — mathematical specification

**Scope:** A research-grade planar prototype with exact arithmetic, not an equivalent reformulation of any continuous-time swarm model. The executable implementation works over F_p for odd primes p. The algebraic identities below are valid over fields of characteristic different from 2, subject to their guards.

## 1. Domains and axioms

- Scalar field: F_q, characteristic p != 2; no compatible total order is assumed.
- Vector space: V = F_q². Affine locations are modeled on V.
- Homogeneous projective points and lines: nonzero triples modulo nonzero scalar multiples. The implementation stores representatives, never conflating tuple equality with projective equivalence.
- Color matrices: M_b = diag(1,1), M_r = diag(1,-1), M_g = [[0,1],[1,0]].
- Quadratic forms: Q_c(u) = uᵀ M_c u.
- Symmetric bilinear forms: b_c(u,v) = uᵀ M_c v.
- Polarization: Q_c(u+v)-Q_c(u)-Q_c(v) = 2 b_c(u,v).
- Oriented heading: u in V with Q_b(u) = 1. This is not the projective direction [u]; in odd characteristic [u]=[-u] although u != -u.
- Inversion is partial and defined only on nonzero field scalars.

## 2. Geometry laws and guards

For affine A,B, colored quadrance q_c(A,B)=Q_c(B-A). Actual collision means A=B; a zero quadrance can occur for distinct points in a split quadratic geometry.

For non-null directions u,v, colored spread is

    s_c([u],[v]) = 1 - b_c(u,v)² / (Q_c(u)Q_c(v)).

Its domain requires Q_c(u) != 0 and Q_c(v) != 0. Undefined spread is not zero spread. The implementation returns None when the denominator vanishes.

Let D(u,v) = det([u v]), epsilon_b=1 and epsilon_r=epsilon_g=-1. The Gram determinant gives

    Q_c(u)Q_c(v) - b_c(u,v)² = epsilon_c D(u,v)².

Dividing on the guarded domain produces

    s_c([u],[v]) = epsilon_c D(u,v)² / (Q_c(u)Q_c(v)).

Fundamental chromatic quadrance identity:

    Q_b(u)² = Q_r(u)² + Q_g(u)².

Mixed chromatic identity:

    Q_b(u)Q_b(v) - Q_r(u)Q_r(v) - Q_g(u)Q_g(v)
       = 2 D(u,v)².

If every spread is defined and nonzero, the chromatic harmonic-spread law holds:

    1/s_b + 1/s_r + 1/s_g = 2.

For affine triangle A,B,C with delta=det(B-A,C-A), set

    quadrea_c = (q1+q2+q3)² - 2(q1²+q2²+q3²)

where q1,q2,q3 are its three colored side quadrances. Then

    quadrea_b = 4 delta²,
    quadrea_r = quadrea_g = -4 delta².

Affine collinearity is delta=0. Homogeneous projective collinearity uses a vanishing 3x3 determinant. Joins and meets of identical projective objects are not unique and must reject degeneracy.

These planar binary results must not be generalized to higher-dimensional indefinite quadratic spaces without additional hypotheses.

## 3. Blue rotations and chromatic covariance

Let R(c,s)=[[c,-s],[s,c]] with c²+s²=1. Then

    Q_b(Ru) = Q_b(u), det(Ru,Rv)=det(u,v).

Writing C=c²-s² and S=2cs:

    (Q_r(Ru),Q_g(Ru))ᵀ
       = [[C,-S],[S,C]] (Q_r(u),Q_g(u))ᵀ.

This is color covariance, not independent invariance of red and green measurements. Their common exact stabilizer in GL(2,F_q) is {+I,-I}; this excludes color permutations and up-to-scale variants.

The implemented Cayley parameter is

    c(t)=(1-t²)/(1+t²), s(t)=2t/(1+t²)

when 1+t² != 0. **Pole policy:** at 1+t²=0 the implementation selects R=-I. This is a totalization policy, not a limit or analytic continuation; its semantics are model-specific.

## 4. Synchronous oriented-heading transition

A state consists of agents (x_i,u_i) with x_i in V and Q_b(u_i)=1. For each configured color c, choose an arbitrary allowed set E_c subset F_p. An undirected interaction edge has A_ij=1 exactly when i != j and all configured tests q_c(x_i,x_j) in E_c succeed; otherwise A_ij=0. Unconfigured colors impose no restriction. No field ordering or k-nearest-neighbor notion is implicit.

Given coupling kappa and speed nu in F_p, perform a synchronous step:

    t_i = kappa * Σ_(j != i) A_ij * det(u_i,u_j),
    u_i⁺ = R(t_i) u_i,
    x_i⁺ = x_i + nu * u_i⁺.

All coupling uses the OLD state. Antiparallel headings have zero determinant coupling, so this rule is not universally consensus-seeking. A more elaborate model must declare a different coupling and prove its properties.

## 5. Transition invariants

The following are elementary propositions for all odd-characteristic fields with valid states and this interaction policy:

1. Blue-unit heading preservation: Q_b(u_i⁺)=1.
2. Common affine translation equivariance: shifting all x_i by h shifts every output position by h, leaving output headings unchanged.
3. Joint sign equivariance: negating every position and heading negates each output; colored quadrances and heading determinants remain unchanged.
4. Heading consensus invariance: if all u_i=u, then every determinant coupling vanishes, R(0)=I, all headings remain u, and all positions translate by nu*u.
5. Consensus shape invariance: the pair differences x_i-x_j and each associated colored quadrance remain fixed during unanimous motion.
6. Exact consensus translation period: if nu*u != 0, the absolute state has period p (the field's characteristic), not q in general; if nu=0 it is fixed.
7. Eventual periodicity: a deterministic total map on a finite configuration space eventually enters a cycle, but need not converge to consensus.

## 6. Worked F_7 example

Take positions (0,0), (1,2), (3,1) and blue-unit oriented headings (1,0), (0,1), (2,2). Choose all-to-all edges, kappa=1, nu=1. One step makes all three headings (2,2); the resulting rigid-translation orbit has transient 1 and cycle length 7.

For u=(1,2) and v=(2,1), the quadrance triples are (5,4,4) and (5,3,4), determinant is 4, and the spread triple is (4,1,6). Their inverse spreads sum to 2 mod 7.

## 7. Non-equivalence statements and future proofs

This construction is not an analytic limit of Cucker–Smale, Vicsek, Kuramoto, Toner–Tu, or Vlasov systems. It does not inherit Lyapunov dissipation, order-disorder critical exponents, stochastic Gaussian theory, or physical Euclidean radius semantics. Probabilities, if desired, must be modeled by exact counts/rational numbers in a separate interpretation layer.

The code does not yet implement arbitrary finite extension fields, verified Lean definitions, formal algebraic proof objects, or complete finite-state orbit enumeration. Its exhaustive tests cover only the stated small prime fields.

Research lineage: N. J. Wildberger, Chromogeometry (2008); Rational Trigonometry.
