# spinel: share
# spinel: gc-minor
# Exception text keeps the selected result and its identity.
class A < StandardError
  def to_s = "a"
end
class B < StandardError; end
n = ARGV.size
e = B.new("v#{n}")
p e.message.equal?(e.message)
arr = [e.message, e.message]
p arr[0].equal?(arr[1])
p e.message.object_id == e.message.object_id
m = e.message
p m.equal?(e.message), m.frozen?
f = B.new("lit")
p f.message.equal?(f.message)
g = StandardError.new("w#{n}")
p g.message.equal?(g.message), [g.message].first.equal?(g.message)
begin
  raise B, "r#{n}"
rescue B => ex
  p ex.message.equal?(ex.message)
end

h = B.new("B")
p h.message.equal?(h.message)
empty = B.new("")
p empty.message.equal?(empty.message)

# A routed read beside an identity read: the identity of the message holds
# whichever way it is asked, and whichever way the other operand is held (a
# plain copy, a container's element, a handle).
class Q < StandardError
  def to_s = "q"
end
class D < StandardError
  def initialize(m)
    super("frz")
  end
end
b = B.new(+"m#{n}")
b.message << "!"
p b.message.equal?(b.message), b.message.object_id == b.message.object_id
c = B.new("lit2")
c.message
p c.message.equal?(c.message), c.message.object_id == c.message.object_id
d = D.new(1)
d.message
p d.message.equal?(d.message), d.message.object_id == d.message.object_id

k = B.new(+"k#{n}")
x = k.message
p x.equal?(k.message), k.message.equal?(x), k.message.object_id == x.object_id
list = [k.message, k.message]
p list[0].equal?(list[1]), list[0].equal?(x), k.message.equal?(list[0])
p [k.message].first.equal?(k.message), list[1].object_id == k.message.object_id
lit = B.new("lit3")
y = lit.message
p lit.message.equal?(y), y.equal?(lit.message), y.frozen?
w = B.new(+"w#{n}")
z = w.message
z << "!"
v = w.message
p v.equal?(z), w.message.equal?(z), z.equal?(w.message), w.message.object_id == z.object_id
pair = [w.message, w.message]
p pair[0].equal?(pair[1]), pair[0].equal?(z)
p z, w.message, v
