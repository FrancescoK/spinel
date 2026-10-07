# A local handed to a call is copied into the call's argument temp. When
# nothing in the statement around the call can rebind the local, the
# local's own root holds the value and the copy takes none; when something
# can -- a later argument, another operand, an op-write, a multiple
# assignment, a block's parameter, a numbered parameter -- the copy keeps
# its root. Run under SPINEL_GC_STRESS=1 each value must survive the
# allocations between its copy and the call.
class Vec
  attr_reader :x, :y
  def initialize(x, y); @x = x; @y = y; end
  def to_s = "(#{@x},#{@y})"
end

class Probe
  def initialize; @log = []; end
  def hit(a, b) = (@log << "#{a}/#{b}"; @log.size)
  def pair(a, b) = [a.to_s, b.to_s]
  def log = @log
end

pr = Probe.new
s = 0
i = 0
while i < 50
  ray = Vec.new(i, i + 1)
  isect = Vec.new(-i, 0)
  # nothing in these statements rebinds ray or isect
  s += pr.hit(ray, isect)
  s += pr.hit(ray, Vec.new(i, i))
  # a later argument rebinds the local: the copy keeps the first value
  p pr.pair(ray, (ray = Vec.new(100 + i, 0); [ray.x].map { |v| v * 2 })) if i % 10 == 0
  # another operand rebinds it
  t = pr.hit(isect, Vec.new(1, 1)) + (isect = Vec.new(7, 7); 0)
  s += t
  i += 1
end
p s, pr.log.size, pr.log.first(3), pr.log.last(2)

# an op-write and a multiple assignment in the statement
str = +"a"
p pr.pair(str, str += "b" * 3)
u, w = Vec.new(1, 2), Vec.new(3, 4)
p pr.pair(u, (u, w = w, u; Vec.new(9, 9)))
# a block parameter and a numbered parameter beside the call
v = Vec.new(5, 6)
p [Vec.new(8, 8)].map { |v2| pr.pair(v, v2) }
p [1, 2].map { pr.pair(v, _1 * 3) }
# a local the method writes elsewhere, read in a loop
acc = []
q = Vec.new(0, 0)
3.times { |k| q = Vec.new(k, k); acc << pr.pair(q, Vec.new(k * 2, 0)) }
p acc
