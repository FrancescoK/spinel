# spinel: share
# spinel: gc-minor
# A block sum reaches the seed's operator even without a direct call to it.
class SumVector
  attr_reader :x
  def initialize(x)
    @x = x
  end
  def +(other)
    SumVector.new(@x + other.x)
  end
end
vs = [SumVector.new(1), SumVector.new(2)]
r = vs.sum(SumVector.new(10)) { |v| v }
p r.x
p vs.take(0).sum(SumVector.new(10)) { |v| v }.x
