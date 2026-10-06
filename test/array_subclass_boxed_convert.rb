# An Array subclass instance read out of a mixed Array is boxed (#7449), and
# it answers as CRuby's does through the boxed path: equality, display and conversion: inspect, to_s, to_a, ==, a Hash key,
# join, a splat, a destructuring, flatten, +.
# Each probe takes a fresh instance.
class Page < Array
  def initialize(src) = (super(); @src = src)
  def label = "page"
end

def fresh
  pg = Page.new("x")
  pg << 1 << 2
  objs = [pg, [9], {a: 1}, 3]
  objs[0]
end

o = fresh
p o
o = fresh
puts o.to_s
o = fresh
p o.to_a.class
o = fresh
p o == [1, 2]
o = fresh
p [1, 2] == o
o = fresh
h = {o => 1}; p h[[1, 2]]
o = fresh
puts o.join("-")
o = fresh
def f(*a) = a.size; p f(*o)
o = fresh
a, b = o; p [a, b]
o = fresh
p [o, [3]].flatten
o = fresh
p (o + [5]).class
