class Foo
  @x = 1
  p respond_to?(:x)
  self.singleton_class.attr_reader "x"
  p respond_to?(:x)
  p x
end
module M
  singleton_class.attr_accessor :conf
  self.conf = {a: 1}
end
p M.conf
class Sub < Foo
  @x = 9
end
p Sub.x
p Foo.singleton_methods.include?(:x)
