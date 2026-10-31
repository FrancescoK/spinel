# The class-body macro form declines: a core method a later macro runs, which an earlier macro defined.
class Base
  def self.mk(n) = define_method(n) { 1 }
  def self.up(n) = define_method(n.upcase) { 2 }
end
class Foo < Base
  mk :upcase
  up :b
end
p Foo.new.upcase, Foo.new.B
