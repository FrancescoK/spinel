# spinel: share
# spinel: gc-minor
# A bare `new` in a class method builds the class it runs for, or a subclass
# of it, so the subclass's own initialize takes the argument: the String
# handed to `mk` is the one its instance variable holds.
class Base
  def initialize(s) = @s = s
  def bget = @s
  def self.mk(v) = new(v)
end
class Sub < Base
  def initialize(s)
    @t = s
  end
  def bget = @t
end
Base.new(nil)
Sub.new(nil)
Sub.new(1)
h = +"held"
o = Sub.mk(h)
o.bget << "!"
p o.class, h, o.bget, h.equal?(o.bget)
h << "+"
p o.bget
x = Sub.mk(+"fresh")
y = x.bget
y << "?"
p x.bget
b = Base.mk(+"base")
c = b.bget
c << "#"
p b.bget
