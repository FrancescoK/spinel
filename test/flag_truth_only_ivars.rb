# An ivar every read of which asks only its truthiness stores the truthiness
# of what is written into it, as a boolean: `@visible ||= @map.clear` holds
# false or the Array by the text, and is read only by conditions and by an
# `&&` stored into another such ivar. The Array's side effect still runs
# once; the answers do not change. An ivar some read uses as a value -- a
# reader, interpolation, a method's value a caller reads, a comparison --
# keeps what it was given.

class Screen
  def initialize
    @map = [1, 2]
    @visible = false
    @enabled = true
    @active = false
    @shown = nil
    @kept = false
  end
  def inspect = "#<Screen>"
  def load
    @visible ||= @map.clear
    @shown ||= @map
    @kept ||= @map
    @active = @enabled
  end
  def flags
    @active = @enabled && @visible
    nil
  end
  def draw(n)
    hits = 0
    n.times { |i| hits += 1 if @active && i.odd? }
    hits += 10 unless @visible
    hits += 100 while !@shown && hits < 300
    hits
  end
  def off
    @visible = false
    @active = false
  end
  def kept = @kept
  def shown_size = (@shown ? @shown.size : -1)
end

s = Screen.new
p s.draw(4)
s.load
s.flags
p s.draw(4), s.kept, s.shown_size
s.off
s.flags
p s.draw(4)
s.load
p s.draw(6), s

# Each of these keeps the value it is given: a method value a caller reads,
# through `super` and `send`; a generated inspect; interpolation and nil?;
# an `&&` whose value is a method's.
class A
  def inspect = "A"
  def initialize = @f = false
  def set(x) = @f = x
  def on? = @f ? 1 : 0
end
a = A.new
v = a.set([1])
p v, a.on?

class B
  def inspect = "B"
  def initialize = @f = false
  def set(x) = @f = x
  def on? = @f ? 1 : 0
end
class B2 < B
  def set(x)
    r = super
    r
  end
end
b = B2.new
p b.set([2]), b.on?

class C
  def initialize = @f = false
  def set(x) = (@f = x; nil)
  def on? = @f ? 1 : 0
end
c = C.new
c.set([3])
p c.inspect.include?("@f=[3]"), c.on?

class D
  def inspect = "D"
  def initialize = @f = false
  def set(x) = @f ||= x
  def on? = @f ? 1 : 0
end
d = D.new
p d.send(:set, [4]), d.on?

class E
  def inspect = "E"
  def initialize = @f = nil
  def set(x) = (@f = x; nil)
  def q = "#{@f}"
  def r = @f.nil?
end
e = E.new
e.set(false)
p e.q, e.r

class F
  def inspect = "F"
  def initialize = @f = false
  def set(x)
    @f = x
    nil
  end
  def on = @f && 7
end
f = F.new
f.set([5])
p f.on

# An ivar nothing reads keeps the object written into it: holding it may be
# its purpose (a keep-alive). One no constructor writes starts nil, so its
# slot would stay boxed: it keeps its value too. A `nil` written into an
# ivar that stores its truthiness stores false.
class G
  def initialize = (@hold = nil; @on = false)
  def inspect = "G"
  def take(x)
    @hold = x
    @on ||= x
    nil
  end
  def on? = @on ? 1 : 0
end
g = G.new
g.take([6])
p g.on?

class H
  def inspect = "H"
  def take(x) = (@f = x; nil)
  def on? = @f ? 1 : 0
end
h = H.new
p h.on?
h.take([7])
p h.on?

class I
  def initialize = (@f = nil; @n = 0)
  def inspect = "I"
  def take(x) = (@f = x; nil)
  def drop = (@f = nil; nil)
  def on? = @f ? 1 : 0
end
i = I.new
p i.on?
i.take([8])
p i.on?
i.drop
p i.on?
