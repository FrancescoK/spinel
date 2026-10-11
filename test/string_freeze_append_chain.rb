# freeze over an append chain on a variable freezes that variable's String
# and answers it: every name of the String sees the freeze

s = +"a"
(s << "q").freeze
p s.frozen?, s

t = +"b"
x = (t.concat("w")).freeze
p t.frozen?, x.equal?(t), x

u = +"c"
y = (u << "1" << "2").freeze
p u.frozen?, y.equal?(u), y

v = +"d"
z = (v << "1").freeze.size
p v.frozen?, z

w = +"e"
q = [(w << "1").freeze]
p w.frozen?, q[0].equal?(w)

begin
  r = +"r"
  (r << "1").freeze
  r << "2"
rescue FrozenError => e
  p e.class, r
end

class C
  def initialize; @s = +"i"; end
  def go; (@s << "q").freeze; @s.frozen?; end
  def go2; v = (@s.concat("z")).freeze; [v.equal?(@s), @s.frozen?, @s]; end
end
p C.new.go
p C.new.go2

a = [+"e", +"f"]
(a[0] << "q").freeze
p a[0].frozen?, a
z2 = (a[1].concat("w")).freeze
p a[1].frozen?, z2.equal?(a[1])

h = {k: +"h"}
(h[:k] << "x").freeze
p h[:k].frozen?, h

$g = +"g"
(($g << "1")).freeze
p $g.frozen?

def m(s) = (s << "q").freeze
m1 = +"m"
mr = m(m1)
p m1.frozen?, mr.equal?(m1)

c1 = +"k"
[1].each { (c1 << "1").freeze }
p c1.frozen?, c1

n1 = +"n"
k = (n1 << "1").freeze
n2 = k
p n2.frozen?, n2.equal?(n1)

# an attribute reader's String, and a second name of a local's
class D
  attr_accessor :n
  def initialize; @n = +"n"; end
end
d = D.new
(d.n << "1").freeze
p d.n.frozen?, d.n
e2 = D.new
f = (e2.n.concat("2")).freeze
p e2.n.frozen?, f.equal?(e2.n)
s9 = +"s9"
t9 = s9
(t9 << "1").freeze
p s9.frozen?
u9 = +"u9"
p((u9 << "1").freeze.equal?(u9), u9.frozen?)
