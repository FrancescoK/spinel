# A String subclass instance read out of a mixed Array is boxed (#7449), and
# it answers as CRuby's does through the boxed path: equality, display and conversion: inspect, to_s and to_str (plain
# Strings), interpolation, ==, a Hash key, +.
# Each probe takes a fresh instance.
class Buf < String
  def initialize(src) = (super("ab"); @src = src)
  def label = "buf"
end

def fresh
  pg = Buf.new("x")
  objs = [pg, [9], {a: 1}, 3]
  objs[0]
end

o = fresh
p o
o = fresh
p o.to_s.class
o = fresh
p o.to_str.class
o = fresh
puts "<#{o}>"
o = fresh
p o == "ab"
o = fresh
p "ab" == o
o = fresh
h = {o => 1}; p h["ab"]
o = fresh
p o + "c"
