# An empty trailing **h passes no keywords, so a positional Hash before it
# stays positional.

pr = proc { |a, b = 0, k: 1| [a, b, k] }
h = {}
a = [5]
p pr.call(5, {k: 2}, **h)
p pr.call(*a, {k: 2}, **h)
p pr.call(5, {k: 2}, **{})
def y(h) = yield(5, {k: 2}, **h)
p(y(h) { |a, b = 0, k: 1| [a, b, k] })
def fy(h, &b) = b.call(5, {k: 2}, **h)
p fy(h, &pr)
boxed = [pr, 1]
p boxed[0].call(5, {k: 2}, **h)
p pr.call(5, {k: 2}, **{k: 3})
l = ->(a, b = 0, k: 1) { [a, b, k] }
p l.call(5, {k: 2}, **h)
