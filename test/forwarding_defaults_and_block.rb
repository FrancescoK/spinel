# `...` forwards only what the caller passed: the target applies its own
# defaults, and the block rides along.

class Base
  def go(a, k: 0) = [a, k]
  def m(a, b = 7) = [a, b]
  def blk(a, k: 1, &b) = [a, k, b ? b.call : :none]
  def bare(a, b = 3) = [a, b]
end

class Sub < Base
  def go(...) = super(...)
  def m(...) = super(...)
  def blk(...) = super(...)
  def bare(...)
    super
  end
end

s = Sub.new
p s.go(1)
p s.go(1, k: 5)
p s.m(1)
p s.m(1, 2)
p s.blk(1)
p s.blk(1, k: 2) { :b }
p s.bare(1)
p s.bare(1, 2)

class Named
  def go(...) = setup(...)
  def setup(a, b, k: 0, &blk) = [a, b, k, blk ? blk.call : :none]
end

p Named.new.go(1, 2, k: 3) { :blk }
p Named.new.go(1, 2) { :blk }
p Named.new.go(1, 2)

def target(a, b = 3, k: 4) = [a, b, k, block_given? ? yield : :none]
def fwd(...) = target(...)

p fwd(1)
p fwd(1, 2) { :x }
p fwd(1, k: 9)

class Point
  def initialize(a, b = 7, k: 1) = (@v = [a, b, k])
  attr_reader :v
end

class Point3 < Point
  def initialize(...) = super(...)
end

klass = Point3
p Point3.new(1).v
p klass.new(1, 2, k: 3).v

class Maker
  def initialize(a, k: 5, &blk) = (@v = [a, k, blk ? blk.call : :none])
  attr_reader :v
  def self.make(...) = new(...)
end

p Maker.make(1).v
p Maker.make(1, k: 2) { :b }.v

class KwBase
  def go(k: 0) = [k]
end

class KwSub < KwBase
  def go(**o) = super(**o)
end

p KwBase.new.go
p KwSub.new.go(k: 3)

# classes of one name in two namespaces: the super target is found through
# A's own chain, not the other Base
module NsA
  class Grand
    def run(x = 0) = [:grand, x]
  end
  class Base < Grand
  end
end
module NsB
  class Base
    def run(k: 0) = [:b, k]
  end
end
module NsA
  class Child < Base
    def run(...) = super(...)
  end
end
p NsA::Child.new.run(1)
p NsA::Child.new.run
p NsB::Base.new.run(k: 2)
