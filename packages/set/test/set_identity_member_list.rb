# A name spelled only in a constant's list that the program asks
# membership of: no computed call can be handed it, so a `public_send` of a
# computed name is no identity Set's compare_by_identity. The identity Set
# is followed, so only the calls on it are checked, and a boxed include?
# with a String elsewhere compiles.
require "set"

class Node; end

class Rng
  def initialize(b, e) = (@b = b; @e = e)
  def first = @b
  def last = @e
end

class Cop
  METHODS = %i[append clear compare_by_identity concat].to_set.freeze

  def initialize = @seen = Set.new.compare_by_identity

  def mutator?(name) = METHODS.include?(name)

  def visit(n)
    @seen.add(n)
    @seen.size
  end

  def ends(loc, names)
    names.map { |m| loc.public_send(m) }
  end
end

def pick(a, i) = a[i]
c = Cop.new
p c.mutator?(:clear), c.mutator?(:map)
p c.visit(Node.new)
p c.ends(pick([Rng.new(1, 2), 3], 0), [:first, :last])
s = Set["a", "b"]
p s.include?(pick(["a", 1], 0))
