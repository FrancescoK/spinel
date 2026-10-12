# spinel: not-cruby
# ...and through a chain of such constants: each is followed to the
# module it names, so the route stands aside as well.
$g = String.new("other")
module Overrides
  def last = $g
end
Inner = Overrides
Outer = Inner
class Range
  prepend Outer
end
s = String.new("a")
e = String.new("c")
r = s..e
x = r.last
t = x
x << "!"
p t, s, e, $g
