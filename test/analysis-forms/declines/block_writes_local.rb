# The class-body macro form declines: a block that writes the macro's local.
class Base
  def self.mk(n)
    count = 0
    define_method(n) { count += 1 }
  end
end
class Foo < Base
  mk :a
end
f = Foo.new
p f.a, f.a
