# Method invocation remains admitted when the source target is not unique.
class MethodSource
  def first = 11
  def second = 22
end
x = MethodSource.new
m = x.method(:first)
p m.call
m = x.method(:second)
p m.call
