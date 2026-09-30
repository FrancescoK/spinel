# A local that a lambda, proc or kept block assigns is read where it is
# written, ahead of a later argument that calls the closure, as CRuby
# evaluates arguments left to right: `m2(v, la.call)` for
# `la = -> { v = 0; 5 }` binds the 1. The read of the closure's shared cell
# used to stay beside the call, where C's unspecified order let it see the 0.
# A builtin's operands order a local read the same way against a later
# operand that assigns it, a parenthesized write or an Array literal.
def m2(a, b) = [a, b]
def mk(a, k:) = [a, k]
def mkr(a, **kw) = [a, kw]
def ms(a, *r) = [a, r]
def mb(a, &b) = [a, b.call]
def kw(a:, b:) = [a, b]
def opt(a, b = 7) = [a, b]
def run(l) = l.call
def keep(&b) = $kept = b

class Base
  def initialize(a = 0, b = 0) = (@a = a; @b = b)
  def pair = [@a, @b]
  def m(a, b) = [a, b]
  def s(a, b) = [a, b]
  def self.cm(a, b) = [a, b]
end

class Sub < Base
  def m(a, b)
    v = a
    la = -> { v = 0; b }
    super(v, la.call)
  end

  def s(a, b) = super
end

class P1; def pm(a, b) = [:p1, a, b]; end
class P2; def pm(a, b) = [:p2, a, b]; end
class K1; def self.km(a, b) = [:k1, a, b]; end
class K2; def self.km(a, b) = [:k2, a, b]; end

def yl(a, b) = yield(a, b)

def in_yield
  v = 1
  la = -> { v = 0; 5 }
  yl(v, la.call) { |a, b| [a, b] }
end

def yv
  v = 1
  la = -> { v = 0; 5 }
  yield(v, la.call)
end

v = 1
la = -> { v = 0; 5 }
lh = -> { v = 0; { k: 5 } }
lr = -> { v = 0; [5, 6] }

# positional, through each spelling of the call
p m2(v, la.call)
v = 1; p m2(v, la.())
v = 1; p m2(v, la[])
v = 1; p m2(v, run(la))
# keywords, a `**` and a splat
v = 1; p mk(v, k: la.call)
v = 1; p mk(v, **lh.call)
v = 1; p mkr(v, **lh.call)
v = 1; p ms(v, *lr.call)
v = 1; p kw(a: v, b: la.call)
v = 1; p kw(b: la.call, a: v)
v = 1; p opt(v, la.call)
# a block argument and a block
v = 1; p mb(v, &la)
v = 1; p(mb(v) { la.call })
# yield
p in_yield
p(yv { |a, b| [a, b] })
# instance and class methods, super, send and Method#call
v = 1; p Base.new.m(v, la.call)
v = 1; p Sub.new.m(1, 5)
v = 1; p Sub.new.s(v, la.call)
v = 1; p Base.cm(v, la.call)
v = 1; p Base.new.send(:m, v, la.call)
v = 1; p Base.new.method(:m).call(v, la.call)
v = 1; p Base.new(v, la.call).pair
# instance_exec
v = 1; p(Object.new.instance_exec(v, **lh.call) { |a, k:| [a, k] })
v = 1; p(Object.new.instance_exec(v, la.call) { |a, b| [a, b] })
# a poly receiver and a Class value
p([P1.new, P2.new].map { |o| v = 1; o.pm(v, la.call) })
p([K1, K2].map { |k| v = 1; k.km(v, la.call) })
# a proc's and a lambda's own call, and a Struct
v = 1; pr = proc { |a, b| [a, b] }; p pr.call(v, la.call)
v = 1; p(->(a, b) { [a, b] }.call(v, la.call))
v = 1; p Struct.new(:a, :b).new(v, la.call).to_a
# operators on the local
v = 1; p v + la.call
v = 1; p v == la.call
v = 1; p v - run(la)
# a builtin's operands
v = 1; p v.divmod(la.call)
v = 1; p "abcdef"[v, la.call]
v = 1; p 2.pow(v, la.call)
v = 1; p v.to_s(la.call * 2)
# ...and a builtin's operand that assigns the local itself, or an Array
# literal built ahead of the call
u = 1; p u.divmod((u = 0; 5))
u = 1; p "abcdef"[u, (u = 0; 5)]
u = 1; p 2.pow(u, (u = 0; 5))
u = 1; p u.to_s((u = 0; 5) * 2)
ar = [9, 8, 7]
u = 1; p ar.first(u) + [(u = 0; 5)]
v = 1; p ar.first(v) + [la.call]
xs = [1]; p xs.push([(xs = [9]; 2)])
# other kinds of local
s = +"a"; ls = -> { s = +"b"; 5 }; p m2(s, ls.call)
f = 1.5; lf = -> { f = 0.5; 5 }; p m2(f, lf.call)
ar = [1]; lar = -> { ar = [0]; 5 }; p m2(ar, lar.call)
# a lambda whose parameter's default assigns the local
d = 1; ld = ->(q = (d = 0)) { { k: 5 } }; p mk(d, **ld.call)
e = 1; le = ->(k: (e = 0)) { { k: 5 } }; p mkr(e, **le.call)
# a kept block, and a lambda made inside a proc
x = 1
keep { x = 0; 5 }
p m2(x, $kept.call)
w = 1
outer = proc { -> { w = 0; 5 } }
li = outer.call
p m2(w, li.call)
