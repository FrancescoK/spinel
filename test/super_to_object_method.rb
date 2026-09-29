# A class's super reaches a method the program defines on Object: the chain
# of every class ends there.
class Object
  def describe(x = 1) = "obj #{x} #{self.class}"
  def each_twice
    yield 1
    yield 2
  end
end
class A
  def describe(x = 5) = "A(" + super + ")"
  def each_twice
    super { |v| yield v * 10 }
  end
end
class B < A
  def describe(x = 7) = "B[" + super(x + 1) + "]"
end
p A.new.describe, B.new.describe, B.new.describe(0)
r = []
A.new.each_twice { |v| r << v }
p r
