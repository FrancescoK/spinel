# Flag-only: `Array.new(n, s)` fills every slot with s itself. When the rule
# shares s, the Array is the poly form whose boxes hold s's handle, as a
# literal `[s, s]` is, so a change through an element shows in s and in the
# other elements, and a change to s shows in the elements: stored in a
# local, a boxed local, an ivar, a method's answer, read in place, iterated
# with a block. A fresh fill (`+"x"`, `s.dup`) is one String in every slot;
# a frozen literal fill stays frozen.
s = +"ab"
a = Array.new(2, s)
a[0] << "x"
p s, a
a[1].upcase!
p s, a[0].equal?(a[1])
t = +"t"
Array.new(3, t)[2] << "!"
p t
class K
  def initialize(v) = (@a = Array.new(2, v))
  def bump = @a[1] << "?"
  def a = @a
end
u = +"u"
k = K.new(u)
k.bump
p u, k.a
def fill(v) = Array.new(2, v)
w = +"w"
b = fill(w)
b[0] << "1"
p w, b
m = +"m"
c = Array.new(2, m)
m << "2"
p c
d = Array.new(2, "lit")
p d, d[0].frozen?
begin
  d[0] << "z"
rescue FrozenError => e
  p e.class
end
x = Array.new(2, +"x")
x[0] << "y"
p x
r = +"r"
y = Array.new(2, r.dup)
y[1] << "!"
p r, y
e = 1
p e
e = Array.new(2, r)
e.each { |z| z << "." }
p r, Array.new(0, r)
g = +"g"
h = Array.new(2, g)
h.map(&:upcase!)
p g
begin
  Array.new(-1, g)
rescue ArgumentError => ex
  p ex.message
end
