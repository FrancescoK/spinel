# A curried proc applies through #yield and #=== as through #call / [] / .():
# they are the same call. Both were refused at compile time.
add = proc { |a, b| a + b }.curry
p add.yield(1).yield(2)
p add[1] === 2
p add.yield(3)[4]
p add.(5).yield(6)

add3 = ->(a, b, c) { a * 100 + b * 10 + c }.curry
p add3.yield(1).yield(2).yield(3)
p add3[4][5] === 6
