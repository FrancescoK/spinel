# A method an included, prepended or extended module supplies is copied into
# each class that takes it, and the copy must keep the method's whole
# parameter layout. It lost the parameters after a rest, so `super(1)` into an
# included `def m(*r, p1)` gave the rest the 1 and p1 its zero, and a direct
# call or `send` did the same. A super reaching the copy through the class's
# own method of that name left out its `&b`, and did not link. A default
# reading an earlier parameter (`p2 = p1`) was typed against the module's
# original, an Integer, while the copy's parameter took its own callers'
# values, and did not compile.

module RestPost; def m(*r, p1) = [r, p1]; end
class I1; include RestPost; def m = super(1); end
class I2; include RestPost; def m(a, b) = super(a, b, 3); end
class I3; include RestPost; end
class I4 < I3; def m = super(*[4, 5]); end
p I1.new.m, I2.new.m(1, 2), I4.new.m, I3.new.m("x"), I3.new.send(:m, 6, 7)
p I3.new.method(:m).call(8), [I3.new, I1.new].map { |o| o.is_a?(I1) ? o.m : o.m(9) }

module Posts; def n(a, *r, b, c) = [a, r, b, c]; end
class Q1; prepend Posts; def n(*) = :q; end
class Q2 < Q1; def n = super(1, 2, 3); end
class Q3 < Q1; def n = super(1, 2, 3, 4, 5); end
p Q2.new.n, Q3.new.n, Q1.new.n(6, 7, 8)

module Blk; def k(p1, **kw, &b) = [p1, kw, b ? b.call : nil]; end
class B1; include Blk; def k = super(1); end
class B2; include Blk; def k(p1, **kw, &b) = super; end
class B3; include Blk; def k = super(2) { :blk }; end
class B4; prepend Blk; def k(*, **, &) = :b4; end
class B5 < B4; def k(&b) = super(3, z: 1, &b); end
p B1.new.k, B2.new.k(1, y: 2) { :g }, B3.new.k, B5.new.k { :h }

module PostKw; def q(p1 = 51, *r, p2, k1: 70, &b) = [p1, r, p2, k1, b ? b.call : nil]; end
class K1; include PostKw; def q = super(1); end
class K2; include PostKw; def q = super(1, 2, 3, k1: 4) { 5 }; end
class K3; include PostKw; def q(p1 = 51, *r, p2, k1: 70, &b) = super; end
p K1.new.q, K2.new.q, K3.new.q(8, 9) { 10 }

module Dflt; def d(p1 = 51, p2 = p1) = [p1, p2]; end
class D1; include Dflt; def d = super(*[]); end
class D2; include Dflt; def d = super("s"); end
class D3; prepend Dflt; def d(*) = :d3; end
class D4 < D3; def d = super(*[1.5]); end
class D5; include Dflt; end
p D1.new.d, D2.new.d, D4.new.d, D5.new.d(*[]), D5.new.d(:y)

module Ext; def e(p0 = 50, p2 = p0, *r, p1) = [p0, p2, r, p1]; end
class E1; extend Ext; end
class E2; end
o = E2.new
o.extend(Ext)
p E1.e(1, 2), E1.e("a"), o.e(3), o.e(:b, :c, :d)
