# A class << self reader read through obj.class answers each class's own
# class-level ivar, set in the subclass's body; nil where none is set.
class Base
  class << self
    attr_reader :label
  end
  def label = self.class.label
end
class A < Base
  @label = 10
end
class B < Base
  @label = 20
end
class C < Base; end
class D < Base
  if true
    @label = 40
  end
end
p A.label
p [A.new, B.new, C.new, D.new].map(&:label)
p Base.new.label

class Shape
  def self.sides; @sides; end
  def sides = self.class.sides
end
class Tri < Shape
  def self.sides; @sides; end
  @sides = 3
end
p Tri.new.sides
p Shape.new.sides
