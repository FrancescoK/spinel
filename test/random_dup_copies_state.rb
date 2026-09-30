# Random#dup and #clone answer a distinct generator that continues from
# the same state; clone keeps a frozen receiver frozen, dup does not.
r = Random.new(1)
d = r.dup
p [r.object_id == d.object_id, r.rand == d.rand]
c = r.clone
p [r.equal?(c), r.rand == c.rand, r == c]

x = Random.new(42)
y = x.dup
a = [x.rand(100), x.rand(100), x.rand(100)]
b = [y.rand(100), y.rand(100), y.rand(100)]
p a == b
p x.seed == y.seed

# a copy taken part-way through the stream, then advanced separately
z = Random.new(7)
3.times { z.rand }
w = z.dup
p z.rand(1000) == w.rand(1000)
p z.rand == w.rand
q = Random.new(5)
q2 = q.dup
q.rand
p q == q2
p q2.rand == Random.new(5).rand
p r.dup.class

# frozen
f = Random.new(3).freeze
p f.dup.frozen?, f.clone.frozen?

# nil, an instance variable and a method result
n = nil
p n.dup
class Gen
  def initialize = @r = Random.new(11)
  def copy = @r.dup
  def draw = @r.rand(1000)
  def r = @r
end
g = Gen.new
cp = g.copy
p [g.draw == cp.rand(1000), g.r.equal?(cp)]
# an instance variable that is nil, then holds a Random
class Holder
  def initialize = @r = nil
  def fill = @r = Random.new(4)
  def d = @r.dup
end
h = Holder.new
p h.d.nil?
h.fill
p h.d.nil?

def mk = Random.new(9)
p mk.dup.rand == mk.rand
