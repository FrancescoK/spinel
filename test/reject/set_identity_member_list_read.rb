# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A name in a constant's list that the program reads otherwise than by
# asking membership: the list's names may reach a computed call, so a
# `public_send` of a computed name may be a Set's compare_by_identity,
# and every Set's calls are checked. Refused at compile time.
require "set"

class Rng
  def initialize(b, e) = (@b = b; @e = e)
  def first = @b
  def last = @e
end

class Cop
  METHODS = %i[append clear compare_by_identity concat].to_set.freeze

  def initialize = @seen = Set.new.compare_by_identity
  def names = METHODS.to_a
  def visit(n) = @seen.add(n).size
  def ends(loc, names) = names.map { |m| loc.public_send(m) }
end

def pick(a, i) = a[i]
c = Cop.new
p c.names.size
p c.visit(Object.new)
p c.ends(pick([Rng.new(1, 2), 3], 0), [:first, :last])
p Set["a", "b"].include?(pick(["a", 1], 0))
