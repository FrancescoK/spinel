# The class-body macro form declines: a call that is not a statement of the class body itself.
class Base
  def self.mk(n) = define_method(n) { 1 }
end
class Foo < Base
  mk :a if ARGV.empty?
end
p Foo.new.a
