# The class-body macro form declines: a block that calls a bare super.
class Root
  def a = :root
end
class Base < Root
  def self.mk(n) = define_method(n) { super }
end
class Foo < Base
  mk :a
end
begin
  p Foo.new.a
rescue RuntimeError => e
  puts e.class
end
