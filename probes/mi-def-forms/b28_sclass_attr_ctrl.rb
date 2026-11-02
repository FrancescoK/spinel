class Foo
  @x = 1
  class << self
    attr_accessor :x
  end
  p x
end
class Sub < Foo
  @x = 9
end
Foo.x = 2
p Foo.x, Sub.x
p Foo.singleton_methods.sort
