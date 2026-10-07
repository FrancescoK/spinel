# A String member keeps the String it was built with, so the String's
# in-place changes read back through it and through its other names (a
# boxed member would hold a copy). A store into a box that can hold no
# Struct, or one whose classes the analysis cannot tell (a method's
# answer, an ivar), types no member, and no `[]=` retypes a String member:
# a computed key, or a box, may reach another member or never run.
S = Struct.new(:x)
s = +"abc"
o = S.new(s)
s << "d"
p o.x
o.x << "e"
p s
q = [{x: 1}, 2][0]
q[:x] = 4
k = [:x, :y][ARGV.size]
q[k] = 4.5
p q

def pick(i) = [[1, 2], {0 => 1}][i]
r = pick(ARGV.size)
r[0] = 5
p r

class Box
  def initialize(v); @v = v; end
  def set(k, val); @v[k] = val; self; end
  def v = @v
end
p Box.new({a: 1}).set(:a, 2).v
p Box.new([1]).set(0, 2).v
p o.x

# a computed key on a receiver typed as the Struct, storing into another
# member
T = Struct.new(:a, :b)
w = +"w"
t = T.new(w, 2)
k = ARGV.size
t[k + 1] = 3
t.a << "!"
p w, t

# the same through a box
U = Struct.new(:x, :n)
s2 = +"abc"
m = U.new(s2, 1)
b = [U.new(+"q", 2), 0][ARGV.size]
b[k + 1] = 4
m.x << "e"
p s2, b
