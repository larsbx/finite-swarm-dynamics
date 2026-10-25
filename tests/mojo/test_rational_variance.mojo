"""Compiled rational N-agent exact variance identities and counterexamples."""
from std.testing import assert_true, assert_false
from finite_exact.rat_q import Q
from finite_exact.field import QField
from chromogeometry.chromatic import ChromoVec2
from swarm_models.rational_variance import rational_variance_witness


def v(x: Q,y: Q) -> ChromoVec2[QField]:
    return ChromoVec2[QField](x,y)


def three_convex() -> List[List[Q]]:
    var rows=List[List[Q]]()
    var r0=List[Q]()
    r0.append(Q(1,2))
    r0.append(Q(1,2))
    r0.append(Q.zero())
    rows.append(r0^)
    var r1=List[Q]()
    r1.append(Q(1,2))
    r1.append(Q(1,2))
    r1.append(Q.zero())
    rows.append(r1^)
    var r2=List[Q]()
    r2.append(Q.zero())
    r2.append(Q.zero())
    r2.append(Q.one())
    rows.append(r2^)
    return rows^


def test_three_agent_jensen() raises:
    var vel=List[ChromoVec2[QField]]()
    vel.append(v(Q.one(),Q.zero()))
    vel.append(v(Q.zero(),Q.one()))
    vel.append(v(Q(2,1),Q(3,1)))
    var report=rational_variance_witness(three_convex(),vel)
    assert_true(report.ok)
    assert_true(report.column_unital)
    assert_true(report.nonnegative_weights)
    assert_true(report.mean_preserved)
    assert_true(report.exact_identity)
    assert_true(report.nonincrease_certified)
    assert_true(QField.eq(report.moment_gap,Q.one()))
    assert_true(QField.eq(report.pairwise_witness,Q.one()))
    assert_true(QField.eq(
        QField.sub(report.variance_before,report.variance_after),Q.one()
    ))


def test_signed_counterexample() raises:
    var rows=List[List[Q]]()
    var a=List[Q]()
    a.append(Q(-1,2))
    a.append(Q(3,2))
    rows.append(a^)
    var b=List[Q]()
    b.append(Q(3,2))
    b.append(Q(-1,2))
    rows.append(b^)
    var vel=List[ChromoVec2[QField]]()
    vel.append(v(Q.one(),Q.zero()))
    vel.append(v(Q.zero(),Q.one()))
    var result=rational_variance_witness(rows,vel)
    assert_true(result.ok)
    assert_true(result.column_unital)
    assert_false(result.nonnegative_weights)
    assert_true(result.exact_identity)
    assert_false(result.nonincrease_certified)
    assert_true(QField.eq(result.variance_before,Q.one()))
    assert_true(QField.eq(result.variance_after,Q(4,1)))
    assert_true(QField.eq(result.pairwise_witness,Q(-3,1)))


def test_row_unital_is_not_double_unital() raises:
    var rows=List[List[Q]]()
    for _ in range(2):
        var row=List[Q]()
        row.append(Q.zero())
        row.append(Q.one())
        rows.append(row^)
    var vel=List[ChromoVec2[QField]]()
    vel.append(v(Q.one(),Q.zero()))
    vel.append(v(Q.zero(),Q.one()))
    var result=rational_variance_witness(rows,vel)
    assert_true(result.ok)
    assert_false(result.column_unital)
    assert_false(result.mean_preserved)
    assert_true(result.exact_identity)
    assert_false(result.nonincrease_certified)


def test_refuse_invalid() raises:
    var vel=List[ChromoVec2[QField]]()
    vel.append(v(Q.one(),Q.zero()))
    assert_false(rational_variance_witness(three_convex(),vel).ok)


def main() raises:
    test_three_agent_jensen()
    test_signed_counterexample()
    test_row_unital_is_not_double_unital()
    test_refuse_invalid()
    print("PASS: exact Q rational N-agent variance witness, signed counterexample and guards.")
