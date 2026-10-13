# spinel: reject-subclass: self inside class << X is X's singleton class, which Spinel does not model
# In `class << self` self is the singleton class (CRuby prints #<Class:Shape>),
# which Spinel does not model: refused rather than answered Shape.
class Shape
  class << self
    puts "defining on #{self}"
    def unit = new
  end
end
p Shape.unit
