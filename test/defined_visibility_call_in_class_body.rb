# defined? does not run what it asks about: `defined?(private)` in a class
# body leaves the methods after it public, as does `defined?(private :m)`.
class Shape
  asked = defined?(private)
  def area = 1
  asked = defined?(protected) && defined?(private :area)
  def perimeter = 2
end

s = Shape.new
p s.area, s.perimeter
p Shape.public_method_defined?(:area), Shape.public_method_defined?(:perimeter)
