# The class-body macro form declines: a captured value it does not write
# (an Array, which a literal would make anew at each call).
class Base
  def self.mk(n, v) = define_method(n) { v }
end
class Foo < Base
  mk :a, [1, 2]
end
f = Foo.new
f.a << 3
p f.a
