# Each flow the share walk follows records the holder that takes the value.
# A new String joins no class, so the holder is the only place that tells
# whether a box that keeps it has to hold the shared handle.
class Slot
  attr_accessor :v
  def initialize
    @v = +"init"
  end

  def put(x)
    @v = x
  end

  def grow(s)
    @v << s
  end
end

o = Slot.new
o.put(+"arg")              # a new String into a parameter whose class shares
o.v = +"member"            # ... an attribute writer's ivar
o.grow("!")
p o.v

shared = +"w"
alias_of = shared          # a name for the same String: a holder's read
alias_of << "?"
p shared

list = []
list << +"elem"            # a new String into the elements of a shared container
list[0] << "+"
mirror = list
mirror[0] << "*"
p list

x, y = +"m1", +"m2"        # a multiple write's targets
y << "!"
q = y
q << "?"
p x, y

mapped = [1, 2].map { |i| +"b#{i}" }   # a block's value into the new container
mapped[0] << "z"
again = mapped
again[1] << "z"
p mapped

def twice
  yield +"yielded"
end
twice { |s| s << "!"; p s }

class Base
  def initialize(v)
    @v = v
  end

  def bang
    @v << "!"
  end

  attr_reader :v
end

class Sub < Base
  def initialize
    super(+"sup")   # a new String into the parameter a super binds
  end
end
sub = Sub.new
sub.bang
p sub.v

th = Thread.new(+"thr") { |x| y = x; y << "!"; y }   # ... and a thread block's
p th.value
