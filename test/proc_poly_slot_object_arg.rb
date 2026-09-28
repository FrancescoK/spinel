# A Proc read from a poly slot takes a user object without #to_int as an
# argument: only a bound Method converts the legacy int slot.

class Foo
  def inspect = "#<Foo>"
end
class Bar
  def inspect = "#<Bar>"
end
xs = [Foo.new, Bar.new, 1]
pr = proc { |a, k: 1| [a, k] }
boxed = [pr, 1]
xs.each do |x|
  p boxed[0].call(x)
  p boxed[0].call(x, k: 2)
  p boxed[0].call(x, {k: 2})
end
