# An inline ivar annotation naming an array of one class, and an --rbs
# signature for the same ivar. Agreement is decided on the types they name, so
# Array[Foo] agrees with Array[Foo] and disagrees with Array[Bar].
class Foo; end
class Bar; end
class Box
  # @rbs @items: Array[Foo]

  def initialize
    @items = [Foo.new]
  end

  def items = @items
end

p Box.new.items.size
