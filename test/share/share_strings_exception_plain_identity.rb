# spinel: share
# spinel: gc-minor
# Without any override of the exception text, a message compares by identity
# with a routed read, a plain copy, an Array element and a frozen literal.
class B < StandardError; end
class D < StandardError
  def initialize(m)
    super("frz")
  end
end
n = ARGV.size
k = B.new(+"k#{n}")
x = k.message
p x.equal?(k.message), k.message.equal?(x), k.message.object_id == x.object_id
list = [k.message, k.message]
p list[0].equal?(list[1]), list[0].equal?(x), k.message.equal?(list[0])
p [k.message].first.equal?(k.message), list[1].object_id == k.message.object_id
lit = B.new("lit")
y = lit.message
p lit.message.equal?(y), y.equal?(lit.message), y.frozen?
d = D.new(1)
z = d.message
p d.message.equal?(z), z.equal?(d.message), d.message.object_id == z.object_id
w = B.new(+"w#{n}")
v = w.message
v << "!"
u = w.message
p u.equal?(v), w.message.equal?(v), v.equal?(w.message), w.message.object_id == v.object_id
pair = [w.message, w.message]
p pair[0].equal?(pair[1]), pair[0].equal?(v)
p v, w.message, u
begin
  raise B, "r#{n}"
rescue B => e
  p e.message.equal?(e.message)
end
