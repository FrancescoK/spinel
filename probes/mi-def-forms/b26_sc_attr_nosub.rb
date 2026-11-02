class Foo
  @x = 1
  singleton_class.attr_reader :x
  p x
end
class Sub < Foo
end
p Foo.x
