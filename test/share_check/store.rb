# A multiple write stores each element of the Array literal it splits into
# its target, also through a splat (#8328): the store needs what the target
# does, though the literal, which no name sees, needs only bytes. Where the
# targets are instance variables the C boxes or wraps a copy, and a change
# through @iv does not reach s: the check marks the stores and reports it
# (the answer differs from CRuby's under --share-strings today).
s = +"s"; t = +"t"; u = +"u"
a, b = *[s, t]
a << "?"
x, y = s, *[t, u]
y << "&"
p s, t
class C
  def initialize; @iv = nil; @jv = nil; end
  def set(s, t); @iv, @jv = s, t; nil; end
  def bang = @iv << "!"
  attr_reader :iv, :jv
end
c = C.new
c.set(s, t)
c.bang
p s, c.iv.equal?(s)
