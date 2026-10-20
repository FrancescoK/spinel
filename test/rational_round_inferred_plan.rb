# Rational#round, #truncate, #floor and #ceil with a digit count: the count
# literal's value picks the result's kind (a positive count answers a
# Rational, zero or a negative one an Integer), which inference types in a
# rule of its own, so the builtin-op row for each has no result to record.
# tools/plan_check.sh requires this program to compile with no call
# reported as unrecorded, so a row that loses its BOPF_INFERRED flag fails
# the plan check and not just a corpus count.
r = Rational(314, 100)
n = Rational(-7, 2)
p r.round(1), r.truncate(1), r.floor(1), r.ceil(1)
p r.round(0), r.truncate(0), r.floor(0), r.ceil(0)
p n.round(-1), n.truncate(-1), n.floor(-1), n.ceil(-1)
p Rational(5, 2).round(0, half: :even), Rational(5, 2).round(0, half: :down)
p Rational(25, 100).round(1, half: :up), Rational(25, 100).round(1, half: :even)
p n.floor(2), n.ceil(2)
