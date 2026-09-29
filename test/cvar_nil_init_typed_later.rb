# `@@x = nil` in a class body, for a class variable whose later writes type
# the slot (Integer here), reads back nil until the first real write: the
# initializer rendered the bare NilNode as 0 in an integer slot.
class A
  @@q = nil
  def self.q = @@q
  def self.q=(v)
    @@q = v
  end
end
p A.q
A.q = 1
p A.q
class B
  @@s = nil
  def self.s = @@s
  def self.s=(v)
    @@s = v
  end
end
p B.s
B.s = "x"
p B.s
class C
  @@f = nil
  def self.f = @@f
  def self.f=(v)
    @@f = v
  end
end
p C.f
C.f = 2.5
p C.f
