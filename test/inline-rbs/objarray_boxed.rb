# An Array[Foo] annotation on an instance variable is a request to unbox the
# array, which only holds while every use of it is one the unboxed array
# supports. `rotate` is not, so the request is reported, at the annotation,
# and the array stays as inference types it.
class Foo
  def initialize(v) = @v = v
  def v = @v
end

class Box
  # @rbs @items: Array[Foo]

  def initialize
    @items = [Foo.new(1), Foo.new(2)]
  end

  def items = @items
  def rot = @items.rotate(1)
end

b = Box.new
p b.items.map(&:v)
p b.rot.map(&:v)
