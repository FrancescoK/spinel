# eql? on an Integer Range held in a mixed Array (a boxed receiver)
# compares by value, as on a Range: equal ends and exclusion are eql?, an
# Integer end is not eql? to a Float one, and uniq and Hash keys follow.
a = (0..1)
b = (0..1.0)
x = [a, 5][0]
y = [b, 5][0]
r = [(1..10), 5][0]
p r.eql?(1..10), r.eql?(1...10), r.eql?(1..11), r == (1..10)
p x.eql?(0..1), x.eql?(b), y.eql?(a), y.eql?([(0..1.0), 5][0]), x.eql?(0...1)
p [(0..1), (0..1), (0..1.0)].uniq.size, [x, (0..1), y].uniq.size
h = {}
h[x] = 1
h[(0..1)] = 2
p h.size
q = [("a".."c"), 5][0]
p q.eql?("a".."c"), [(1.5..2.5), 5][0].eql?(1.5..2.5)
