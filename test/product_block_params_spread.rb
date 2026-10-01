# product hands its block one Array per tuple. A block with two or more
# parameters takes the tuple's elements, nil past its end, as a yield of
# one Array does; only the first parameter was bound, to the whole tuple,
# and the rest stayed nil. Typed and general receivers, one operand and
# several, and numbered parameters.
[1, 2].product([3]) { |q, r| p [q, r] }
[1, "x"].product([3], [4]) { |q, r, s| p [q, r, s] }
[1.5].product([2.5]) { |a, b| p a + b }
["a"].product(["b"]) { |a, b| p a + b }
[1, nil].product([3]) { |q, r| p [q, r] }
[1].product([2], [3]) { |a, b| p [a, b] }
[1].product([2]) { |a, b, c| p [a, b, c] }
[1, 2].product([3]) { |q| p q }
p([1, 2].product([3]) { _1 })
[1, 2].product([3]) { p [_1, _2] }
[1, 2].product([3]) { p it }
t = 0
[1, 2].product([3, 4]) { |a, b| t += a * b }
p t
