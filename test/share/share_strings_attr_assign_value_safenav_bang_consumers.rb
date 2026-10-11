# What follows a safe-navigation bang on an attribute assignment's value
# takes the String itself: a plain `<<` or `concat`, `freeze`, a method's
# value, an Array element, a conditional and a block, and a mix of safe and
# plain links, which raises NoMethodError where a plain link meets the nil;
# through a typed receiver and a boxed one, an attr_accessor and an
# explicit writer. The String changes, freezes and answers equal? through
# every name, an explicit writer and each receiver run once for each
# assignment, and appends after freeze on the assignment raise FrozenError;
# a bang on the assignment as a statement changes the String.
class K
  attr_accessor :a
  def initialize = (@a = +"k")
end
class W
  attr_reader :b, :n
  def initialize = (@b = +"w"; @n = 0)
  def c=(v)
    @n += 1
    @b = v
  end
end
class D
  attr_reader :d
  def initialize = (@d = +"d")
  def d=(v)
    @d = v.dup
  end
end

o = K.new
w = W.new
bo = [o, nil][0]

s = +"s"
(o.a = s)&.sub!("s", "Q").<<("1")
p [o.a, s, o.a.equal?(s)]
(bo&.a = s)&.downcase!.concat("2")
p [o.a, s]
r = (o.a = s)&.sub!("q", "s").freeze
p [r, s.frozen?, o.a.frozen?, r.equal?(s)]

t = +"t"
(w.c = t)&.upcase!.<<("1")
p [w.b, t, w.n]
r = if t.size > 1 then (w.c = t)&.sub!("T", "u").<<("2") end
p [r, t, w.n]
[1].each { (w.c = t)&.sub!("u", "v")&.<<("3") }
p [w.b, t, w.n]

def tail(o, s) = (o.a = s)&.sub!("x", "y").<<("1")
u = +"x"
r = tail(o, u)
p [r, u, r.equal?(u), o.a.equal?(u)]
e = [(o.a = u)&.sub!("zz", "q")&.<<("4"), (o.a = u)&.sub!("y", "z")&.<<("5")]
p [e, u, e[1].equal?(u)]
begin
  (o.a = u)&.sub!("zz", "q")&.<<("6").<<("7")
rescue NoMethodError => ex
  p ex.message[0, 30]
end
r = (o.a = u)&.sub!("z", "y")&.<<("6").<<("7")
p [r, u]

dd = D.new
bd = [dd, nil][0]
v = +"v"
bd&.d = v
bd.d = v
v << "!"
p [dd.d, v]

# appends after freeze on the assignment raise FrozenError, the writer run
# once; through a nil receiver the chain is nil
f = +"f"
begin
  (w.c = f)&.freeze&.<<("!")
rescue FrozenError => ex
  p ex.class
end
p [w.n, f.frozen?, w.b.equal?(f)]
nb = [o, nil][1]
p (nb&.a = f)&.freeze&.<<("!")

# each receiver runs once
$n = 0
def rec(x) = ($n += 1; x)
g = +"g"
(rec(o).a = g)&.sub!("g", "G").<<("1")
(rec(bo)&.a = g)&.downcase!&.<<("2")&.concat("3", "4")
r = (rec(w).c = g)&.upcase!.freeze
p [o.a, g, r, g.frozen?, $n]

# a bang on the assignment as a statement, safe navigation or not
h = +"h"
(o.a = h)&.upcase!
p [o.a, h, o.a.equal?(h)]
(rec(w).c = h)&.downcase!
(w.c = h).capitalize!
p [w.b, h, w.n, $n]
