# `def initialize(...)` is reached through `Klass.new(...)`, so its forwarded
# parameters come from the `new` call sites, or from the `super` it forwards to.

class Base
  def initialize(a, b) = (@a = a; @b = b)
  attr_reader :a, :b
end

class Sub < Base
  def initialize(...) = super(...)
end
s = Sub.new(1, 2)
p [s.a, s.b]

class KwBase
  def initialize(a, b, k: 0, &blk)
    @a = a; @b = b; @k = k; @r = blk ? blk.call : :none
  end
  attr_reader :a, :b, :k, :r
end

class KwSub < KwBase
  def initialize(...) = super(...)
end
s = KwSub.new(1, 2, k: 3) { :blk }
p [s.a, s.b, s.k, s.r]

class ValueSub < Base
  def initialize(...) = super(...)
end
k = ValueSub
s = k.new(3, 4)
p [s.a, s.b]

class ZsuperSub < Base
  def initialize(...)
    super
  end
end
s = ZsuperSub.new(5, 6)
p [s.a, s.b]

class LeadSub < Base
  def initialize(x, ...)
    @x = x
    super(...)
  end
  attr_reader :x
end
s = LeadSub.new(0, 7, 8)
p [s.x, s.a, s.b]

class Setup
  def initialize(...) = setup(...)
  def setup(a, b) = (@a = a; @b = b)
  attr_reader :a, :b
end
s = Setup.new(9, 10)
p [s.a, s.b]
