"""Complete F7 coupling sweep: strict Mojo/Python differential verifier."""
from __future__ import annotations
from collections import Counter
from dataclasses import dataclass
from itertools import product
from pathlib import Path
import sys
from reference.extension_chromogeometry import ChromaticPlane, FiniteField
from reference.finite_phase_models import PhaseState, finite_kuramoto_step
from reference.linear_alignment import exact_census

GOLD = Path(__file__).resolve().parents[1] / "conformance/coupling_F7_v1.txt"
UNITS = tuple((x,y) for x in range(7) for y in range(7) if (x*x+y*y)%7 == 1)
STATES = tuple((a,b,c,d) for a,b in UNITS for c,d in UNITS)
ROW_COUNT = 448

# (cycle period, full basin size, greatest incoming tail, number of cycles)
SIGNATURES = {
  0: ((1,1,0,64),),
  1: ((1,1,0,16),(2,2,0,8),(2,4,1,8)),
  2: ((1,1,0,8),(1,3,1,8),(2,4,1,8)),
  3: ((1,1,0,8),(1,3,1,8),(2,2,0,16)),
  4: ((1,1,0,8),(1,3,1,8),(2,2,0,16)),
  5: ((1,1,0,8),(1,3,1,8),(2,4,1,8)),
  6: ((1,1,0,16),(2,2,0,8),(2,4,1,8))
}

@dataclass(frozen=True)
class Stratum:
    coupling: int
    cycle_count: int
    fixed_points: int
    transient_states: int
    signature: tuple[tuple[int,int,int,int],...]

def independent_rows() -> tuple[str,...]:
    f = FiniteField(7)
    g = ChromaticPlane(f)
    one = g.v(1,0)
    w = ((f.zero,f.one),(f.one,f.zero))
    result = []
    for k in range(7):
        for s in STATES:
            a,b,c,d=s
            out=finite_kuramoto_step(g,PhaseState((g.v(a,b),g.v(c,d))),
                  weights=w,coupling=f.element(k),natural_rotors=(one,one),
                  phase_lag_rotor=one)
            data=s+tuple(z.coeffs[0] for heading in out.headings
                          for z in (heading.x,heading.y))
            result.append("STRAT7v1 "+str(k)+" "+" ".join(map(str,data)))
    assert len(result)==ROW_COUNT
    return tuple(result)

def _rot(u,r):
    a,b=u; c,d=r
    return ((a*c-b*d)%7,(a*d+b*c)%7)

def _flip(s):
    return (s[0],s[1],(-s[2])%7,(-s[3])%7)

def verify_strata(actual: str, golden: str|None=None) -> tuple[Stratum,...]:
    golden=GOLD.read_text(encoding="utf-8") if golden is None else golden
    if not actual.endswith("\n") or not golden.endswith("\n"):
        raise ValueError("noncanonical final newline")
    a,g=actual.splitlines(),golden.splitlines()
    if len(a)!=ROW_COUNT or len(g)!=ROW_COUNT:
        raise ValueError("incomplete enumeration")
    if "\n".join(a)+"\n"!=actual or "\n".join(g)+"\n"!=golden:
        raise ValueError("noncanonical records")
    if len(set(a))!=ROW_COUNT or len(set(g))!=ROW_COUNT:
        raise ValueError("duplicate records")
    for i,expected in enumerate(independent_rows()):
        if g[i]!=expected: raise ValueError(f"golden/oracle mismatch row {i}")
        if a[i]!=expected: raise ValueError(f"Mojo/oracle mismatch row {i}")
    maps={};out=[]
    for k in range(7):
        transitions={}
        for i,s in enumerate(STATES):
            columns=a[k*64+i].split(" ")
            if len(columns)!=10 or columns[0]!="STRAT7v1":
                raise ValueError("invalid record")
            values=tuple(int(v) for v in columns[1:])
            if any(v<0 or v>6 for v in values):
                raise ValueError("noncanonical scalar")
            if values[0]!=k or values[1:5]!=s:
                raise ValueError("wrong source state")
            target=values[5:9]
            if target not in STATES:raise ValueError("transition not closed")
            transitions[s]=target
        maps[k]=transitions
        census=exact_census(STATES,transitions.__getitem__,max_states=64)
        counts=Counter((c.period,c.basin_size,c.max_transient)
                       for c in census.cycles)
        signature=tuple(sorted((p,b,t,n) for (p,b,t),n in counts.items()))
        if signature!=SIGNATURES[k]:
            raise ValueError(f"cycle signatures differ for k={k}: {signature}")
        for s in STATES:
            nxt=transitions[s]
            if transitions[transitions[nxt]]!=nxt:
                raise ValueError(f"F^3 != F at k={k}")
        for rotor in UNITS:
            for s in STATES:
                rs=(*_rot(s[:2],rotor),*_rot(s[2:],rotor))
                nxt=transitions[s]
                rhs=(*_rot(nxt[:2],rotor),*_rot(nxt[2:],rotor))
                if transitions[rs]!=rhs:
                    raise ValueError(f"rotor equivariance fails for k={k}")
        out.append(Stratum(k,census.cycle_count,
                   sum(c.period==1 for c in census.cycles),
                   sum(c.basin_size-c.period for c in census.cycles),
                   signature))
    for k in range(7):
        for s in STATES:
            if _flip(maps[k][s])!=maps[(-k)%7][_flip(s)]:
                raise ValueError(f"parameter sign conjugacy fails at k={k}")
    return tuple(out)

def main(args):
    if len(args)!=2:
        raise SystemExit("usage: python -m tools.coupling_stratification <Mojo output>")
    result=verify_strata(Path(args[1]).read_text(encoding="utf-8"))
    for x in result:
        print(f"k={x.coupling}: cycles={x.cycle_count} fixed={x.fixed_points} "
              f"transient={x.transient_states} signature={x.signature}")
    print("PASS: 448 exact Mojo/Python transitions, parameter strata and symmetries")
    return 0

if __name__=="__main__":
    sys.exit(main(sys.argv))
