# A bare super from a method with a rest lends a leading parameter to the
# parent's appending one, also where the parent funds its posts ahead of
# its optionals.
# spinel: gc-minor
# spinel: share
class P
  def m(p1, p2 = 1, p3) = (p1 << "x"; [p1, p2, p3])
end
class C < P
  def m(p1, p2 = 1, *a, p3) = super
end
v = +"s1"
p [C.new.m(v, 4), v]
w = +"t1"
p [C.new.m(w, 2, 3), w]

module M
  def n(p1, p2, p3 = "d3", p4) = (p1 << "y"; [p1, p2, p3, p4])
end
class Q
  prepend M
  def n(*, **, &) = [:q]
end
class D < Q
  def n(p1, p2, p3 = "d3", *a, p4) = super
end
u = +"u1"
p [D.new.n(u, 2, 3), u]
