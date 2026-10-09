# A freeze over a conditional with an attribute assignment's value for a branch:
# the frozen value would be a copy, and the field and the variable stay unfrozen.
class K
  attr_accessor :a
  def initialize = (@a = +"x")
end
o = K.new
s = +"s"
r = (s.empty? ? nil : (o.a = s)).freeze
p [o.a, s, r, o.a.frozen?, s.frozen?]
p 1
