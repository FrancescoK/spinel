# A String member mutated through another name (`t = s.a; t << "!"`) is
# the shared handle: the constructor and an attribute writer store the
# handle of a variable handed to them, or a fresh one for a new String,
# and `s[:a]` / `s.dig(:a)` read the member as `s.a` does.

S = Struct.new(:a, :b)
s = S.new(+"x", 1)
t = s.a
t << "!"
p s[:a], s.a, s.dig(:a), s[0], s.to_a

x = +"y"
s2 = S.new(x, 2)
t2 = s2.a
t2 << "!"
p s2.a, x

s.a = +"new"
s.a << "?"
p s.a

z = +"z"
s.a = z
z << "1"
u = s.a
u << "2"
p s.a, z

K = Struct.new(:a, :b, keyword_init: true)
w = +"w"
k = K.new(a: w, b: 3)
k.a << "!"
p k, w

D = Data.define(:a)
v = +"v"
d = D.new(a: v)
d.a << "!"
p d, v

N = Struct.new(:inner)
n = N.new(S.new(+"n", 4))
m = n.inner.a
m << "!"
p n.dig(:inner, :a)

class C
  attr_accessor :a
  def initialize(a) = (@a = a)
end
c = C.new(+"c")
c.a = +"new"
q = +"q"
c.a = q
r = c.a
r << "!"
p c.a, q

o = Struct.new(:a, :b).new(+"m" + "n", 1)
u = o.a
u << "?"
p o.a
y2 = +"y2"
o2 = Data.define(:a).new(a: y2)
o2.a << "?"
p o2.a, y2
