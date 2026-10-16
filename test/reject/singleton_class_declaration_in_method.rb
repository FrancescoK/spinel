# spinel: reject-subclass: Object#singleton_class is not supported by AOT compilation
# A declaration on the singleton class inside a method runs when the method
# does, on whatever self is then: not a class body, so it stays refused.
class Foo
  def self.setup = singleton_class.send(:attr_accessor, :x)
end
Foo.setup
Foo.x = 1
p Foo.x
