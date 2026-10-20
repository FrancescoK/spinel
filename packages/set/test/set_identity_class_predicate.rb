# A member taken from a list whose classes hold other kinds: only under the
# test of a predicate that answers true in Pair and Group alone (every other
# class answers false by its literal body) does the list reach the identity
# Set, so only their parts, objects and nil, enter it, while a Num's
# Float and Bignum and a Text's String never do. The same holds for the
# statements after a guard `return unless item.pair?`.
require "set"

class Item
  def pair? = false
  def group? = false
end

class Pair < Item
  def initialize(first, second) = (@first = first; @second = second)
  def parts = [@first, @second]
  def pair? = true
end

class Group < Item
  def initialize(head, rest) = (@head = head; @rest = rest)
  def parts = [@head, @rest]
  def group? = true
end

class Num < Item
  def initialize(value) = @value = value
  def parts = [@value]
end

class Text < Item
  def initialize(text) = @text = text
  def parts = [@text]
end

class Leaf < Item
  def parts = [:leaf, nil]
end

class Registry
  def seen = (@seen ||= Set.new.compare_by_identity)

  def heads(item)
    list = [item.parts[0]]
    list << item.parts[1] if item.group?
    list.compact
  end

  def visit(item)
    if item.pair? || item.group?
      heads(item).each { |h| seen << h }
    end
    seen.size
  end

  def kept = (@kept ||= Set.new.compare_by_identity)

  def keep(item)
    return unless item.pair?

    kept << item.parts[0]
    kept.size
  end
end

leaf = Leaf.new
other = Leaf.new
items = [Pair.new(leaf, nil), Group.new(leaf, other), Num.new(1.5), Num.new(2**70), Text.new("t"), leaf]
r = Registry.new
p items.map { |it| r.visit(it) }
p r.seen.include?(leaf), r.seen.include?(other), r.seen.include?(Leaf.new)
p items.map { |it| it.parts[0].class }
p items.map { |it| r.keep(it) }, r.kept.include?(leaf)
