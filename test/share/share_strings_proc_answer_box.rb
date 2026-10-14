# Under --share-strings a proc's answer is the box the proc hands back: a
# String the proc answers, kept in a container and changed through the
# element, is the String the proc's block holds, and a new String the
# proc answers is one String however many names keep it.
def f_str(&blk)
  pr = proc { blk.call }
  pr.call
end
s = +"shared"
r = [f_str { s }, 1]
r[0] << "!"
p s, r
class Runner
  def run2(x, &blk)
    pr = lambda { |y| blk.call(y) }
    [pr.call(x), pr.(x), pr[x]]
  end
end
z = Runner.new.run2(s) { |v| v }
z[0] << "z"
p s, z, z[0].equal?(s), z[0].equal?(z[1])
class Box
  def initialize(v) = @v = v
  def map_v(&blk) = blk.call(@v)
end
b = Box.new(3)
def relay(o, m, &blk) = o.send(m, &blk)
r1 = relay(b, :map_v) { |x| x + 1 }
r3 = relay(b, :map_v) { |x| "n#{x}" }
r4 = [r3, r3]
r4[0] << "#"
p r1, r3, r4, r4[0].equal?(r4[1])
