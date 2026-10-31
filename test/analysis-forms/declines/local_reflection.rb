# The class-body macro form declines: a block that reads the macro's binding.
class Base
  def self.mk(n)
    v = 5
    define_method(n) { binding.local_variable_get(:v) }
  end
end
class Foo < Base
  mk :a
end
p Foo.new.a
