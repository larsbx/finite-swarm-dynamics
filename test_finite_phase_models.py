"""Finite modal-Vicsek and algebraic-Kuramoto reference model tests."""
import unittest

from reference.extension_chromogeometry import (
    Agent, ChromaticPlane, FiniteField, Swarm,
)
from reference.finite_phase_models import (
    PhaseState, exact_coherence, finite_kuramoto_step, inverse_rotor,
    modal_vicsek_step, relative_rotor, rotor_multiply,
)
from reference.linear_alignment import exact_census


def state3(g: ChromaticPlane) -> Swarm:
    return Swarm((
        Agent(g.v(0, 0), g.v(1, 0)),
        Agent(g.v(1, 1), g.v(1, 0)),
        Agent(g.v(2, 2), g.v(0, 1)),
    ))


class FinitePhaseTests(unittest.TestCase):
    def test_modal_majority_and_ties(self):
        for f in (FiniteField(7), FiniteField(3, (1, 0, 1))):
            g = ChromaticPlane(f)
            state = state3(g)
            nxt = modal_vicsek_step(g, state)
            self.assertEqual(tuple(a.heading for a in nxt.agents), (g.v(1,0),)*3)
            self.assertEqual(
                tuple(a.position for a in nxt.agents),
                tuple(g.add(a.position, g.v(1,0)) for a in state.agents),
            )
            tie = Swarm(state.agents[:1] + state.agents[2:])
            after = modal_vicsek_step(g, tie)
            self.assertEqual(
                tuple(a.heading for a in after.agents),
                tuple(a.heading for a in tie.agents),
            )

    def test_chromatic_guard_rejects_non_neighbors(self):
        f = FiniteField(7)
        g = ChromaticPlane(f)
        old = state3(g)
        # Only zero displacement can enter the blue guard; self is included
        # regardless of guards. All old positions are distinct.
        nxt = modal_vicsek_step(
            g, old, allowed_quadrances={"b": frozenset({f.zero})}
        )
        self.assertEqual(
            tuple(a.heading for a in nxt.agents),
            tuple(a.heading for a in old.agents)
        )
        with self.assertRaises(ValueError):
            modal_vicsek_step(g, old, allowed_quadrances={"purple": frozenset()})
        with self.assertRaises(ValueError):
            modal_vicsek_step(
                g, old, allowed_quadrances={"b": frozenset({FiniteField(5).one})}
            )

    def test_modal_equivariance_for_blue_guard(self):
        f = FiniteField(7)
        g = ChromaticPlane(f)
        base = state3(g)
        guard = {"b": frozenset(f.elements())}
        shifted = Swarm(tuple(
            Agent(g.add(a.position, g.v(3,5)), a.heading) for a in base.agents
        ))
        x = modal_vicsek_step(g, base, allowed_quadrances=guard)
        y = modal_vicsek_step(g, shifted, allowed_quadrances=guard)
        self.assertEqual(
            y, Swarm(tuple(
                Agent(g.add(a.position, g.v(3,5)), a.heading) for a in x.agents
            ))
        )
        spun = Swarm(tuple(
            Agent(g.rotate(a.position, f.one), g.rotate(a.heading, f.one))
            for a in base.agents
        ))
        z = modal_vicsek_step(g, spun, allowed_quadrances=guard)
        self.assertEqual(
            z, Swarm(tuple(
                Agent(g.rotate(a.position, f.one), g.rotate(a.heading, f.one))
                for a in x.agents
            ))
        )

    def test_supplied_finite_noise_and_guards(self):
        f = FiniteField(7)
        g = ChromaticPlane(f)
        old = state3(g)
        quarter = g.v(0,1)
        nxt = modal_vicsek_step(g, old, noise_rotors=(quarter,)*3)
        self.assertEqual(tuple(a.heading for a in nxt.agents), (quarter,)*3)
        self.assertTrue(all(g.q(a.heading, "b") == f.one for a in nxt.agents))
        with self.assertRaises(ValueError):
            modal_vicsek_step(g, old, noise_rotors=(quarter,))
        with self.assertRaises(ValueError):
            modal_vicsek_step(g, old, noise_rotors=(g.v(0,0),)*3)

    def test_rotor_group_operations(self):
        for f in (FiniteField(7), FiniteField(3, (1,0,1))):
            g = ChromaticPlane(f)
            e, q = g.v(1,0), g.v(0,1)
            self.assertEqual(rotor_multiply(g, q, q), g.v(-1,0))
            self.assertEqual(rotor_multiply(g, q, inverse_rotor(g, q)), e)
            self.assertEqual(relative_rotor(g, e, q), q)
            self.assertEqual(relative_rotor(g, q, g.v(-1,0)), q)

    def test_finite_phase_sync_and_drift(self):
        for f in (FiniteField(7), FiniteField(3, (1,0,1))):
            g = ChromaticPlane(f)
            e, quarter = g.v(1,0), g.v(0,1)
            state = PhaseState((e,e,e))
            weights = tuple(tuple(f.one if i != j else f.zero
                                  for j in range(3)) for i in range(3))
            nxt = finite_kuramoto_step(
                g, state, weights=weights, coupling=f.one,
                natural_rotors=(quarter,)*3,
            )
            self.assertEqual(nxt, PhaseState((quarter,)*3))
            self.assertEqual(exact_coherence(nxt), (3,3))

    def test_antipodal_stationary_and_distinct(self):
        f = FiniteField(7)
        g = ChromaticPlane(f)
        e, minus_e = g.v(1,0), g.v(-1,0)
        state = PhaseState((e,minus_e))
        weights = ((f.zero, f.one), (f.one, f.zero))
        nxt = finite_kuramoto_step(
            g, state, weights=weights, coupling=f.one, natural_rotors=(e,e)
        )
        self.assertEqual(nxt, state)
        self.assertEqual(exact_coherence(nxt), (0,1))

    def test_common_drift_preserves_relative_phase_without_coupling(self):
        f = FiniteField(7)
        g = ChromaticPlane(f)
        e, q = g.v(1,0), g.v(0,1)
        state = PhaseState((e,q))
        weights = ((f.zero,f.zero),(f.zero,f.zero))
        nxt = finite_kuramoto_step(
            g, state, weights=weights, coupling=f.one, natural_rotors=(q,q)
        )
        self.assertEqual(
            relative_rotor(g, *state.headings),
            relative_rotor(g, *nxt.headings),
        )

    def test_lag_breaks_uniform_phase_on_irregular_graph(self):
        f = FiniteField(7)
        g = ChromaticPlane(f)
        e, q = g.v(1,0), g.v(0,1)
        state = PhaseState((e,e))
        nxt = finite_kuramoto_step(
            g, state,
            weights=((f.zero,f.one),(f.zero,f.zero)),
            coupling=f.one, natural_rotors=(e,e), phase_lag_rotor=q,
        )
        self.assertNotEqual(nxt.headings[0], nxt.headings[1])
        self.assertTrue(all(g.q(u, "b") == f.one for u in nxt.headings))
        self.assertEqual(exact_coherence(nxt), (0,1))

    def test_phase_size_and_field_guards(self):
        f, other = FiniteField(7), FiniteField(5)
        g = ChromaticPlane(f)
        e = g.v(1,0)
        with self.assertRaises(ValueError):
            finite_kuramoto_step(
                g, PhaseState((e,)), weights=((f.one,),),
                coupling=f.one, natural_rotors=(e,),
            )
        with self.assertRaises(TypeError):
            finite_kuramoto_step(
                g, PhaseState((e,)), weights=((f.zero,),),
                coupling=other.one, natural_rotors=(e,),
            )
        with self.assertRaises(ValueError):
            finite_kuramoto_step(
                g, PhaseState((e,)), weights=((f.zero,),),
                coupling=f.one, natural_rotors=(),
            )

    def test_exact_single_oscillator_cycle(self):
        f = FiniteField(3)
        g = ChromaticPlane(f)
        e, q = g.v(1,0), g.v(0,1)
        cycle = (e, q, g.v(-1,0), g.v(0,-1))
        states = tuple(PhaseState((u,)) for u in cycle)
        def advance(s):
            return finite_kuramoto_step(
                g, s, weights=((f.zero,),), coupling=f.one,
                natural_rotors=(q,),
            )
        census = exact_census(states, advance)
        self.assertEqual(census.state_count, 4)
        self.assertEqual(census.cycle_count, 1)
        self.assertEqual(census.cycles[0].period, 4)
        self.assertEqual(census.cycles[0].max_transient, 0)


if __name__ == "__main__":
    unittest.main()
