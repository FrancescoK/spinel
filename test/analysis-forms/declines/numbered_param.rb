# The class-body macro form declines: a block with numbered parameters.
class Base
  def self.mk(n) = define_method(n) { [1, 2].map { _1 * 2 } }
end
class Foo < Base
  mk :a
end
p Foo.new.a
