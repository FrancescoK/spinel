# A rescue modifier whose fallback is a `next v` answers v as the block's
# value when the modifier is the block's last expression.

p([1, 2].map { |i| raise "boom" rescue next 9 })
p(["1", "z", "3"].map { |s| Integer(s) rescue next 0 })
p(["1", "z"].map { |s| Integer(s) rescue next })
p(["a", "b"].map { |s| raise s rescue next s * 2 })
p(["1", "x"].map { |s| Integer(s) rescue (s = "n"; next s) })

# not the tail: the next still leaves the iteration with its value
p([1, 2].map { |i| x = (raise "boom" rescue next 5); x })
p(["1", "z"].map { |s| Integer(s) rescue next -1 }.sum)
