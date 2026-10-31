# The class-body macro form declines: a block that reads a captured String as an operand.
class Base
  def self.mk(n, d) = define_method(n) { |v = nil| v || d }
end
class Foo < Base
  mk :a, "dflt"
end
p Foo.new.a, Foo.new.a("x")
