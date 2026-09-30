# A bare `super` passes the method's keywords on, and a parent saying
# `**nil` refuses them as it refuses a call's: "no keywords accepted",
# ahead of its count, for a named keyword of the method's always and for its
# `**` when that holds a key. The parent binds them nowhere, so the super
# answered as if none had come. Through a class parent, an included and a
# prepended module, a class method, a yielding parent, `initialize`, and a
# method with a rest and a post called with a leading splat.
def t
  p yield
rescue ArgumentError => e
  p e.message
end
h = { z: 5 }
e = {}
class A1; def a(x, **nil) = [x]; end
class A2 < A1; def a(x, **o) = super; end
t { A2.new.a(1, **h) }
t { A2.new.a(1, z: 5) }
t { A2.new.a(1, **e) }
class B1; def b(x, **nil) = [x]; end
class B2 < B1; def b(x, k: 1) = super; end
t { B2.new.b(1) }
class C1; def c(x, **nil) = [x]; end
class C2 < C1; def c(x, **) = super; end
t { C2.new.c(1, **h) }
t { C2.new.c(1) }
module DM; def d(x, **nil) = [x]; end
class D1; include DM; def d(x, **o) = super; end
t { D1.new.d(1, **h) }
module EM; def e(p1, *r, p2, **nil) = [p1, r, p2]; end
class E1; prepend EM; def e(*, **) = [:e1]; end
class E2 < E1; def e(p1, *r, p2, **o) = super; end
t { E2.new.e(*[nil, 2], 3, 4, **h) }
t { E2.new.e(*[nil, 2], 3, 4, **e) }
module FM; def f(x, k: 0, **o) = super; end
class F1; prepend FM; def f(x, **nil) = [x]; end
t { F1.new.f(1) }
t { F1.new.f(1, k: 2) }
class G1; def self.g(x, **nil) = [x]; end
class G2 < G1; def self.g(x, **o) = super; end
t { G2.g(1, **h) }
t { G2.g(1) }
class H1; def h(x, **nil) = yield(x); end
class H2 < H1; def h(x, **o) = super; end
t { H2.new.h(1, **h) { |v| [v] } }
t { H2.new.h(1) { |v| [v] } }
class I1; def initialize(x, **nil) = (@x = x); attr_reader :x; end
class I2 < I1; def initialize(x, **o) = super; end
t { I2.new(1, **h).x }
t { I2.new(1).x }
class J1; def j(x, y, **nil) = [x, y]; end
class J2 < J1; def j(x, **o) = super; end
t { J2.new.j(1, **h) }
t { J2.new.j(1) }
