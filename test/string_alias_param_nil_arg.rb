# A parameter appended to through a local alias (`t = y; t << x`) that is
# also passed nil: CRuby appends to the caller's String through either
# name. The nil argument widened the parameter to a boxed value, which the
# alias then appended to as a copy, so the caller lost the append (#6179,
# the alias-chain rule of #6470). The parameter now stays the caller's
# String, as one appended to directly does.
def m(y) = (t = y; t << "!" if t; y)
s = +"a"; m(s); p s
p m(nil)
u = nil; p m(u)

def k(y:) = (t = y; t << "?" if t; y)
w = +"w"; k(y: w); p w
p k(y: nil)

def d(y = nil) = (t = y; u = t; u << "#" if u; nil)
x = +"x"; d(x); p x
d; d(nil)

def rd(y) = (t = y; t.nil? ? 0 : t.size)
p rd(nil), rd(+"abc")

f = +"f"; f.freeze
begin; m(f); rescue FrozenError => e; p e.class; end
p f
