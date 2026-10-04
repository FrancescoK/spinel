# is_a? / kind_of? / instance_of? with the class computed at run time (passed
# through a method, stored in an ivar): a builtin receiver answers it (it
# raised NoMethodError, nil answered false), and instance_of? inside a method
# a subclass inherits reads the object's own class (it read the method's).
def w(v, d = nil) = v
class Cell
  def set(v) = (@v = v; self)
  def get = @v
end
class Animal
  def kind = instance_of?(w(Animal)) ? "plain" : "other"
  def dog? = instance_of?(Cell.new.set(Dog).get)
end
class Dog < Animal; end
p Animal.new.kind, Dog.new.kind, Dog.new.dog?, Animal.new.dog?
p 5.instance_of?(w(Integer)), 5.is_a?(w(Numeric)), 5.is_a?(w(String))
p "s".is_a?(w(String)), :a.kind_of?(w(Symbol)), [1].is_a?(w(Enumerable))
p nil.is_a?(w(NilClass)), 1.5.instance_of?(w(Float)), true.is_a?(w(TrueClass))
p (1..2).is_a?(Cell.new.set(Range).get)
p((5.is_a?(Cell.new.set(3).get) rescue [$!.class, $!.message]))
