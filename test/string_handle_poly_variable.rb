# A variable that can hold other values besides a String (POLY) holds the
# String as a plain value, so a method or a proc that appends to its
# parameter appended to a copy and the caller's variable kept the old
# String. The variable now hands over the shared handle (#6179): a local, a
# method's or a proc's parameter, a captured local, through a direct call,
# a proc, a Method, `send`, a class method, a poly receiver, `new`,
# `super` and a bare `super`, and a parameter handed on to such a method.
# Each append is 100 bytes, so it cannot land in spare capacity by chance.
# spinel: gc-minor
def pv(s) = [s, 1][0]
def gr(v) = v << "x" * 100
def m(q) = (gr(q); q)
c = proc { |q1| gr(q1); q1 }
p [c.call(+"k2").size, c.call([]).size, m(+"k2").size, m([]).size]

x = pv(+"k3"); gr(x); p x.size
x = pv(+"k3"); m(x); p x.size
s = +"k4"; m(s); p s.size
x = pv(+"k5"); c.call(x); p x.size
x = pv(+"k6"); f = ->(t) { t.concat("y" * 100) }; f.(x); f.([]) rescue 0; p x.size
x = pv(+"k7"); method(:gr).call(x); p x.size
x = pv(+"k8"); send(:gr, x); p x.size
x = pv(+"k9"); [1, 2].each { gr(x) }; p x.size
x = pv(+"kl"); l = -> { gr(x) }; l.call; l.(); p x.size

class K; def self.g(s) = s << "q" * 100; end
K.g([]); x = pv(+"ka"); K.g(x); p x.size

class A; def add(s) = s.insert(0, "z" * 100); end
class B; def add(s) = s << "w" * 100; end
o = [A.new, B.new][0]
o.add([]) rescue 0
x = pv(+"kb"); o.add(x); s = +"kc"; o.add(s); p [x[0], x.size, s.size]

class Box; def initialize(s) = s << "i" * 100; end
Box.new([]); x = pv(+"kd"); Box.new(x); p x.size

class P; def h(s) = s << "r" * 100; end
class Q < P; def h(s) = (super; s); end
class R < P; def h(s) = super(s); end
Q.new.h([]); R.new.h([])
x = pv(+"ke"); Q.new.h(x); s = +"kf"; R.new.h(s); p [x.size, s.size, Q.new.h(+"kg").size]

# a frozen String still raises, a binary one keeps its bytes, and anything
# else is handed over as it is
x = pv((+"fz").freeze)
begin; gr(x); rescue FrozenError => e; p e.class; end
p x
x = pv(+"a\0b"); gr(x); p [x.size, x[0, 4], x.encoding]
x = pv([1]); gr(x); p x.size
keep = []
20.times { |i| v = pv(+"g#{i}"); gr(v); keep << v }
p keep.sum(&:size)
