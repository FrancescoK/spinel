# Range#bsearch over Floats bisects the bounds' bit patterns, as CRuby does:
# halving the reals never ended at an infinite bound, and -Infinity +
# Infinity made a NaN. A range with only its end a Float went to the
# Integer bisection, which held Infinity as an sp_int and trapped.

inf = Float::INFINITY
p((0..inf).bsearch { |x| x == inf })
p((-inf..0).bsearch { |x| x != -inf })
p((0.0..inf).bsearch { |x| x >= 1e300 })
p((-inf..inf).bsearch { |x| x >= 5.5 })
p((0.0..10.0).bsearch { |x| x >= 2.5 })
p((0.0...2.5).bsearch { |x| x >= 2.5 })
p((0.0..2.5).bsearch { |x| x >= 2.5 })
p((-5.0..5.0).bsearch { |x| x >= -0.0 })
p((-5.0..5.0).bsearch { |x| x > 0 })
p((0.0..100.0).bsearch { |x| 42.0 <=> x })
p((0.0..100.0).bsearch { |x| 4.2 <=> x })
p((1..10.0).bsearch { |x| x * x >= 50 })
p((0.0..1.0).bsearch { |x| false })
p((0.0..1.0).bsearch { |x| true })
p((-inf..-1.0).bsearch { |x| x >= -1e10 })
p((0.0..inf).bsearch { |x| x > 1e308 })
n = 0
r = (0.0..1.0).bsearch { |x| n += 1; x >= 0.3 }
p r, n <= 66
