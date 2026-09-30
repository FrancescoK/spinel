# A Struct's member is a reader too: `self.x` in a method of the Struct reaches
# the `def x` a subclass gives it.
Pt = Struct.new(:x, :y) do
  def sum = self.x + self.y
  def me = self
  def sum2 = me.x + me.y
  def x_s = self.x.to_s
end
class Pt3 < Pt
  def x = 100
end
class Pt5 < Pt
  def y = 50
end
p [Pt.new(1, 2).sum, Pt3.new(1, 2).sum, Pt5.new(1, 2).sum]
p [Pt.new(1, 2).sum2, Pt3.new(1, 2).sum2, Pt5.new(1, 2).sum2]
p [Pt.new(1, 2).x_s, Pt3.new(1, 2).x_s]

class Q < Struct.new(:a, :b)
  def tot = self.a + self.b
end
class Q2 < Q
  def a = 10
end
p [Q.new(1, 2).tot, Q2.new(1, 2).tot]

K = Struct.new(:a, :b, keyword_init: true) do
  def tot = self.a + self.b
end
class K2 < K
  def b = 1000
end
p [K.new(a: 1, b: 2).tot, K2.new(a: 1, b: 2).tot]

D = Data.define(:a, :b) do
  def tot = self.a + self.b
end
class D2 < D
  def a = 10
end
p [D.new(a: 1, b: 2).tot, D2.new(a: 1, b: 2).tot]
