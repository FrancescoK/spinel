class Bag
  include Enumerable
  def initialize(x) = (@x = x)
  def each = yield(@x)
end
s = +"abc"
Bag.new(s).first << "!"
p s
