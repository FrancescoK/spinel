# A method called on an object binds its arguments by the call's positional
# layout, as a direct call does: a splat spreads in place into a rest target
# whatever sits beside it, the posts come from the end, a trailing splat's
# count is judged once every argument has run, and the arguments to the left
# of a splat run before it. The same holds through the virtual dispatch
# (arms that take the same parameters share one set of argument temps),
# `send`, `public_send`, `define_method`, and a method only the subclasses
# define.
def lg(x)
  puts "lg #{x.inspect}"
  x
end

def t(l)
  r = yield
  puts "#{l}: #{r.inspect}"
rescue ArgumentError => e
  puts "#{l}: #{e.class}: #{e.message}"
end

class O
  def r(p1, *r, k1: 70) = [p1, r, k1]
  def s(a, *r, b) = [a, r, b]
  def q(a = 5, *r, b) = [a, r, b]
  def u(a, b, *r) = [a, b, r]
  def v(a, b = 9) = [a, b]
  def h(a, *r) = [a, r]
  def k(a, *r, k:) = [a, r, k]
  def bs(s, t) = (s << "x"; [s, t])
  define_method(:dm) { |p1 = 51, *r, k1:, k2: 70| [p1, r, k1, k2] }
end

o = O.new
e = []
t("rest kw empty") { o.r(*[]) }
t("rest kw var") { o.r(*e, k1: 1) }
t("rest kw spread") { o.r(*[1, 2]) }
t("rest kw order") { o.r(lg(1), *lg([2]), k1: lg(3)) }
t("post one") { o.s(*[1]) }
t("post spread") { o.s(*[1, 2, 3, 4]) }
t("opt post") { o.q(*[1]) }
t("opt post spread") { o.q(*[1, 2, 3]) }
t("rest short") { o.u(*[1]) }
t("rest mid") { o.u(1, *[2, 3]) }
t("rest order") { o.u(lg(1), *lg([2, 3])) }
t("opt order") { o.v(lg(7), *lg([8])) }
t("count after args") { o.v(lg(7), *[8, 9, 10]) }
t("rest empty") { o.h(*e) }
t("rest hash") { o.h(*[1], z: 2) }
t("rest hash only") { o.h(*e, z: 2) }
t("rest req kw") { o.k(*[1, 2], k: 3) }
t("rest req kw short") { o.k(*e, k: 3) }
t("define_method") { o.dm(*[1], k1: 2) }
t("define_method spread") { o.dm(*[1, 2], **{ k1: 3 }) }
sb = String.new("a")
t("byref") { o.bs(sb, "b") }
t("byref elem") { o.bs(*[String.new("c"), "d"]) }
t("send") { o.send(:r, *[]) }
t("send spread") { o.send(:u, *[1, 2, 3]) }
t("public_send") { o.public_send(:s, *[1, 2]) }
t("public_send kw") { o.public_send(:r, *e, k1: 2) }

# the virtual dispatch: an override taking the same parameters
class B
  def r(p1, *r, k1: 70) = [:B, p1, r, k1]
  def s(a, *r, b) = [:B, a, r, b]
  def u(a, b, *r) = [:B, a, b, r]
  def v(a, b) = [:B, a, b]
  def x(a, *r, **kw) = [:B, a, r, kw]

  def go
    e = []
    t("v rest kw") { r(*[]) }
    t("v rest kw spread") { r(*[1, 2], k1: 3) }
    t("v post") { s(*[1, 2, 3]) }
    t("v post short") { s(*[1]) }
    t("v rest order") { u(lg(1), *lg([2, 3])) }
    t("v rest short") { u(1, *e) }
    t("v count order") { v(lg(1), *[]) }
    t("v kwrest") { x(*[1, 2], z: 1) }
    t("v kwrest short") { x(*e, z: 1) }
    t("v send") { send(:r, *e, k1: 4) }
  end
end

class D < B
  def r(p1, *r, k1: 70) = [:D, p1, r, k1]
  def s(a, *r, b) = [:D, a, r, b]
  def u(a, b, *r) = [:D, a, b, r]
  def v(a, b) = [:D, a, b]
  def x(a, *r, **kw) = [:D, a, r, kw]
end
B.new.go
D.new.go

# a method only the subclasses define
class Base
  def go
    t("sub spread") { run(*[1, 2]) }
    t("sub one") { run(1) }
    t("sub short") { run(*[]) }
  end
end
class K1 < Base
  def run(a, *r) = [:K1, a, r]
end
class K2 < Base
  def run(a, *r) = [:K2, a, r]
end
K1.new.go
K2.new.go

# a `(...)` forwarder's synthesized parameters are no count to judge; the
# method it forwards to judges the call
class F
  def two(a, b = 2) = [:two, a, b]
  def fw(...) = two(...)
  def go
    t("forward spread") { fw(*[1, 3]) }
    t("forward one") { fw(*[1]) }
    t("forward over") { fw(*[1, 2, 3]) }
  end
end
class G < F
  def fw(...) = two(...)
end
F.new.go
G.new.go

# a direct call runs the arguments to the left of a splat first too
def d(a, b, c) = [a, b, c]
t("direct order") { d(lg(1), *lg([2, 3])) }
