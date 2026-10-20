# A dispatch by a computed name, read out of a table built of Symbol
# literals (an Array literal with a splat of a product, to_h, freeze): only
# the methods the table names can be called that way, so the parameter of
# a method it does not name holds only what its callers pass, and the
# identity Set's members, read under a class predicate, are objects.
require "set"
class Item
  def pair? = false
  def group? = false
end
class Pair < Item
  def initialize(first, second) = (@first = first; @second = second)
  def parts = [@first, @second]
  def pair? = true
  def kind = :pair
end
class Group < Item
  def initialize(head, rest) = (@head = head; @rest = rest)
  def parts = [@head, @rest]
  def group? = true
  def kind = :group
end
class Num < Item
  def initialize(value) = @value = value
  def parts = [@value]
  def kind = :num
end
class Leaf < Item
  def parts = []
  def kind = :leaf
end
class Walker
  SCOPE_KINDS = (%i[pair] + [:group]).freeze
  HANDLERS = [[:num, :visit_num], *SCOPE_KINDS.product([:visit_scope])].to_h.freeze
  def seen = (@seen ||= Set.new.compare_by_identity)
  def walk(item)
    name = HANDLERS[item.kind]
    send(name, item) if name
    seen.size
  end
  def visit_num(item) = item.parts.size
  def visit_scope(item)
    return unless item.pair? || item.group?

    heads(item).each { |h| seen << h }
  end
  def heads(item)
    list = [item.parts[0]]
    list << item.parts[1] if item.group?
    list.compact
  end
end
leaf = Leaf.new
w = Walker.new
p [Pair.new(leaf, nil), Group.new(leaf, Leaf.new), Num.new(1.5), Num.new(2**70), leaf].map { |it| w.walk(it) }
p w.seen.include?(leaf)
