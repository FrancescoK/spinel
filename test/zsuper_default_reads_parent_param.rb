# A bare super into a parent whose default reads an earlier parameter
# (`p2 = p1`) fills it from the parent's binding of that parameter, typed as
# the parent takes it, where the method's own parameter is named or typed
# otherwise.
# spinel: gc-minor
# spinel: share
def wrap(v) = v
def defaults(p1 = 51, p2 = p1, p3, &b)
  wrap([p1, p2, p3, (b ? b.call : nil)])
end
def grow(p1, &b) = (p1 << "x"; [p1, (b ? b.call : nil)])
module M
  def m(p1, p2 = p1, *r, p3) = [p1, p2, r, p3]
end
class C
  include M
  def m(p1, p2 = p1, *r, p3) = super
end
h = nil
p C.new.m(:v1, 2, 3, **h)
p C.new.m(:v1, 2, **h)
p C.new.m(:v1, 2, 3, 4)

# The parent's names, not the method's own: `p1` is the parent's.
class P
  def m(p1, p2 = p1, *r, p3) = [p1, p2, r, p3]
end
class D < P
  def m(a, b = 7, *r, z) = super
end
p D.new.m(:v1, 2)
p D.new.m(:v1, 2, 3)
class Q
  def n(p1, p2 = p1.size) = [p1, p2]
end
class E < Q
  def n(a, *r) = super
end
p E.new.n("abc")
p E.new.n("abc", 1)
