# `@bytes[off, n] = block` where both are boxed: an Integer, Float or String
# Array receiver takes a boxed Array source whose elements fit it without
# turning into a boxed copy.
class Img
  def initialize(bytes) = @bytes = bytes
  attr_reader :bytes
  def put(off, n, data) = @bytes[off, n] = data.first(n) + Array.new(n - [data.length, n].min, data[0])
end

other = Img.new(+"text")
p other.bytes.size

ints = Img.new(Array.new(10, 0))
ints.put(2, 3, [7, 8])
ints.put(8, 4, [5])
p ints.bytes
ints.put(0, 2, [1, 2, 3])
p ints.bytes

floats = Img.new(Array.new(5, 0.0))
floats.put(1, 2, [1.5])
p floats.bytes

strs = Img.new(Array.new(4, "-"))
strs.put(1, 2, ["a", "b"])
p strs.bytes

