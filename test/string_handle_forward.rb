# A String variable a method hands on -- through `super` after a `**h`
# call, or through a forwarded `*` rest, `*`, `...` -- is the caller's own
# String, as in CRuby: the method the argument lands on appends to it
# (#6179).
# spinel: gc-minor
X = "x" * 100

# a parameter a `**h` call types POLY, handed on by `super`
class P
  def m(p1, k1:) = (p1 << X; nil)
  def n(p1, k1: 0) = (p1 << X; nil)
end
class C < P
  def m(p1, k1:) = super
  def n(p1, k1: 0) = super(p1, k1: k1)
end
a = +"a"
C.new.m(a, **{k1: 3})
h = {k1: 4}
C.new.n(a, **h)
p a.size

# a zsuper into an explicit `super` that hands the parameter on
class P2; def m(p1, k1: 0) = (p1 << X; nil); end
class C2 < P2; def m(p1, k1: 0) = super(p1, k1: 2); end
class D2 < C2; def m(p1, k1: 0) = super; end
a2 = +"a"
D2.new.m(a2, **{k1: 1})
p a2.size

# a rest forwarded by `*a`, `*`, `...`, a lead argument ahead of it, and
# forwarders forwarding to each other
def grow(p1) = (p1 << X; nil)
def grow2(p1, p2) = (p2 << X; nil)
def grow_k(p1, k: 0) = (p1 << X; nil)
def fwd_named(*r) = grow(*r)
def fwd_anon(*) = grow(*)
def fwd_all(...) = grow(...)
def fwd_all_k(...) = grow_k(...)
def fwd_lead(x, *r) = grow2(x, *r)
def fwd_everything(*r, **kw, &b) = grow_k(*r, **kw, &b)
def fwd_twice(*r) = fwd_named(*r)
b = +"b"
fwd_named(b)
fwd_anon(b)
fwd_all(b)
fwd_all_k(b, k: 1)
fwd_lead(1, b)
fwd_everything(b, k: 2)
fwd_twice(b)
fwd_named(+"lit")
p b.size

# a parameter of the caller's handed to a forwarder
def outer(y) = fwd_named(y)
c = +"c"
outer(c)
p c.size

# `new` forwarded from a class method, and `def m(*) = super`
class Box
  attr_reader :n
  def initialize(p1) = (p1 << X; @n = p1.size)
  def self.build(*r) = new(*r)
end
class Q
  def m(p1) = (p1 << X; nil)
end
class R < Q
  def m(*) = super
end
d = +"d"
box = Box.build(d)
R.new.m(d)
p d.size, box.n

# a zsuper beside a child's `**o` into an included module's method, also
# from a call that splats and passes `**h`; a splatted local Array into a
# forwarder
module Grow
  def g(p1, p2, p3 = 0, *r, k1:) = (p1 << X; nil)
end
class Inc
  include Grow
  def g(p1, p2, p3 = 0, *r, k1:, **o) = super
end
f = +"f"
Inc.new.g(f, 2, k1: 1)
rest = [2]
kw = {}
Inc.new.g(f, *rest, 3, **kw, k1: 4)
fwd_anon(*[f])
arr = [f]
fwd_named(*arr)
p f.size

# a chain of six forwarders, and two that forward to each other
def fw6(*r) = fw5(*r)
def fw5(*r) = fw4(*r)
def fw4(*r) = fw3(*r)
def fw3(*r) = fw2(*r)
def fw2(*r) = fw1(*r)
def fw1(*r) = grow(*r)
def ca(n, *r) = n > 0 ? cb(n - 1, *r) : nil
def cb(n, *r) = n > 0 ? ca(n - 1, *r) : grow(*r)
g = +"g"
fw6(g)
ca(3, g)
p g.size

# a method that only reads leaves the String alone
def size_of(p1) = p1.size
def fwd_read(*r) = size_of(*r)
e = +"e"
p fwd_read(e), e

# frozen, and bytes
fz = "fz".freeze
begin
  fwd_named(fz)
rescue FrozenError
  p :frozen
end
bin = +"a\0b"
fwd_all(bin)
p bin.bytesize, bin.bytes.first(4)
