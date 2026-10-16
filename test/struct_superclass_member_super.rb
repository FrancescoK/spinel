# super from a method that overrides a member of a Struct.new or Data.define
# superclass reaches the member's reader or writer.

class Point < Struct.new(:x, :y)
  def x = [super, 1]
  def y=(v)
    super(v * 2)
  end
end
pt = Point.new(3, 4)
p pt.x
pt.y = 5
p pt.y, pt.to_a
class Pair < Struct.new(:a, :b, keyword_init: true)
  def a = super.to_s * 2
end
p Pair.new(a: 7, b: 1).a
class Pt < Data.define(:x)
  def x = super + 1
end
p Pt.new(x: 1).x, Pt.new(x: 1)

# A Data member has a reader only: super from a writer of that name finds
# none, and the member keeps its value.
class Frozen < Data.define(:x)
  def x=(v)
    super
  rescue NoMethodError => e
    puts e.message
  end
end
f = Frozen.new(x: 1)
f.x = 5
p f.x
