# Explicit chromatic-neighborhood construction in Mojo

`chromatic_neighbor_mask` builds the finite interaction graph from affine
positions and **membership predicates** on the blue, red, and green quadrance
forms. Every enabled color is a conjunctive guard; disabled colors impose no
restriction. No total ordering or metric radius exists on the field. The
returned mask is symmetric because each quadratic form is even in displacement,
and diagonal entries are always false; `modal_vicsek_step` separately includes
each agent's own heading in its observation multiset.

A zero colored quadrance need not represent collision: positions `(0,0)`
and `(1,0)` are distinct but have green quadrance zero. The compiled
test explicitly verifies the distinction, as well as a three-agent
green-null star graph and its resulting *tie-retaining* modal update.

Invalid field elements or positions fail closed with no partial mask. Canonical
field and chromatic forms still come from the pinned shared Mojo kernels;
this module owns only model-specific adjacency semantics.
