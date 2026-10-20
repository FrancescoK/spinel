# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# The same each over parts, where one class's parts answers an
# Enumerator (each without a block): its each answers what the block
# answered, so the identity Set may be handed on, and the whole program's
# check refuses the boxed include? with a String.
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
  def parts = [].each
end

class Bundle < Item
  def initialize(n) = @n = n
  def parts = Array.new(@n) { |i| [i, Piece.new] }.to_h
end

def pick(a, i) = a[i]
items = [Pair.new(Piece.new, Bundle.new(2)), Piece.new, Bundle.new(3)]
p items.map(&:scan)
p pick([%w[a b], Set["a"]], 1).include?("a"), pick([%w[a b], Set["a"]], 0).include?("b")
