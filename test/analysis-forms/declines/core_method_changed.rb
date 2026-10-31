# The class-body macro form declines: a program change to a core method the macro ran.
class Symbol
  def upcase = :changed
end
class Base
  def self.mk(n) = define_method(n.upcase) { 1 }
end
class Foo < Base
  mk :a
end
p Foo.new.changed
