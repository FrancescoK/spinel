# Hash#merge with a conflict block on a value that is a Hash or a program
# class with a merge of its own: a genuine Hash merges through the block,
# its answer boxed into the slot the dispatch shares with the class's arm.
class Indiff
  def initialize(h = {}) = @h = h
  def merge(other, &block) = Indiff.new(@h.merge(other, &block))
  def to_h = @h
end
class Dur
  attr_reader :value
  def initialize(value, parts)
    @value, @parts = value, parts
  end
  def _parts = @parts
  def +(other)
    if Dur === other
      parts = @parts.merge(other._parts) do |_key, value, other_value|
        value + other_value
      end
      Dur.new(value + other.value, parts)
    else
      Dur.new(value + other, @parts.merge(seconds: other))
    end
  end
  def parts = @parts
end
p (Dur.new(1, { a: 1 }) + Dur.new(2, { a: 2, b: 3 })).parts
p (Dur.new(1, { a: 1 }) + 5).parts
p (Dur.new(1, Indiff.new({ x: 1 })) + Dur.new(2, { x: 2 })).parts.to_h
