# The class-body macro form declines: something the record cannot follow ran in the class body before the call.
class Base
  def self.mk(n) = define_method(n) { 1 }
end
class Foo < Base
  class_eval(ARGV.empty? ? "def b = 2" : "def b = 3")
  mk :a
end
p Foo.new.a, Foo.new.b
