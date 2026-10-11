# spinel: gc-minor
# The value of an attribute assignment as the block value of a user-defined `each`, whose result is changed is the very String the writer was handed,
# so a change through the value shows in the field and the right-hand side.
class Acc
  attr_accessor :a
  def initialize = (@a = +"x")
end
o = Acc.new
s = +"s"
class C
  def each = yield
end
r = C.new.each { o.a = s }
r << "1"
p [o.a, s, r]
