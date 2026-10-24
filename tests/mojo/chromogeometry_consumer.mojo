"""Consumer of pinned canonical Mojo chromogeometry; not a copied kernel."""
from std.testing import assert_false, assert_true
from finite_exact.fp import Fp, FpField
from chromogeometry.chromatic import (
    ChromoVec2, chromo_det, chromo_blue, chromo_red, chromo_green,
    chromo_blue_spread, chromo_red_spread, chromo_green_spread,
    chromo_pythagoras, chromo_harmonic_spread, chromo_gram_identity,
)

def main() raises:
    var u = ChromoVec2[FpField[7]](Fp[7](1), Fp[7](2))
    var v = ChromoVec2[FpField[7]](Fp[7](2), Fp[7](1))
    assert_true(chromo_blue(u) == Fp[7](5))
    assert_true(chromo_red(u) == Fp[7](4))
    assert_true(chromo_green(u) == Fp[7](4))
    assert_true(chromo_det(u,v) == Fp[7](4))
    assert_true(chromo_blue_spread(u,v) == Fp[7](4))
    assert_true(chromo_red_spread(u,v) == Fp[7](1))
    assert_true(chromo_green_spread(u,v) == Fp[7](6))
    assert_true(chromo_harmonic_spread(u,v))
    assert_true(chromo_pythagoras(u))
    assert_true(chromo_gram_identity(u,v,0))
    assert_true(chromo_gram_identity(u,v,1))
    assert_true(chromo_gram_identity(u,v,2))
    assert_true(chromo_blue_spread(u,u) == Fp[7](0))
    var null_green = ChromoVec2[FpField[7]](Fp[7](1), Fp[7](0))
    assert_false(chromo_green_spread(null_green,u).accepted())
    print("Pinned canonical Mojo chromogeometry consumer passed.")
