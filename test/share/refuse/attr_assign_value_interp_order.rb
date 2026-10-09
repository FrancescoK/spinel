# An interpolation whose first part appends to the String an attribute
# assignment stores, and whose second part reads the assignment: the read would
# be a copy taken before the append.
class K
  attr_accessor :a
  def initialize = (@a = +"x")
end
o = K.new
s = +"s"
r = "#{(o.a = s) << "1"}#{o.a = s}"
p [o.a, s, r]
p 1
