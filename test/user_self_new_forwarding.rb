# A user `def self.new` that wraps the constructor: the block it keeps has to
# reach the method, the splats it forwards carry no static count, and a bare
# `super` inside it means what `super(*a, **k, &blk)` means.
class Base
  def initialize(a, b = 2, x: 0, &blk)
    @a = a
    @b = b
    @x = x
    @blk = blk
  end
  attr_reader :a, :b, :x
  def run = @blk ? @blk.call : :noblk
end

class Sub < Base
  def self.new(*a, **k, &block)
    super
  end
end

o = Sub.new(1)
p [o.a, o.b, o.x, o.run]
o = Sub.new(1, 9, x: 7) { :hi }
p [o.a, o.b, o.x, o.run]

# the explicit spelling the bare one is defined to match
class Sub2 < Base
  def self.new(*a, **k, &block)
    super(*a, **k, &block)
  end
end
o = Sub2.new(1, 9, x: 7) { :hi2 }
p [o.a, o.b, o.x, o.run]

# reached through a Class VALUE, not a constant: the dispatch arm has to hand
# the block over too
def build(klass, &blk) = klass.new(1, 9, x: 7, &blk)
o = build(Sub) { :dyn }
p [o.class.name, o.a, o.x, o.run]

# a forwarder over a class whose initialize takes nothing: `super(*a, **k)`
# with an empty rest and an empty kwrest is ZERO arguments, not two
class Bare
  def self.new(*a, **k, &block)
    super(*a, **k, &nil)
  end
end
class BareSub < Bare; end
p BareSub.new.class.name
def make(k) = k.new
p make(BareSub).class.name
