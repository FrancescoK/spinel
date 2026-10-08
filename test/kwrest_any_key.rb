# A `**kwrest` takes every keyword the call passes, whatever the class of
# its key: a String or Integer literal, a `**` of a hash keyed by another
# class or known only at run time, or a computed key answering something
# other than a Symbol or of a class inference never settles (a nil global).
# The rest was always a Symbol-keyed hash, so such a key was dropped
# silently, raised a TypeError, or was refused at compile time. A rest some
# call brings such a key now takes any key, through the
# direct call, a poly receiver, the virtual dispatch, a class method, `send`,
# `Method#call`, `super`, `...` and an anonymous `**`, and the hash reads
# as a Hash in the body and forwards on. A rest only Symbols reach is
# unchanged.
# spinel: gc-minor
def lit(x) = (puts "run #{x.inspect}"; x)
def rr(**k) = k
def mk(a, k: 0, **r) = [a, k, r]
def nk(a: 0) = a
def mixed(a, b = 2, *r, k: 0, **o) = [a, b, r, k, o]
def sym_only(**k) = k

p rr("s" => 1, a: 2)
p rr(1 => :x)
p rr(1.5 => 1, nil => 2, [1] => 3)
p mk(1, "s" => 2, k: 3)
p mixed(1, "x" => 1)
p mixed(1, 2, 3, k: 4, "x" => 5, y: 6)
h = { "s" => 1 }
p rr(**h)
p rr(a: 1, **{ "a" => 2 }, b: 3)
p rr(lit("q") => lit(1), lit(:b) => lit(2), c: lit(3))
$nokey = nil
p rr($nokey => 1, a: 2), mk(1, $nokey => 2, k: 3)
p rr(*[], "s" => 1)
sy = { b: 2 }
p rr(**sy), rr(**sy, "c" => 3), rr
p sym_only(a: 1), sym_only(**{ b: 2 }), sym_only

# the rest in the body, and forwarded on
def body(**k)
  p k[:a], k["s"], k.key?("s"), k.fetch(:a, 0), k.keys, k.size
  k.each { |kk, v| p [kk, v] }
  p k.merge(z: 1), k.transform_keys(&:to_s), k.empty?
end
body("s" => 1, a: 2)
body
def fwd(**k) = [rr(**k), mk(0, **k)]
p fwd("s" => 1, k: 2)
def named(**k) = nk(**k)
p named(a: 5)
begin
  named("s" => 1)
rescue ArgumentError => e
  p e.message
end
def inner(*a, **k) = [a, k]
def dots(...) = inner(...)
def anon(**) = rr(**)
p dots(1, "s" => 1, a: 2), dots(1, a: 2)
p anon("t" => 3, u: 4)
def anon_named(**) = nk(**)
p anon_named(a: 6)
begin
  anon_named("s" => 1)
rescue ArgumentError => e
  p e.message
end

# other call paths
class C
  def self.cr(**k) = k
  def initialize(**o) = (@o = o)
  attr_reader :o
  def im(x, **k) = [x, k]
end
class D < C
  def im(x, **k) = [:D, super]
end
class E < C
  def im(x, **k) = [:E, super(x, "z" => 9, **k)]
end
p C.cr("s" => 1, a: 2)
p C.new("s" => 1).o, C.new(a: 1).o
p D.new.im(1, "u" => 2), E.new.im(1, a: 3)
p send(:rr, "s" => 1, b: 2)
p method(:rr).call("t" => 3)
p ->(**k) { k }.call("s" => 1)

# poly receivers and the virtual dispatch
class A; def kw(**r) = [:A, r]; def nk(a: 0) = [:A, a]; def m(x, k: 0, **r) = [:A, x, k, r]; end
class B; def kw(**r) = [:B, r]; def nk(a: 0) = [:B, a]; def m(x, k: 0, **r) = [:B, x, k, r]; end
class Sub < A; def m(x, k: 0, **r) = [:Sub, x, k, r]; end
objs = [A.new, B.new]
p objs.map { |o| o.kw(**{ "s" => 1 }) }
p objs.map { |o| o.kw("t" => 2, a: 1) }
p objs.map { |o| o.kw(lit("u") => 2) }
p objs.map { |o| o.kw($nokey => 1) }
p objs.map { |o| o.kw(lit(:b) => 2, a: 1) }
p objs.map { |o| o.m(1, "s" => 2, k: 3, j: 4) }
p objs.map { |o| o.nk(lit(:a) => 2) }
begin
  objs.map { |o| o.nk("a" => 2) }
rescue ArgumentError => e
  p e.message
end
g = { "a" => 1 }
p objs.map { |o| o.m(0, **g, x: 1) }
v = [A.new, Sub.new][1]
p v.m(1, "s" => 2, k: 3)
