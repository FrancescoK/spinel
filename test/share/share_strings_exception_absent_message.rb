# spinel: share
# spinel: gc-minor
# An exception built without a message answers a new class-name String on
# every #message, as CRuby does, while a message it was given stays one
# object, even when it spells the class name.
class A < StandardError
  def to_s = "override"
end
class B < StandardError; end
class C < StandardError
  def initialize
    @x = 1
  end
end
class D < StandardError
  def initialize(m = nil)
    @x = 1
    super(m)
  end
end

# a nil handed to super is no message given
class F < StandardError
  def initialize(m) = super(m)
end
class G < StandardError
  def initialize(m = nil)
    super
  end
end
class H < StandardError
  def initialize(m) = super(m)
end
p H.new(nil).message
p F.new(nil).message, F.new("f").message, G.new.message, G.new(nil).message, G.new("g").message

e = B.new
a = e.message
b = e.message
a << "!"
b << "?"
p a, b
p e.message, B.new.message.equal?(B.new.message)

c = C.new
x = c.message
y = c.message
x << "1"
y << "2"
p x, y, c.message, x.equal?(y)

d = D.new
p d.message.equal?(d.message), d.message
d = D.new("D")
p d.message

h = B.new("B")
p h.message.equal?(h.message)
s = B.new("x")
p s.message.equal?(s.message)

begin
  raise B
rescue B => r
  m = r.message
  n = r.message
  m << "!"
  p m, n, m.equal?(n)
end

# the absent message is not a message given
p B.new == B.new, B.new == B.new("B"), B.new == B.new(""), B.new("") == B.new(nil)
p C.new == C.new, D.new == D.new, D.new == D.new("D")
z = B.new
p z == z.dup, z.dup.message, z.exception.message, z.exception("m").message
p B.new.inspect, B.new("").inspect, B.new("B").inspect

# the class name an absent message answers is read when it is asked, so a
# class named after the exception was built answers its new name
anon = Class.new(StandardError)
ae = anon.new
p ae.message.start_with?("#<Class:0x")
Late = anon
am = ae.message
am << "!"
p am, ae.message, anon.new.message, ae.inspect
class Plain < StandardError; end
un = ARGV.size == 0 ? anon.new : Plain.new
us = un.to_s
us << "?"
p us, un.to_s
class AbsU < StandardError; end
class AbsV < StandardError
  def to_s = "v"
end
au = ARGV.size == 0 ? AbsU.new : AbsV.new
p au.to_s.equal?(au.to_s), au.message.equal?(au.message)

# an unnamed class raised as a value, and an exception object raised with a
# nil message, raise an exception that was given no message
vk = Class.new(StandardError)
r1 = begin; raise vk; rescue => ex; ex; end
r2 = begin; raise vk, nil; rescue => ex; ex; end
p r1.message.equal?(r1.message), r2.message.equal?(r2.message)
Named2 = vk
p r1.message, r2.message
class RaiseFoo < StandardError; end
rf = RaiseFoo.new("x")
begin; raise rf, nil; rescue => ex; p ex.message, ex.equal?(rf), rf.message; end
ru = [rf, 1][0]
begin; raise ru, nil; rescue => ex; p ex.message; end
rn = nil
begin; raise rf, rn; rescue => ex; p ex.message; end
begin; raise rf; rescue => ex; p ex.message; end
