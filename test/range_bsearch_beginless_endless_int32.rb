# Range#bsearch over a beginless or endless Integer range, with values that
# fit a 32-bit Integer, so the -m32 lane (which drops the int64 companion
# range_bsearch_beginless_endless) still bisects from its own sp_int bounds.

p((1..).bsearch { |x| x >= 1000 })
p((..10).bsearch { |x| x >= 2 })
p((...-1).bsearch { |x| x >= -10 })
p((..0).bsearch { |x| x > 5 ? -1 : 1 })
p([1, 2, 3].include?((...10).bsearch { |x| x < 1 ? 1 : x > 3 ? -1 : 0 }))
p((0..100).bsearch { |x| x >= 37 })
p((0..100).bsearch { |x| 50 <=> x })
p((-5..5).bsearch { |x| x > 9 })
p((..0).bsearch { |x| x >= 2_000_000_000 })
p((1..).bsearch { |x| x >= 2_000_000_000 })
p((..-5).bsearch { |x| x >= -2_000_000_000 })
p((0..).bsearch { |x| 1_000_000 <=> x })
p((..0).bsearch { |x| -1_000_000 <=> x })
p((-3..).bsearch { |x| x < 0 ? 1 : (x > 0 ? -1 : nil) })
