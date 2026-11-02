class Foo
  @x = 1
  def self.x = @x
  p x
end
class Sub < Foo
  @x = 9
end
p Sub.x
