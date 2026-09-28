# slice! with a beginless or an endless Range on a mixed Array removes and
# answers that part, as the same call on an Integer Array does.
a = [10, "s2", 30, "s4", 50, "s6"]
p a.slice!(..3)
p a
b = [10, "s2", 30, "s4", 50, "s6"]
p b.slice!(4..)
p b
c = [1, "x", 3]
p c.slice!(..-2)
p c
d = [1, "x", 3, "y"]
p d.slice!(...1)
p d
e = [1, "x"]
p e.slice!(5..)
p e
f = [1, "b", 3, "d", 5]
p f.slice!(0..)
p f
g = [1, "b", 3, "d", 5]
p g.slice!(-2..)
p g
# a start before the first element answers nil and leaves the Array as it was
h = [1, "b", 3, "d", 5]
p h.slice!(-6..)
p h.slice!(-6..-5)
p h
begin
  [1, "b", 3].freeze.slice!(-10..)
rescue => e
  p e.class
end
