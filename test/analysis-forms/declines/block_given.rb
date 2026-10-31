# The class-body macro form declines: a block that asks block_given?.
class Base
  def self.mk(n) = define_method(n) { block_given? }
end
class Foo < Base
  mk :a
end
p Foo.new.a, Foo.new.a { 1 }
