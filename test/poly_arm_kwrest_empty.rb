# A `**kw` parameter reached through a poly dispatch arm with no keywords
# at the call gets an empty hash. The arm handed the callee NULL, and the
# first read of the hash crashed.
# spinel: decisions
class A
  def m(x) = x
  def k(x, **kw) = kw.empty? ? x : kw
end
class B < A
  def m(x, **kw) = [x, kw.size]
  def k(x, **kw) = [x, kw.keys]
end
[A.new, B.new].each { |o| p o.m(3) }
[A.new, B.new].each { |o| p o.k(1) }
[A.new, B.new].each { |o| p o.k(1, a: 2) }
