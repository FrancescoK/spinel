# An identity Set's alias answered as the value of an each block over a
# method's answer the analysis boxes (parts answers an Array of a pair's
# items in one class, an empty one in another, a Hash in a third): every
# method the call can reach answers an Array or a Hash, no Enumerator, so
# the each drops the block's value and the Set is followed there. A boxed
# include? with a String elsewhere compiles.
require "set"

class Item
  def seen_items
    @seen_items ||= Set.new.compare_by_identity
  end

  def scan
    parts.each do |_x|
      seen_items << Item.new
    end
    seen_items.size
  end
end

class Pair < Item
  def initialize(a, b) = (@a = a; @b = b)
  def parts = [@a, @b]
end

class Piece < Item
  def parts = []
end

class Bundle < Item
  def initialize(n) = @n = n
  def parts = Array.new(@n) { |i| [i, Piece.new] }.to_h
end

def pick(a, i) = a[i]
items = [Pair.new(Piece.new, Bundle.new(2)), Piece.new, Bundle.new(3)]
p items.map(&:scan)
p pick([%w[a b], Set["a"]], 1).include?("a"), pick([%w[a b], Set["a"]], 0).include?("b")
