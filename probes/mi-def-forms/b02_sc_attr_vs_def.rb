class Foo
  def self.y = 1
  singleton_class.attr_reader :x
  @x = 7
end
p Foo.method(:y).owner == Foo.singleton_class
p Foo.respond_to?(:x)
p Foo.x
class Bar
  singleton_class.attr_writer :w
  def self.w = @w
end
Bar.w = 3
p Bar.w
p Foo.singleton_class.instance_methods(false).sort
