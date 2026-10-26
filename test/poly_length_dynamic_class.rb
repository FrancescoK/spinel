# A class built only through a Class value the compiler cannot name still
# answers a poly receiver's `length`, and its Float joins the union.
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

KINDS = { "tape" => Tape }.freeze

def count(x) = x.length

kind = ARGV.empty? ? "tape" : "none"
items = [[1, 2, 3], Image.new([4, 5]), KINDS.fetch(kind).new([1.5, 2.5])]
items.each { |x| p count(x) }
