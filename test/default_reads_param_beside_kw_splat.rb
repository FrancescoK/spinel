# A default reading an earlier parameter (`def m(p1, p2 = p1, **kw)`) reads
# it through a call on an object that passes a `**`. Such a call reads its
# keywords out of the hash the `**` builds, and the object-receiver path
# bound the parameters to named temps a later default reads only when the
# call had no `**`, so the default spelled the callee's `lv_p1` at the call
# site and the C did not build. Through an instance method, `send` and
# `public_send`, a `**` of an empty hash and a keyword default reading a
# positional; the virtual dispatch and class values bound them already.
h = { z: 2 }
e = {}
g = { k: 4 }
class C
  def m(p1, p2 = p1, **kw) = [:c, p1, p2, kw]
  def n(p1, p2 = p1, k: p2) = [:c, p1, p2, k]
  def o(p1 = 51, p2 = p1) = [:c, p1, p2]
  def q(p1 = 51, p2 = p1) = [:c, p1, p2]
  def s(p1, p2 = p1, **kw) = [:c, p1, p2, kw]
end
class D
  def m(p1, p2 = p1, **kw) = [:d, p1, p2, kw]
end
class K
  def self.m(p1, p2 = p1, **kw) = [:k, p1, p2, kw]
end
class L
  def self.m(p1, p2 = p1, **kw) = [:l, p1, p2, kw]
end
p C.new.m(1, **h)
p C.new.m(1, 5, **h)
p C.new.m(1, **e)
p C.new.n(1, **g)
p C.new.n(1, 3, **e)
p C.new.public_send(:o, z: 2, **e)
p C.new.q(z: 1, **e)
p C.new.send(:s, 1, **h)
[C.new, D.new].each { |x| p x.m(1, **h) }
[K, L].each { |x| p x.m(1, **h) }
p K.m(2, **h)
