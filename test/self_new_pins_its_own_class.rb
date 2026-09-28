# A receiverless `new` inside `def self.m` is `self.new`: it constructs that
# class (or a descendant that inherits the class method) and no other. Counted
# as an unpinnable dynamic `new`, its ARITY alone put every unrelated class
# with that many parameters out of reach of the handle-argument evidence, so a
# mutable String such a class retained was copied at the call and the caller's
# later writes never reached it -- silently, with the program still running.
#
# Maker.build's `new(1, 2, 3)` takes three arguments, as Ctx#initialize does.
class Holder
  attr_reader :buf
  def initialize(buf)
    @buf = buf
  end
end

class Ctx
  def initialize(buf, a, b)
    @buf = buf
    @a = a
    @b = b
  end
  def peek(i)
    @buf.getbyte(i)
  end
end

class Maker
  def initialize(x, y, z)
    @x = x + y + z
  end
  def self.build
    new(1, 2, 3)
  end
end

class Writer
  def initialize(h)
    @h = h
  end
  def poke(i, v)
    b = @h.buf
    b.setbyte(i, v)
  end
end

Maker.build
h = Holder.new(+"AAAA")
w = Writer.new(h)
ctx = Ctx.new(h.buf, 1, 2)
w.poke(0, 66)
p ctx.peek(0)

# The owner itself keeps the protection: `Plant.build` can construct Plant, so
# Plant#initialize's own String parameter is still reached by that shape.
class Plant
  def initialize(s, a, b)
    @s = s
    @a = a
    @b = b
  end
  def self.build(s)
    new(s, 1, 2)
  end
  def read
    @s
  end
end
p Plant.build("pp").read

# A descendant inherits the class method, so it is reached too.
class Sprout < Plant
end
p Sprout.build("ss").read
