# The class-body macro form declines: a block that answers a String the macro made.
class Base
  def self.mk(n)
    s = n.to_s
    define_method(n) { s }
  end
end
class Foo < Base
  mk :a
end
f = Foo.new
f.a << "!"
p f.a
