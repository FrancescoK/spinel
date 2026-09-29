# A keyword written twice across a call's sources binds its last value, the
# `**`'s when it comes after the literal, also when a String key stands
# among them: `f(k1: 3, "s" => 4, **{k1: 5})` binds k1 5. The String key made
# the call give up on merging its sources in order, so the literal k1 bound
# 3; merged, the hash the check reads takes the String key by name. Through
# a direct call, a named keyword alone, a `**kwrest`, a rest and a splat, an
# explicit `super`, a yield, a poly receiver and a Method.
def t
  p yield
rescue ArgumentError => e
  p e.message
end
h = { k1: 5 }
def f(k1:, **kw) = [k1, kw]
def n(k1:) = k1
def w(**kw) = kw
t { f(k1: 3, "s" => 4, **{ "s" => 9 }) }
t { f("s" => 4, k1: 3, **h) }
t { n(k1: 3, "s" => 4, **h) }
t { w("s" => 1, "s" => 2) }
t { w("s" => 1, **{ "s" => 2 }) }
t { f(k1: 1, 1 => :a, **h) }
t { f(k1: 1, "s" => 4) }
def y(h) = yield(k1: 3, "s" => 4, **h)
t { y(h) { |k1:, **kw| [k1, kw] } }
class K; def m(k1:, **kw) = [k1, kw]; end
t { [K.new, K.new][0].m(k1: 3, "s" => 4, **h) }
t { K.new.method(:m).call(k1: 3, "s" => 4, **h) }
def g(*r, k1:, **kw) = [r, k1, kw]
p g(*[1], k1: 3, **h)
p g(*[1], k1: 3, "s" => 4, **h)
class B; def m(p1, *r, k1:, **kw) = [p1, r, k1, kw]; end
class C < B; def m = super(*[1, 2], k1: 3, **{ k1: 5 }); end
p C.new.m
class D < B; def m = super(*[1, 2], k1: 3, "s" => 4, **{ k1: 5 }); end
p D.new.m
