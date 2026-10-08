# A store through a box can widen its Hash only after another Hash widened:
# the stored value is read out of that one. Each link of such a chain widens
# in a later round, and every Hash it reaches, through a local or a method's
# parameter, must see its store.
# spinel: gc-minor
def put(h, x)
  b = [h, 1][ARGV.size]
  b[0] = x
end
h0 = {"x" => 0}
h1 = {1 => 1}
h2 = {2 => 2}
hp = {0 => 0}
b0 = [h0, 1][ARGV.size]
b0["x"] = "s"
v0 = h0["x"]
b1 = [h1, 1][ARGV.size]
b1[1] = v0
v1 = h1[1]
b2 = [h2, 1][ARGV.size]
b2[2] = v1
v2 = h2[2]
put(hp, v2)
p v0, v1, v2
p h0, h1, h2, hp

# The values carried through ivars.
class Chain
  def initialize
    @a = {"x" => 0}
    @b = {1 => 1}
    @c = {2 => 2}
    @d = {0 => 0}
  end

  def run
    [@a, 1][ARGV.size]["x"] = :sym
    @va = @a["x"]
    [@b, 1][ARGV.size][1] = @va
    @vb = @b[1]
    [@c, 1][ARGV.size][2] = @vb
    @vc = @c[2]
    keep(@d, @vc)
    [@va, @vb, @vc]
  end

  def keep(h, x)
    [h, 1][ARGV.size][0] = x
  end

  def show = [@a, @b, @c, @d]
end
ch = Chain.new
p ch.run, ch.show

# The values carried through Struct members.
Cell = Struct.new(:v)
def stash(h, x)
  [h, 1][ARGV.size][0] = x
end
g0 = {"x" => 0}
g1 = {1 => 1}
g2 = {2 => 2}
gp = {0 => 0}
c0 = Cell.new(0)
c1 = Cell.new(0)
c2 = Cell.new(0)
[g0, 1][ARGV.size]["x"] = 1.5
c0.v = g0["x"]
[g1, 1][ARGV.size][1] = c0.v
c1.v = g1[1]
[g2, 1][ARGV.size][2] = c1.v
c2.v = g2[2]
stash(gp, c2.v)
p c0, c1, c2
p g0, g1, g2, gp
