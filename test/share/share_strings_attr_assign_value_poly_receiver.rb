# The value of an attribute assignment kept as a String, through a receiver of
# either of two classes: the assignment is dispatched on the receiver's class,
# and its value is the right-hand side's String whichever writer ran.
class K
  attr_accessor :a
  def initialize = (@a = +"x")
end
class M
  attr_accessor :a
  def initialize = (@a = +"m")
end
[K.new, M.new].each do |o|
  y = +"y"
  r = (o.a = y)
  r << "!"
  p o.a, y, r
end
