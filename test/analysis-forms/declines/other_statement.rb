# The class-body macro form declines: a macro body that does more than define methods.
class Base
  def self.mk(n)
    puts "making #{n}"
    define_method(n) { 1 }
  end
end
class Foo < Base
  mk :a
end
p Foo.new.a
