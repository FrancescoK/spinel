# A block given to a method or a constructor that takes `...` reaches the
# method the `...` forwards to: a parent's initialize through super(...)
# or a bare super, whether it yields or takes &blk, and a helper the body
# calls with (...), yielding or taking &blk. Without a block each answers
# its no-block value.

class Base
  def initialize(a, &blk)
    @v = blk ? blk.call(a) : :none
  end
  attr_reader :v
end

class Kid < Base
  def initialize(...) = super(...)
end

class Yielder
  def initialize(a)
    @v = block_given? ? yield(a) : :none
  end
  attr_reader :v
end

class YKid < Yielder
  def initialize(...)
    super(...)
  end
end

class BareKid < Yielder
  def initialize(...)
    super
  end
end

def yhelper(a) = block_given? ? yield(a) : :none
def bhelper(a, &b) = b ? b.call(a) : :none

class Holder
  def initialize(...)
    @r = [yhelper(...), bhelper(...)]
  end
  attr_reader :r
end

def m(...) = n(...)
def n(a) = block_given? ? yield(a) : :none

p Kid.new(2) { |x| x * 10 }.v
p Kid.new(3).v
p YKid.new(4) { |x| x + 1 }.v
p YKid.new(5).v
p BareKid.new(6) { |x| -x }.v
p BareKid.new(7).v
p Holder.new(8) { |x| x * 2 }.r
p Holder.new(9).r
p m(10) { |x| x - 1 }
p m(11)
