# Inherited class methods whose bodies fan out into each other. Deciding
# whether Sub needs its own copy walks the bare-call graph from each one;
# a walk without a visited set is exponential in this shape and never
# returned (the diamond repeats at every level: m_i calls m_{i+1} twice).
class Base
  def self.m0 = m1 + m1
  def self.m1 = m2 + m2
  def self.m2 = m3 + m3
  def self.m3 = m4 + m4
  def self.m4 = m5 + m5
  def self.m5 = m6 + m6
  def self.m6 = m7 + m7
  def self.m7 = m8 + m8
  def self.m8 = m9 + m9
  def self.m9 = m10 + m10
  def self.m10 = m11 + m11
  def self.m11 = m12 + m12
  def self.m12 = m13 + m13
  def self.m13 = m14 + m14
  def self.m14 = m15 + m15
  def self.m15 = m16 + m16
  def self.m16 = m17 + m17
  def self.m17 = m18 + m18
  def self.m18 = m19 + m19
  def self.m19 = m20 + m20
  def self.m20 = m21 + m21
  def self.m21 = m22 + m22
  def self.m22 = m23 + m23
  def self.m23 = m24 + m24
  def self.m24 = m25 + m25
  def self.m25 = m26 + m26
  def self.m26 = m27 + m27
  def self.m27 = m28 + m28
  def self.m28 = m29 + m29
  def self.m29 = m30 + m30
  def self.m30 = 1
end
class Sub < Base
  def self.m30 = 2
end
p Base.m0
p Sub.m0
