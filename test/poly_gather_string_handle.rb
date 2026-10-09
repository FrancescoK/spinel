# A poly dispatch whose arms gather a splat hands a String variable over as
# the String itself, so an arm appending to its parameter appends to the
# caller's.
# spinel: gc-minor
# spinel: share
class A
  def m(p1, *r) = (p1 << "a"; [p1, r])
end
class B
  def m(p1, *r) = (p1 << "b"; [p1, r])
end
class E
  def m(p1, p2, *r, p3) = (p1 << "e"; [p1, p2, r, p3])
end
class F
  def m(p1, p2, *r, p3) = (p1 << "f"; [p1, p2, r, p3])
end
[A.new, B.new].each do |o|
  v = +"s1"
  s = [2, 3]
  p [o.m(v, *s), v]
end
[E.new, F.new].each do |o|
  v = +"s1"
  s = [2, 3, 4]
  p [o.m(v, *s), v]
end
