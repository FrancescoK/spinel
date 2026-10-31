# The class-body macro form declines: a private section.
class Base
  def self.mk(n) = define_method(n) { 1 }
end
class Foo < Base
  private
  mk :a
end
p Foo.new.a
