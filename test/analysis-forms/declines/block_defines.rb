# The class-body macro form declines: a block with a def of its own.
class Base
  def self.mk(n) = define_method(n) { def inner = 3; inner }
end
class Foo < Base
  mk :a
end
p Foo.new.a
