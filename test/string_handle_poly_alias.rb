# A variable that can hold other values besides a String (POLY) holds the
# String as a plain value, so a second name for it was a copy: `y = x`
# copied the box, and an append through either name, or through a callee
# either was handed to, answered a new String the other name never saw.
# The same held for a String a yielding method's POLY parameter yields to
# a block that appends to it, and for a POLY instance variable handed to an
# appending parameter. These now take the shared handle (#6475's lift): an
# alias plain, reversed, chained, `||=`, inside a method and a block; a
# yield, a spliced `b.call` and a proc passed as the block; and an ivar of
# an instance, the top level and a class method, through a call, a yield,
# an alias and a proc. Each append is 100 bytes, so it cannot land in spare
# capacity by chance.
# spinel: gc-minor
def pv(s) = [s, 1][0]
def gr(v) = v << "x" * 100
def yl(v) = yield(v)
def bc(v, &b) = b.call(v)
def wy(q) = yl(q) { |t| t << "w" * 100 }
def al(q) = (r = q; r << "m" * 100; q.size)

a1 = pv(+"a"); b1 = a1; b1 << "b" * 100; p a1.size
a2 = pv(+"a"); b2 = a2; a2 << "b" * 100; p b2.size
a3 = pv(+"a"); b3 = a3; gr(a3); p b3.size
a4 = pv(+"a"); b4 = a4; gr(b4); p a4.size
a5 = pv(+"a"); b5 = a5; c5 = b5; c5 << "c" * 100; p a5.size
a6 = pv(+"a"); c6 = b6 = a6; c6.concat("c" * 100); p [a6.size, b6.size]
a7 = pv(+"a"); b7 = nil; b7 ||= a7; b7 << "o" * 100; p a7.size
a8 = pv(+"a"); [1].each { b8 = a8; b8 << "e" * 100 }; p a8.size
a9 = pv(+"a"); b9 = a9; b9.upcase!; b9.insert(1, "i" * 100); p [a9[0], a9.size]
p al(pv(+"a")), al(+"a")

y1 = pv(+"y"); yl(y1) { |t| t << "s" * 100 }; p y1.size
y2 = pv(+"y"); yl(y2) { |t| u = t; u << "u" * 100 }; p y2.size
y3 = pv(+"y"); bc(y3) { |t| t << "s" * 100 }; p y3.size
y4 = pv(+"y"); wy(y4); p y4.size
y5 = pv(+"y"); pr = proc { |t| t << "p" * 100 }; yl(y5, &pr); bc(y5, &pr); p y5.size
y6 = pv(+"y"); yl(y6) { |t| t.size }; p y6

class C
  def initialize = (@i1 = pv(+"i"); @i2 = pv(+"i"); @i3 = pv(+"i"); @i4 = pv(+"i"))
  def run
    gr(@i1); yl(@i2) { |t| t << "y" * 100 }; j = @i3; j << "j" * 100
    pr = proc { |t| t << "p" * 100 }; pr.call(@i4)
    [@i1.size, @i2.size, @i3.size, @i4.size]
  end
end
p C.new.run
p Array.new(20) { C.new }.sum { |o| o.run.sum }
@t1 = pv(+"t"); gr(@t1); p @t1.size
class K; def self.run = (@k1 = pv(+"k"); gr(@k1); @k1.size); end
p K.run

# a frozen String still raises, a binary one keeps its bytes, and anything
# else is shared as it is
f1 = pv("fz".freeze); g1 = f1
begin; g1 << "x"; rescue FrozenError => e; p e.class; end
p [f1, f1.frozen?]
n1 = pv(+"a\0b"); m1 = n1; m1 << "c" * 100; p [n1.size, n1[0, 4], n1.encoding]
r1 = [[1], +"r"][0]; s1 = r1; s1 << 2; p r1
@fz = pv("fz".freeze); begin; gr(@fz); rescue FrozenError => e; p e.class; end
keep = []
20.times { |i| v = pv(+"g#{i}"); w = v; w << "z" * 100; keep << v }
p keep.sum(&:size)
