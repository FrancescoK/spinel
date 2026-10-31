# The class-body macro form declines: a block that yields to the macro's block.
class Base
  def self.mk(n) = define_method(n) { yield }
end
class Foo < Base
  mk :a
end
begin
  Foo.new.a
rescue LocalJumpError => e
  puts e.class
end
