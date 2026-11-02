class Foo
  @x = 1
  def self.x = @x
  p x
end
class Sub < Foo
end
p Foo.x
