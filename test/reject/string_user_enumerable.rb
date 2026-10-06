# A user Enumerable's first is what its each yields, @x, which is s. The
# answer was a copy and s stayed "abc": refused, not compiled wrong.
class Bag
  include Enumerable
  def initialize(x) = (@x = x)
  def each = yield(@x)
end
s = +"abc"
Bag.new(s).first << "!"
p s
