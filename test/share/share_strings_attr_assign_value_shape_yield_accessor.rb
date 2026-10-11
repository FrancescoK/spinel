# spinel: gc-minor
# The value of an attribute assignment as a block value is the very String the writer was handed,
# so a change through the value shows in the field and the right-hand side.
class Acc
  attr_accessor :a
  def initialize = (@a = +"x")
end
o = Acc.new
s = +"s"
def yl = yield
yl { (o.a = s) } << "4"
p [o.a, s]
