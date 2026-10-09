# spinel: share
# spinel: gc-minor
# spinel: gc-stress
# Multiple break arguments form one Array in loops and iterators.
p(loop { break 1, 2 })
p(while true; break 3, 4; end)
p(until false; break 5, 6; end)
p([1, 2].each { |i| break i, i + 1 })
p([1, 2].map { |i| break 7, 8 if i == 2; i })
p(loop { break 1, *[2, 3], 4 })
