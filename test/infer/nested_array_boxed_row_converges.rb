# A table of Integer rows that a boxed value (a row, or nil) is stored into
# stays the poly array. The narrowing pass rejected the Integer-row kind for
# the boxed row, but put its own earlier narrowing pin back, which the write
# pass re-asserted as the narrowed kind the next round: the two traded the
# slot every round, and the fixpoint ran to its 128-round cap ("type
# inference did not converge").
rows = [[1, 2]]
[[3, 4], nil].each { |row| rows[0] = row }
