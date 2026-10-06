# A product block taking two or more parameters spreads each tuple across
# them, as CRuby's does: a typed receiver, a general Array, a boxed one and
# the n-way form. One parameter, and a destructuring one, take the tuple
# whole.
a = [1, 2]
a.product([3]) { |q, r| p [q, r] }
a.product([3]) { |q,| p q }
a.product([3]) { |(q, r)| p [r, q] }
a.product([3]) { |t| p t }
s = ["x", "y"]
r = s.product([1.5]) { |w, f| p [f, w] }
p r.equal?(s)
b = [1, nil]
b.product([3]) { |x, y| p [x, y] }
b.product([3], [4]) { |x, y, z| p [z, y, x] }
c = [3, 1]
c = 5 if a.size > 9
c.product([7, 8]) { |m, n| p m + n }
sum = 0
[1, 2].product([10, 20]) { |x, y| sum += x * y }
p sum
t = []
["a", nil].product([1.5], [:z]) { |u, v, w| t << [w, v, u] }
p t
[[1, 2]].product([3]) { |pr, z| p [pr, z] }
