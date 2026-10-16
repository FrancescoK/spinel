# A String no one else changes in place stays the object it is as the value of
# an inlined yield, however many yields it passes through: nested blocks, a
# method of the program's own that answers a String it keeps, and a `next`
# of one on an arm of a conditional beside another value. Under
# --share-strings the value was demanded as a handle, which wraps a new String
# around the bytes of one the plan shares no handle for, and equal? said it was
# another object.
def m = yield
class K
  def initialize = (@s = +"ks")
  def s = @s
end
k = K.new
q = +"q"
c = ARGV.empty?
p m { q }.equal?(q)
p m { m { q } }.equal?(q)
p m { m { m { q } } }.equal?(q)
p m { k.s }.equal?(k.s)
p m { m { k.s } }.equal?(k.s)
p m { c ? (next k.s) : q }.equal?(k.s)
p m { c ? q : (next k.s) }.equal?(q)
p m { c ? (next q) : k.s }.equal?(q)
p m { m { c ? q : k.s } }.equal?(q)
p Fiber.new { m { q } }.resume.equal?(q)
p Thread.new { m { k.s } }.value.equal?(k.s)
