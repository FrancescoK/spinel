# Under --share-strings (#6765), `@s += x` on an ivar the rule holds as the shared handle (it is
# appended to elsewhere, or a chain's bang is run on it) builds a new String from the handle's bytes:
# with another handle ivar as the operand (each read is rooted), as the value of a method, with the
# String the ivar held kept apart from the new one, and with a non-String operand raising TypeError.
class Rhs
  def initialize = (@s = +"a"; @t = +"t")
  def app1 = (@s << "b")
  def m
    @s += @t
    [@s, @t]
  end
end
a1 = Rhs.new
a1.app1
p a1.m

class Val
  def initialize(s) = (@s = s)
  def app = (@s << "b")
  def plus(x) = (@s += x)
end
a2 = Val.new(+"a")
a2.app
p a2.plus("c")

class Alias
  def initialize(s) = (@s = s)
  def app = (@s << "b")
  def plus(x)
    @s += x
    @s
  end
end
o = +"a"
a3 = Alias.new(o)
a3.app
r = a3.plus("c")
a3.app
p [r, o]

class Raises
  def initialize = (@s = +"a")
  def app = (@s << "b")
  def m(x)
    @s += x
  rescue TypeError => e
    e.message
  end
end
a4 = Raises.new
a4.app
p a4.m(nil)
p a4.m("z")
