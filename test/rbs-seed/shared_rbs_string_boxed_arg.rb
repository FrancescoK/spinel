# Under --share-strings (#6765), a String that arrives boxed (a poly
# Array's or Hash's element, a poly ivar, a poly answer, a find over a
# poly Array, an untyped answer) at a parameter, keyword, module function
# or instance variable an --rbs signature types String or String? is the
# String the caller holds: the slot takes the handle the box holds. The
# ivar store wrapped a copy of the box's bytes, so the callee's change and
# the caller's later change landed on two Strings, and equal? was false;
# an ivar's `||=` did the same. A boxed nil into a String? ivar is nil
# (converted as a String, it raised TypeError). A multiple assignment into
# such ivars takes the handle the same way.
# spinel: rbs-seed-check
class ShrbsbTake
  def take(a)
    a << "!"
    a
  end

  def kw(a:)
    a << "k"
    a
  end

  def optkw(a: "d")
    a << "o"
    a
  end
end

module ShrbsbMod
  def self.f(a)
    a << "m"
    a
  end
end

class ShrbsbHold
  attr_reader :y

  def initialize(v, w)
    @x = v
    @y = w
  end

  def x = @x

  def bump
    @x << "!"
    @y << "?" if @y
  end

  def set(v)
    @x = v
    @z ||= v
  end

  def z = @z

  def both(v, w)
    @x, @z = v, w
  end
end

class ShrbsbSrc
  def initialize(s) = @v = s
  def v = @v
end

def shrbsb_pick(i, s) = i == 0 ? s : 1

def shrbsb_show(s, r)
  p [s, r, r.equal?(s)]
end

s = +"a"
shrbsb_show(s, ShrbsbTake.new.take([s, 1][0]))
shrbsb_show(s, ShrbsbTake.new.kw(a: {"k" => s, "n" => 1}["k"]))
shrbsb_show(s, ShrbsbTake.new.optkw(a: shrbsb_pick(0, s)))
shrbsb_show(s, ShrbsbMod.f([s, 1].find { |x| x.is_a?(String) }))

h = ShrbsbHold.new([s, 1][0], {"k" => s, "n" => 1}["k"])
h.bump
s << "2"
p [s, h.x, h.y, h.x.equal?(s), h.y.equal?(s)]

t = +"t"
h = ShrbsbHold.new(shrbsb_pick(0, t), ShrbsbSrc.new(t).v)
h.bump
t << "3"
p [t, h.x, h.y, h.x.equal?(t), h.y.equal?(t)]

u = +"u"
h.set([u, 1].find { |x| x.is_a?(String) })
h.bump
u << "4"
p [u, h.x, h.z, h.x.equal?(u), h.z.equal?(u)]

h = ShrbsbHold.new([u, 1][0], [nil, 1][0])
h.bump
p [h.x, h.y]

# a multiple assignment takes the box's handle as a single write does
m = +"m"
h = ShrbsbHold.new(+"x", +"y")
h.both([m, 1][0], [nil, 1][0])
h.bump
m << "6"
p [m, h.x, h.z, h.x.equal?(m)]
n = +"n"
h.both([+"p", 1][0], [n, 1][0])
n << "7"
p [h.x, h.z, h.z.equal?(n)]
