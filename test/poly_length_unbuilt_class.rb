# A class nothing constructs has no arm in a poly receiver's dispatch, so its
# `length` answering a Float must not widen `poly.length` for the classes that
# are built: the count stays an Integer and the Range built from it stays an
# Integer Range.
class Tape
  def initialize(crossings)
    @crossings = crossings
  end

  def length = @crossings.empty? ? 0 : @crossings.last
end

class Image
  def initialize(bytes)
    @bytes = bytes
  end

  def length = @bytes.length
end

def count(x) = x.length

items = [[1, 2, 3], Image.new([4, 5]), "abc"]
n = 0
items.each { |x| n += count(x) }
p n
p items.map { |x| (0...count(x)).to_a }
