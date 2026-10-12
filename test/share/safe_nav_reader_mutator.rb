# A String mutator that answers its receiver, called with `&.` (or plainly)
# on an attr_reader whose ivar holds a String or nil: the reader's value is
# boxed, and the mutator writes through the shared handle behind the box.
# Its value is that String (equal? to the reader's), read as a handle where
# a store or an `equal?` wants one; nil for a nil reader.
class C
  attr_reader :s
  def initialize(s) = @s = s
end
c = C.new(+"ab")
n = C.new(nil)
r = c.s&.concat(">"); p r, r.equal?(c.s)
r = c.s&.prepend("["); p r, c.s
r = c.s&.<<("<"); p r, r.equal?(c.s)
r = c.s&.insert(1, "I"); p r, r.equal?(c.s)
c.s&.concat("1")
c.s&.prepend("2")
c.s&.<<("3")
c.s&.insert(1, "4")
p c.s
p n.s&.concat("x"), n.s&.prepend("x"), n.s&.<<("x"), n.s&.insert(0, "x")
n.s&.concat("x")
n.s&.prepend("x")
p n.s
r = c.s.concat("5"); p r, r.equal?(c.s)
r = c.s.prepend("6"); p r
r = c.s << "7"; p r.equal?(c.s)
r = c.s.insert(0, "8"); p r, r.equal?(c.s)
p [c.s&.concat("!"), c.s]
