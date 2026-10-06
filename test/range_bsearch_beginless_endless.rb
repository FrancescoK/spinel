# spinel: int64
# Range#bsearch over a beginless or endless Integer range: the bounds span
# most of sp_int, so the probe's midpoint (hi - lo) and the step past it
# (mid + 1) overflowed. That is undefined, and gcc compiled the search into a
# loop that never ended (ruby/spec core/range bsearch_spec on Linux); clang's
# happened to wrap. The width is taken unsigned and the step guarded.

p((1..).bsearch { |x| x >= 1000 })
p((0...).bsearch { |x| x > 2**40 })
p((..10).bsearch { |x| x >= 2 })
p((...-1).bsearch { |x| x >= -10 })
p((..0).bsearch { |x| x > 5 ? -1 : 1 })
p([1, 2, 3].include?((...10).bsearch { |x| x < 1 ? 1 : x > 3 ? -1 : 0 }))
p((0..100).bsearch { |x| x >= 37 })
p((0..100).bsearch { |x| 50 <=> x })
p((-5..5).bsearch { |x| x > 9 })
p((..10).bsearch { |x| x >= 1 })
p((..(2**62)).bsearch { |x| x >= 2**62 - 1 })
p((-(2**62)..).bsearch { |x| x >= -(2**62) + 3 })
