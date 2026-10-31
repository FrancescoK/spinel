# The class-body macro form declines: a macro with a parameter other than a required one.
class Base
  def self.mk(n, v = 1) = define_method(n) { v }
end
class Foo < Base
  mk :a
end
p Foo.new.a
