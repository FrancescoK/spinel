# A bare `new` in a class method runs initialize's defaults on the new
# object when the class is a value type too: the default that reads the
# instance (`twice(x)`) was handed the class method's self, and the C did
# not compile.
class V
  attr_reader :x, :y
  def initialize(x, y = twice(x)) = (@x = x; @y = y)
  def twice(n) = n * 2
  def self.at(n) = new(n)
end
v = V.at(3)
p v.x + v.y
