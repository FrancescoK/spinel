# A method whose last expression writes an ivar that may hold a nil Integer
# or Float answers the value written, nil included. The ivar keeps its nil
# in a nil byte beside the field; the method's value read the field alone,
# and answered 0 (or 0.0) where CRuby answers nil.
class Bus
  def initialize
    @data = 0
    @gain = 0.5
  end

  def load(v) = @data = v
  def level(v) = @gain = v
  attr_reader :data
end

b = Bus.new
p b.load([1, 2][5])
p b.data
p b.load(3)
p b.level([1.5, 2.5][5])
p b.level(2.0)
