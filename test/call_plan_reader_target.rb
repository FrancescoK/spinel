# Reader dispatch includes a subclass's overriding method.
class Base
  attr_reader :value
  def initialize = @value = 1
  def implicit = value
  def explicit = self.value
end
class Child < Base
  def value = 2
end
[Base.new, Child.new].each { |object| p object.implicit; p object.explicit }
