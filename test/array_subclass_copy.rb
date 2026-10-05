# Every dup and clone of an Array subclass instance (#7449) is a copy of the
# class the instance carries, running that class's initialize_copy: one held
# in a boxed value was copied by the runtime as a plain Array (its class and
# ivars lost), one in a slot typed as a base class ran the base's hook, and a
# clone of a frozen one froze the copy before the hook, so the hook's ivar
# write raised FrozenError.
class Base < Array
  attr_accessor :tag
  def initialize_copy(o)
    super
    @tag = "copied #{o.tag}"
  end
end
class Leaf < Base
  def initialize_copy(o)
    super
    @tag = "leaf #{@tag}"
  end
end
def dupit(x) = x.dup
b = Base.new; b.tag = "b"; b << 1
l = Leaf.new; l.tag = "l"; l << 2
p dupit(b).tag, dupit(l).tag, dupit(l).class, dupit(l)
class Holder
  def initialize(x) = @x = x
  def copy = @x.dup
end
[Holder.new(b), Holder.new(l)].each { |h| c = h.copy; p [c.class, c.tag, c] }
fz = Leaf.new; fz.tag = "f"; fz << 3; fz.freeze
c2 = fz.clone; p c2.frozen?, c2.tag, c2
c3 = fz.dup; p c3.frozen?; c3 << 4; p c3
c4 = fz.clone(freeze: false); p c4.frozen?
