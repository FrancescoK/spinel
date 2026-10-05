# A Hash subclass instance read out of a mixed Array is boxed (#7449), and
# it answers as CRuby's does through the boxed path: equality, display and conversion: inspect, to_s, to_h (a plain
# Hash), to_a, ==.
# Each probe takes a fresh instance.
class Opts < Hash
  def initialize(src) = (super(); @src = src)
  def label = "opts"
end

def fresh
  pg = Opts.new("x")
  pg[:a] = 1
  pg[:b] = 2
  objs = [pg, [9], {a: 1}, 3]
  objs[0]
end

o = fresh
p o
o = fresh
puts o.to_s
o = fresh
p o.to_h.class
o = fresh
p o.to_a
o = fresh
p o == {a: 1, b: 2}
o = fresh
p({a: 1, b: 2} == o)
