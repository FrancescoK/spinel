# The class-body macro form declines: a method_added hook.
class Base
  def self.method_added(m) = puts("added #{m}")
  def self.mk(n) = define_method(n) { 1 }
end
class Foo < Base
  mk :a
end
p Foo.new.a
