# Literature review: Cayley–Klein geometry, finite fields, and discrete swarm structures

**Scope:** Mathematical literature, not a repository audit. **Reviewed:** October 2026.

## Abstract

Projective metrical geometry starts with incidence together with a distinguished
absolute (usually a quadric), rather than a primitive analytic notion of length
or angle. Cayley and Klein made cross-ratios central to this program; later
developments in quadratic-form theory and finite geometry put it on an algebraic
footing. Wildberger's rational trigonometry and universal geometry explicitly
define quadrance and spread over general fields, including finite fields.
Separately, cellular algebra and discrete exterior calculus provide exact
boundary/coboundary operators for graph-indexed geometry. Their combination is
useful for finite-state models, but neither projective incidence nor nonzero
homology proves any swarm-dynamical conclusion.

This review traces those strands, reproduces a representative cross-ratio
identity as a **standard algebraic consequence** of Vieta's formulas, and
identifies genuinely separate research questions. It does not claim that the
identity, finite-field extension, or cellular Stokes pairing is novel.

## 1. From the absolute to projective metric invariants

**Cayley (1859)** introduced a projective approach to metric geometry relative
to an *absolute*; **Klein (1871, 1873)** connected this to models of
non-Euclidean geometry. A projective space \(\mathbb P(V)\) equipped with a
quadratic form \(Q\) has an absolute
\[
\Omega=\{[x]\in\mathbb P(V):Q(x)=0\}.
\]
The distinction between projective incidence and a particular absolute is
essential: different absolutes determine different geometric invariants.
Onishchik–Sulanke (2006) is a modern systematic reference for this tradition
and its transformation groups [1–3].

For four ordered vertices \(A,B,C,D\) on a projective line, with homogeneous
representatives in a two-dimensional vector space, fix the convention
\[
\operatorname{CR}(A,B;C,D)
  =\frac{\det(A,C)\det(B,D)}
         {\det(A,D)\det(B,C)}.
\]
The denominator factors must be nonzero. The expression is unchanged by
rescaling any representative and by a common invertible linear change of basis.
**Conventions differ across books**: permuting the arguments can yield the
inverse, the complement, or one of six standard transforms. Formula comparison
must state the ordering.

A Cayley–Klein metric need not be introduced via a logarithmic cross-ratio.
For algebraic applications the cross-ratio itself, or a symmetric rational
expression in it, is often the more natural invariant. The geometric
cross-ratio and the choice of absolute are different ingredients: projective
invariance alone does not supply a metric.

## 2. Quadrance and spread in universal geometry

Wildberger's *Divine Proportions* (2005) and *Affine and Projective Universal
Geometry* (2006) develop an algebraic trigonometry. For a field of
characteristic different from two and a symmetric bilinear form \(B\), write
\(Q(u)=B(u,u)\). For non-isotropic vectors \(u,v\), define
\[
S_Q([u],[v])
=1-\frac{B(u,v)^2}{Q(u)Q(v)},\qquad Q(u)Q(v)\ne0.
\]
This quantity is unchanged under \(u\mapsto\lambda u\) and
\(v\mapsto\mu v\) for \(\lambda,\mu\ne0\): numerator and denominator
both scale by \(\lambda^2\mu^2\).

The same formula serves as **projective quadrance** for projective
vertices in universal geometry; when the projective vertices represent
*directions*, it is interpreted as a **spread**. The algebraic formula
does not itself distinguish these geometric uses. In a nondegenerate
two-dimensional quadratic plane,
\[
Q(u)Q(v)-B(u,v)^2
=\det(G)\,\det(u,v)^2
\]
where \(G\) is the Gram matrix in the chosen basis. For the standard
form \(Q(x,y)=x^2+y^2\), \(\det(G)=1\) and
\(S_Q=\det(u,v)^2/(Q(u)Q(v))\). This determinant identity must
retain its Gram factor for other quadratic forms.

Neither a field order nor square-root choices are needed. Isotropic
directions are **outside the domain**, not assigned spread zero. Over
an indefinite or finite-field quadratic form, zero spread need not
imply equal directions in dimensions higher than two: the relevant
Gram determinant can vanish for independent vectors. These
distinctions are especially important when transferring geometric
intuition between coefficient fields.

Wildberger's *Universal Hyperbolic Geometry I* (preprint 2009,
subsequently published) develops the projective and algebraic
trigonometric laws in characteristic other than two. His 2018 overview
explicitly treats finite fields, polarity and the relevant existence
questions for midpoints and sydpoints [4–7].

## 3. Cross-ratios of absolute intersections: an established bridge

The relation between the classical absolute and algebraic spread can
be derived without analytic trigonometry. Take independent
non-isotropic \(u,v\), and put
\[
 a=Q(u),\qquad b=B(u,v),\qquad c=Q(v).
\]
On the projective line \([u+tv]\), the absolute satisfies
\[
 Q(u+tv)=a+2bt+ct^2=0.
\]
Let \(r,s\) be its two roots in a splitting field \(L\) of \(K\).
Since \(a,c\ne0\), both are nonzero, and Vieta gives
\[
 c(r+s)=-2b,\qquad crs=a.
\]
In the homogeneous coordinate \([u+tv]\), \([u]\) is \(t=0\),
\([v]\) is \(t=\infty\), and the fixed determinant convention yields
\[
 \rho=\operatorname{CR}([u],[v];[u+rv],[u+sv])=r/s.
\]
Consequently,
\[
 \rho+\rho^{-1}
 =\frac{(r+s)^2}{rs}-2
 =\frac{4b^2}{ac}-2
\]
and therefore
\[
 \boxed{\frac{2-\rho-\rho^{-1}}4
      =1-\frac{b^2}{ac}
      =S_Q([u],[v]).}
\]

This calculation is an elementary consequence of quadratic forms,
Vieta's formulas and projective cross-ratios, in a setting with
substantial historical and modern precedent [1–7]. **It is not a
novel Cayley–Klein identity.**

Three distinct statements should not be conflated:

1. **Algebraic root-ratio identity:** the displayed rational identity
   under its division and Vieta hypotheses.
2. **Ordinary four-distinct-vertex interpretation:** additionally
   requires \(r\ne s\), plus the independent non-isotropic endpoints.
3. **Intrinsic geometric theorem:** needs a definition of the
   projective cross-ratio and a proof that the chosen coordinates
   represent that definition; the displayed derivation suggests and
   supports this statement but is not a substitute for formalizing
   the interface in a proof assistant.

Swapping the two absolute roots sends \(\rho\mapsto\rho^{-1}\).
The symmetric expression is unchanged. But an arbitrary permutation
of the four arguments need not preserve it.

## 4. Finite fields: splitting, Galois descent and tangency

Hirschfeld (1998) is a standard reference for projective varieties,
quadrics and polarities over finite fields [8]. For the restricted
quadratic above, the discriminant is
\[
 \Delta=4(b^2-ac).
\]
Over \(\mathbb F_q\), \(q\) odd, \(\Delta\) has three cases:

- **Nonzero square:** two distinct intersections defined over
  \(\mathbb F_q\).
- **Nonsquare:** two conjugate intersections defined over
  \(\mathbb F_{q^2}\), not individually over \(\mathbb F_q\).
- **Zero:** one repeated intersection; in the ordinary nonsingular
  quadric setting, the projective line is tangent at that vertex.

In the nonsplit case the Frobenius automorphism exchanges the roots:
\(s=r^q\). With \(\rho=r/s\),
\[
 \rho^q=\rho^{-1},\qquad
 \rho^{q+1}=1.
\]
Thus \(\rho\) belongs to the norm-one subgroup
\(\ker N_{\mathbb F_{q^2}/\mathbb F_q}\). Its symmetric trace-like
quantity descends:
\[
 (\rho+\rho^{-1})^q=\rho+\rho^{-1}.
\]
The resulting Cayley–Klein spread lies in the base field although the
individual absolute intersections do not. This is a straightforward
instance of Galois invariance, not a novel descent theorem.

At a repeated root \(r=s\ne0\), the *rational expression*
\(\rho=1\) gives spread zero. The pair of distinct absolute
intersections required for an ordinary four-vertex cross-ratio is
absent. Calling this an **algebraic tangent extension** is accurate;
calling it a genuine four-distinct-vertex cross-ratio is not.

Characteristic two is not obtained by removing the guard:
division by \(4\) is undefined, and the polarization of a
quadratic form has different algebraic behavior. A characteristic-two
replacement needs a new formulation, not a changed tactic.

The finite-geometric study of *finite upper half-planes* (Angel,
1996) offers a different construction, using field extensions and
graphs; it is useful comparative context, but must not be identified
with Wildberger's universal projective quadrance [9].

## 5. From geometric cells to cellular algebra

A separate literature addresses finite oriented chains and cochains.
For a finite cell complex and any suitable commutative coefficient
ring \(R\), boundary maps satisfy
\[
 \partial_{k-1}\partial_k=0.
\]
For an edge cochain \(j\) and a face chain \(f\), the discrete
Stokes pairing is
\[
 \langle \delta j,f\rangle
 =\langle j,\partial_2f\rangle.
\]
As a finite sum, this pairing identity is algebraic. The condition
\(\partial_1\partial_2=0\) is necessary to claim the matrices form a
chain complex, but not to prove the pairing equation for an arbitrary
matrix called \(\partial_2\).

Desbrun–Hirani–Leok–Marsden's *Discrete Exterior Calculus* (2005)
organizes such finite constructions and adds discrete geometric
operators [10]. Lim (2020) isolates the linear-algebraic foundations
of Hodge theory, while Schaub et al. (2020) study a normalized Hodge
Laplacian and random walks on simplicial complexes [11–12].

These papers are not interchangeable with the purely ring-valued
incidence identity. Standard Hodge decomposition and positive
semidefinite graph Laplacians typically use additional scalar-product,
adjoint and positivity hypotheses; those properties do **not**
automatically survive when coefficients are replaced by arbitrary
finite fields.

Nor does a valid algebraic cycle prove that one of its columns is the
attaching map of a single **geometric** face. Incidence matrices,
realization witnesses and embedding properties are separate layers.

## 6. A geometric invariant is not a swarm convergence theorem

Jadbabaie–Lin–Morse (2003) and Olfati-Saber–Fax–Murray (2007)
establish classical coordination and consensus results with hypotheses
on connectivity, update operators and convergence [13–14].
Their ordered/analytic constructions cannot simply be transplanted
to an unordered finite field. In a finite-state model, exact
dynamics must instead specify the transition map and prove concrete
claims about its reachable states, recurrent classes, invariants or
finite-time behavior.

A spread-certified cell, a closed cochain, and a nontrivial homology
class are different objects. In particular, homology alone does not
prove physical vorticity, synchronization or stabilization. Establishing
a connection would require a defined update law and a theorem relating
that law to the geometry or homology.

## 7. Novelty boundary and further mathematical questions

**Well established in the literature:** metrical geometry relative to
an absolute; projective cross-ratios; bilinear projective
quadrance/spread; split/nonsplit/tangent quadratic configurations;
Galois symmetry; cellular Stokes and finite chain complexes.

**Potentially useful new problems, not established results:**

- A coordinate-free finite-field treatment of spread predicates on
  projective direction vertices, including changes of basis,
  projective symmetry groups and exact admissibility guards.
- Classify the spread values and accepted-interaction graphs for a
  selected quadratic form over \(\mathbb F_q\), accounting for the
  norm-one torus in nonsplit cases and the exceptional tangent locus.
- Construct verified geometric face-attachment witnesses and
  compare their induced boundary matrices with abstract chain-complex
  certificates.
- Determine which properties of cell filtrations or homology survive
  prescribed finite transition rules. A dynamical conclusion must be
  proved from an explicitly specified finite-state update.

A proof assistant can strengthen trust in particular algebraic
statements, but formalization of a familiar identity is a
**verification contribution**, not automatically a new mathematical
theorem. A complete geometric formalization would additionally
identify homogeneous representatives, cross-ratio conventions,
nonvanishing conditions, quadratic extensions, and the exact
interface between the geometric definitions and the field identity.

## Annotated primary and standard references

1. **A. Cayley (1859)**, “A Sixth Memoir upon Quantics,”
   *Philosophical Transactions of the Royal Society of London*
   **149**, 61–90. The absolute and projective metrical approach.
2. **F. Klein (1871; 1873)**, “Ueber die sogenannte Nicht-Euklidische
   Geometrie,” *Mathematische Annalen* **4**, 573–625, and “Zweiter
   Aufsatz,” **6**, 112–145. Projective accounts of non-Euclidean
   geometry; [historical bibliographic record](https://www.numdam.org/item/RHM_2010__16_2_217_0/).
3. **A. L. Onishchik and R. Sulanke (2006)**, *Projective and Cayley-Klein
   Geometries*, Springer Monographs in Mathematics.
   [doi:10.1007/3-540-35645-2](https://doi.org/10.1007/3-540-35645-2).
   Modern systematic treatment of absolutes, invariants and groups.
4. **N. J. Wildberger (2005)**, *Divine Proportions: Rational
   Trigonometry to Universal Geometry*, Wild Egg Books. Source of the
   quadrance/spread vocabulary and its algebraic development.
5. **N. J. Wildberger (2006)**, “Affine and projective universal
   geometry,” [arXiv:math/0612499](https://arxiv.org/abs/math/0612499).
   General-field affine and projective constructions (*preprint*).
6. **N. J. Wildberger (2009 preprint)**, “Universal hyperbolic geometry
   I: Trigonometry,” [arXiv:0909.1377](https://arxiv.org/abs/0909.1377).
   Algebraic hyperbolic trigonometry outside characteristic two.
7. **N. J. Wildberger (2018)**, “Universal Hyperbolic Geometry,
   Sydpoints and Finite Fields: A Projective and Algebraic
   Alternative,” *Universe* **4**(1), 3.
   [doi:10.3390/universe4010003](https://doi.org/10.3390/universe4010003).
   Explicit finite-field applications and polarity.
8. **J. W. P. Hirschfeld (1998)**, *Projective Geometries over Finite
   Fields*, 2nd ed., Oxford University Press.
   [doi:10.1093/oso/9780198502951.001.0001](https://doi.org/10.1093/oso/9780198502951.001.0001).
   Standard finite-projective reference for quadrics and polarities.
9. **J. Angel (1996)**, “Finite Upper Half Planes over Finite Fields,”
   *Finite Fields and Their Applications* **2**, 62–86.
   [doi:10.1006/ffta.1996.0005](https://doi.org/10.1006/ffta.1996.0005).
   Related but distinct finite hyperbolic/graph construction.
10. **M. Desbrun, A. N. Hirani, M. Leok and J. E. Marsden (2005)**,
    “Discrete Exterior Calculus,”
    [arXiv:math/0508341](https://arxiv.org/abs/math/0508341).
    Discrete forms and chain/cochain structure (*preprint*).
11. **L.-H. Lim (2020)**, “Hodge Laplacians on Graphs,” *SIAM Review*
    **62**(3), 685–715.
    [doi:10.1137/18M1223101](https://doi.org/10.1137/18M1223101).
    Cohomological algebra and Hodge decompositions.
12. **M. T. Schaub, A. R. Benson, P. Horn, G. Lippner and A. Jadbabaie
    (2020)**, “Random Walks on Simplicial Complexes and the Normalized
    Hodge 1-Laplacian,” *SIAM Review* **62**(2), 353–391.
    [doi:10.1137/18M1201019](https://doi.org/10.1137/18M1201019).
    Higher-order graph diffusion, with analytic metric assumptions.
13. **A. Jadbabaie, J. Lin and A. S. Morse (2003)**, “Coordination of
    Groups of Mobile Autonomous Agents Using Nearest Neighbor Rules,”
    *IEEE Transactions on Automatic Control* **48**(6), 988–1001.
    [doi:10.1109/TAC.2003.812781](https://doi.org/10.1109/TAC.2003.812781).
    Classical local-rule coordination.
14. **R. Olfati-Saber, J. A. Fax and R. M. Murray (2007)**, “Consensus
    and Cooperation in Networked Multi-Agent Systems,” *Proceedings
    of the IEEE* **95**(1), 215–233.
    [doi:10.1109/JPROC.2006.887293](https://doi.org/10.1109/JPROC.2006.887293).
    Review of graph-based analytic consensus.

**Reading order:** [3] for the classical structure, [5–8] for
general-field and finite-field quadrance/cross-ratio, [10–12] for
cellular algebra, and [13–14] only when a transition rule is defined.
