# `a.fill(v, start, len)` on a boxed receiver fills the Array itself where
# the value fits it, and answers it; every other case answers as before.
class Img
  def initialize(bytes) = @bytes = bytes
  attr_reader :bytes
  def all(v) = @bytes.fill(v)
  def from(v, s) = @bytes.fill(v, s)
  def span(v, s, n) = @bytes.fill(v, s, n)
end

p Img.new(+"text").bytes.size

ints = Img.new([1, 2, 3, 4, 5, 6])
p ints.span(0, 1, 2)
p ints.span(9, -2, 1)
p ints.span(7, 4, 5)
p ints.span(8, 9, 1)
p ints.span(5, 0, -1)
p ints.from(3, 7)
p ints.all(1).equal?(ints.bytes)

floats = Img.new([1.0, 2.0, 3.0])
p floats.span(0.5, 1, 1)

mixed = Img.new([1, "a", nil])
p mixed.span(:x, 1, 5)

strs = Img.new(%w[a b c])
p strs.from("z", 1)

frozen = Img.new([1, 2].freeze)
begin
  frozen.all(0)
rescue FrozenError => e
  puts "FrozenError"
end
