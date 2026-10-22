# Object's Comparable inclusion supplies the operators to every class.
class Object
  include Comparable
end
class ObjectComparableOrder
  def <=>(other) = 0
end
class ObjectComparableChild < ObjectComparableOrder
end
a = ObjectComparableOrder.new
[a, ObjectComparableChild.new].each do |x|
  p(x < a)
  p(x <= a)
  p(x == a)
end
