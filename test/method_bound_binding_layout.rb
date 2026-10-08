# The binders a call through a Method object, a bare `super` and a
# Class-value `new` go through lay the arguments out by the call's plan
# (arg_layout), as a direct call does: a count judged in CRuby's words, a
# leading optional funded after the requireds, a rest with its posts, a splat
# anywhere, keywords with a `**kwrest`, and the block. Each binder had its
# own index arithmetic that got some of these wrong or declined them, and a
# bare `super` dropped its `**` into a parent naming keywords.
# spinel: gc-minor
class O
  def initialize(v) = (@v = v)
  def a(x, *r, y) = [x, r, y]
  def b(x, y = @v, k: 2, **o, &blk) = [x, y, k, o, (blk ? blk.call : nil)]
  def c(p = 1, q) = [p, q]
  def d(x, y) = [x, y]
  def self.cm(a, *r, z: 0) = [a, r, z]
end
class Q < O
  def self.who(x = 1) = [name, x]
end

# Method#call on an object: rest and post, splats anywhere, keywords, a block
m = O.new(9).method(:a)
p m.call(1, 2)
p m.call(1, 2, 3, 4)
p m.call(*[1], 2, *[3])
p((m.call(1) rescue $!))
n = O.new(9).method(:b)
p n.call(1)
p n.call(1, 5, k: 3, z: 4) { :blk }
bb = proc { :amp }
p n.call(7, &bb)
p O.new(8).method(:c).call(7)
p((O.new(8).method(:d).call(*[1, 2, 3]) rescue $!))
p((O.new(8).method(:d).call(1, *[]) rescue $!))
p O.method(:cm).call(1, 2, 3, z: 4)
p Q.method(:who).call
p Q.method(:who).call(5)

# the same through a Method held in a slot of several kinds
x = [O.new(9).method(:a), 1][0]
p x.call(1, 2, 3)
y = [O.new(9).method(:b), 1][0]
p y.call(1, q: 2)
z = [O.new(9).method(:c), 1][0]
p z.call(4)

# Method#to_proc: a block reaches a `&blk`, posts, a leading optional,
# `**kwrest`, and `**nil` refusing keywords
def tb(p1, p2, *r, &b) = [p1, p2, r, (b ? b.call : nil)]
pr = method(:tb).to_proc
p pr.call(1, 2, 3)
p(pr.call(1, 2) { :blk })
p pr.call(1, 2, 3, &bb)
def po(a, *r, z) = [a, r, z]
q = method(:po).to_proc
p q.call(1, 2)
p q.call(1, 2, 3, 4)
p((q.call(1) rescue $!))
def lo(a = 5, b) = [a, b]
p method(:lo).to_proc.call(1)
p method(:lo).to_proc.call(1, 2)
def kr(a, k: 1, **kw) = [a, k, kw]
p method(:kr).to_proc.call(1, k: 2, z: 3)
p method(:kr).to_proc.call(1)
def nk(a, **nil) = [a]
p((method(:nk).to_proc.call(1, z: 2) rescue $!))
p O.new(6).method(:a).to_proc.call(1, 2, 3)

# a bound builtin whose call sites pass different counts, or a splat
pm = method(:puts)
a = [1, 2]
pm.call(*a)
pm.call(0, *a, 3)
cm = "ab".method(:center)
p cm.call(*[6])
p cm.call(*[6, "*"])
p cm.call(6, *["-"])

# a bare `super` passes this method's positionals as a call would
class B
  def m(a = 1, b) = [a, b]
  def n(a, *r, z) = [a, r, z]
  def w(a, b) = [a, b]
  def k(a, k: 0, **o) = [a, k, o]
  def self.c(a, b = 1, *r, z) = [a, b, r, z]
end
class C < B
  def m(x) = super
  def n(x, y, z = 9) = super
  def w(a) = super
  def k(a, k: 5, j: 6) = super
  def self.c(p, q, r, s, t) = super
end
c = C.new
p c.m(3)
p c.n(1, 2)
p c.n(1, 2, 3)
p((c.w(1) rescue $!))
p c.k(1)
p c.k(1, k: 2, j: 3)
p C.c(1, 2, 3, 4, 5)

# its `**`: the parent's keywords read from it, checked as a call's are,
# and through an included module or a prepended one
class B2
  def k(a, k: 0) = [a, k]
  def r(a, k:) = [a, k]
  def w(a, k: 0, **o) = [a, k, o]
end
class C2 < B2
  def k(a, **o) = super
  def r(a, **) = super
  def w(a, j: 1, **o) = super
end
c2 = C2.new
p c2.k(1, k: 5), c2.k(1)
p((c2.k(1, z: 5) rescue $!))
p c2.r(1, k: 2)
p((c2.r(1) rescue $!))
p c2.w(1, k: 2, z: 3)
module M2; def k(a, k: 0) = [:m, a, k]; end
class I2; include M2; def k(a, **o) = super; end
p I2.new.k(1, k: 2)
module P2; def k(a, **o) = [:pre, super]; end
class J2; prepend P2; def k(a, k: 1) = [a, k]; end
p J2.new.k(1, k: 2), J2.new.k(1)
# a parent keyword read from the `**` takes its value's type, and a post
# after the parent's rest any of the method's positionals
class B3
  def k(a, k: 0) = [a, k]
  def m(a, *r, z) = z
  def o(a = 1, b) = b
end
class C3 < B3
  def k(a, **o) = super
  def m(x, *y) = super
  def o(x, *r) = super
end
c3 = C3.new
p c3.k(1, k: "x"), c3.k(1)
p c3.m(1, "s"), c3.m(1, "s", :t), c3.m(1, 2)
p c3.o(4), c3.o(4, "w")

# `new` on a Class value: a Struct or Data built by keywords, a `**`
# among them, and an initialize with a rest or a leading optional
K = Struct.new(:a, :b, keyword_init: true)
D = Data.define(:a, :b)
S = Struct.new(:a, :b)
h = { a: "x", b: 2 }
[K, D, S].each { |k| p k.new(**h) }
[K, D].each { |k| p((k.new(a: 1, c: 2) rescue $!)) }
class R1
  def initialize(a, *r, z) = (@v = [a, r, z])
  def v = @v
end
class R2
  def initialize(a = 1, b, c) = (@v = [a, b, c])
  def v = @v
end
[R1, R2].each { |k| p k.new(1, 2, 3).v }
[R1, R2].each { |k| p((k.new(1).v rescue $!)) }

# a bound builtin's wrapper whose call sites disagree takes any count, none
# included, and an Array's or a String's slice reaches its [] by the count
sp = "a b".method(:split)
p sp.call(*[]), sp.call(" "), sp.name
fa = [1, 2, 3].method(:first)
p fa.call, fa.call(2), fa.to_proc.call
sl = [5, 6, 7].method(:slice)
p sl.call(1), sl.call(0, 2), sl.name
ssl = "hello".method(:slice)
p ssl.call(1), ssl.call(1, 3)

# a lone `**h` into a Class value's initialize taking no keywords is one
# positional Hash, or none when h is empty
class Op; def initialize(opts) = (@v = opts); def inspect = "Op(#{@v})"; end
class Qo; def initialize(a, b = 1) = (@v = [a, b]); def inspect = "Qo#{@v}"; end
kh = { x: 5 }
eh = {}
p [Op][0].new(**kh)
[Qo, Op].each { |k| p k.new(**kh) }
p [Qo][0].new(7, **eh), [Qo][0].new(7, **kh)
p(([Op][0].new(**eh) rescue $!))

# a local re-written to another Method calls the one it holds, and answers
# for it
class Ra; def x(s) = "Ra #{s}"; end
class Rb; def y(s, t = 2) = [s, t]; end
def rtop(s) = "rtop #{s}"
rm = Ra.new.method(:x)
p rm.call("q")
rm = method(:rtop)
p rm.call("r"), rm.arity, rm.owner, rm.parameters
rn = Ra.new.method(:x)
p rn.call(1)
rn = Rb.new.method(:y)
p rn.call(3), rn.call(3, 4), rn.arity
ro = Ra.new.method(:x)
ro = ro.dup
p ro.call(:d)

# an inherited class method runs on the class the Method was taken from
class Par; def self.make = new; def self.tag(t = 0) = "#{name}#{t}"; end
class Sub < Par; end
p Sub.method(:make).call.class, Par.method(:make).call.class
st = Sub.method(:tag)
p st.call, st.call(1), st.to_proc.call(3), Par.method(:tag).call(2)

# a bare super into an included module's method lays out as any bare super
module Mx; def m(a, *r) = "Mx#{a}#{r}"; end
class Cx; include Mx; def m(a, b) = super; end
module My; def m(a, b = 5) = "My#{a}#{b}"; end
class Cy; include My; def m(a) = super; end
module Mq; def m(a, b) = "Mq" + super; end
class Cq; prepend Mq; def m(a, *r) = "Cq#{a}#{r}"; end
p Cx.new.m(1, 2), Cy.new.m(1), Cq.new.m(1, 2)
