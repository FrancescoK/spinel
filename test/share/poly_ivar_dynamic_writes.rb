# A send or an instance_variable_set whose name is not a literal can write
# any instance variable, so after one every boxed ivar receiver may be a
# String: the append through the reader changes the String every name
# holds.
class D1
  attr_accessor :d1
  def initialize = (@d1 = {})
end
od1 = D1.new
od1.d1["k"] = 1
s1 = +"send"
od1.public_send("d" + "1=", s1)
od1.d1 << "+"

class D2
  attr_reader :d2
  def initialize = (@d2 = {})
end
od2 = D2.new
od2.d2["k"] = 1
s2 = +"ivset"
od2.instance_variable_set("@" + "d2", s2)
od2.d2 << "+"
p s1, s2
