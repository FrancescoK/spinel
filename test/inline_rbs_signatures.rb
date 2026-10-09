# A program annotated with ruby/rbs inline comments (docs/inline-rbs.md).
# CRuby reads them as comments; Spinel pins the
# slots they describe, as the same signatures in a .rbs file would. Either
# way the program prints the same thing.
class Bag
  EMPTY = [0]

  # @rbs @items: Array[Integer]?

  #: (Array[Integer]?) -> void
  def initialize(items)
    @items = items
  end

  # Without the signature, `@items || EMPTY` is a value of either kind and
  # every `.size` on it is dispatched at run time.
  #: () -> Array[Integer]
  def items
    @items || EMPTY
  end
end

class Point
  attr_reader :x #: Integer
  attr_reader :y #: Integer

  #: (Integer, Integer) -> void
  def initialize(x, y)
    @x = x
    @y = y
  end

  # @rbs other: Point
  # @rbs return: Integer
  def dist2(other)
    dx = x - other.x
    dy = y - other.y
    dx * dx + dy * dy
  end

  #: (Integer dx,
  #   Integer dy) -> Point
  def moved(dx, dy) = Point.new(x + dx, y + dy)
end

class Label
  attr_accessor :text #: String?

  def initialize
    @text = nil
  end

  def show = text || "(none)"
end

bags = [Bag.new([1, 2, 3]), Bag.new(nil), Bag.new([4, 5])]
t = 0
i = 0
while i < 30
  t += bags[i % 3].items.size
  i += 1
end
p t
o = Point.new(1, 2)
p o.dist2(Point.new(4, 6))
q = o.moved(2, 3)
p [q.x, q.y]
l = Label.new
puts l.show
l.text = "hi"
puts l.show
