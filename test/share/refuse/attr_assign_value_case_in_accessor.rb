# A case subject that is an attribute assignment, bound by a pattern and changed:
# the bound value would be a copy.
class K
  attr_accessor :a
  def initialize = (@a = +"x")
end
o = K.new
s = +"s"
case o.a = s
in String => x
  x << "1"
end
p [o.a, s, x]
p 1
