# The class-body macro form declines: a block that reads a constant, its macro defined in another body.
class Base
  K = 1
  def self.mk(n) = define_method(n) { K }
end
class Foo < Base
  K = 2
  mk :a
end
p Foo.new.a
