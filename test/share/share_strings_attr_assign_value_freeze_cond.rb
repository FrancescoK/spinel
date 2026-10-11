# A freeze over a conditional with an attribute assignment's value for a branch
# freezes that String: the field, the variable and the answer are one object.
class K
  attr_accessor :a
  def initialize = (@a = +"x")
end
o = K.new
s = +"s"
r = (s.empty? ? nil : (o.a = s)).freeze
p [o.a, s, r, o.a.frozen?, s.frozen?, r.equal?(s)]
p 1
