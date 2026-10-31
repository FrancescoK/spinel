# The class-body macro form declines: a call that ends the class body, whose
# value the macro's last statement does not give.
class Base
  def self.mk(n)
    if n == :a
      define_method(n) { 1 }
    else
      define_method(:other) { 2 }
    end
  end
end
class Foo < Base
  mk :a
end
p Foo.new.a
