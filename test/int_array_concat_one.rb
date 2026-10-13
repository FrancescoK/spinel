# `a.concat(b)` of two Integer Arrays as a statement copies b's elements in
# one move, each nil with its place, and works on itself, on a shifted
# receiver, across a growth, and raises on a frozen receiver.
a = [1, 2, 3]
b = [4, nil, 6]
a.concat(b)
p a, a[4].nil?

c = [7, 8]
c.concat(c)
p c

d = [1, 2, 3, 4, 5]
d.shift
d.shift
d.concat([9, nil])
p d

e = []
big = (1..100).to_a
big[50] = nil
e.concat(big)
p e.size, e[50], e[99], e.compact.size

f = [1].freeze
p((f.concat([2]) rescue $!.class))

g = [nil, 1]
g.concat([nil])
p g, g.count(nil)
