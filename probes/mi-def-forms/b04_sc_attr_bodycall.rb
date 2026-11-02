class Foo
  @x = 1
  singleton_class.attr_reader :x
  p x
end
class Sub < Foo
  @x = 9
end
p Sub.x
