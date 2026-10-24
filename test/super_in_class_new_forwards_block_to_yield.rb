class YBase
  def self.new(x) = super
end
class YKid < YBase
  def initialize(x)
    @x = x
    @r = yield(x)
  end
  attr_reader :x, :r
end
y = YKid.new(4) { |v| v + 1 }
p [y.x, y.r]

class YBase2
  def self.new(x) = super(x)
end
class YKid2 < YBase2
  def initialize(x)
    @x = x
    @r = yield(x)
  end
  attr_reader :x, :r
end
y2 = YKid2.new(4) { |v| v + 1 }
p [y2.x, y2.r]

class YBase3
  def self.new = super
end
class YKid3 < YBase3
  def initialize
    @r = yield 7
  end
  attr_reader :r
end
p YKid3.new { |v| v + 1 }.r

class YBase4
  def self.new(x) = super
end
class YKid4 < YBase4
  def initialize(x)
    @x = x
    yield @x
  end
  attr_reader :x
end
begin
  YKid4.new(4)
rescue LocalJumpError => e
  puts e.message
end

module YTracking
  def new(x)
    super
  end
end
class YTracked
  extend YTracking
  def initialize(x)
    @r = yield(x)
  end
  attr_reader :r
end
p YTracked.new(5) { |v| v * 2 }.r

class YGrand < YKid
end
yg = YGrand.new(9) { |v| v - 1 }
p [yg.x, yg.r]
