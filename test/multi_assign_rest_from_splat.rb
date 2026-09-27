# A rest target under a right side that is only a splat takes the tail
# of the splatted array, whatever its element kind.
x = [[:a, 1], [:b, 2]]
g, *i = *x
p g, i

h = {a: 1, b: 2}
c, *d = *h.to_a
p c, d

s = ["a", "b", "c"]
g2, *i2 = *s
p g2, i2

m = [1, "b", :c]
g3, *i3 = *m
p g3, i3

*i4, g4 = *x
p i4, g4

g5, *i5, h5 = *x
p g5, i5, h5

def pairs
  [[:q, 1], [:r, 2], [:s, 3]]
end
g6, *i6 = *pairs
p g6, i6

def split(xs)
  first, *more = *xs
  [first, more]
end
p split([[:a, 1], [:b, 2]])

e = []
g7, *i7 = *e
p g7, i7

g8, *i8 = *(1..4)
p g8, i8
