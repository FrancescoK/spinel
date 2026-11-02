class Foo
  singleton_class.attr_accessor :x
  self.x = 5
end
p Foo.x
p Foo.singleton_methods.sort
p Foo.method(:x).owner == Foo.singleton_class
