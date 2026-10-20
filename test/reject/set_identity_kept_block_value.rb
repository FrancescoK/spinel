# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An identity Set answered as the value of a block whose iterator is a
# method of the program's that keeps what its block answers: the Set
# leaves its place, so every Set's calls are checked, and the String
# looked up in a plain Set is refused.
require "set"

class Node; end

class Bag
  def each
    @kept = yield(1)
    self
  end

  def kept = @kept
end

class Seen
  def initialize = @seen = Set.new.compare_by_identity

  def fill(bag)
    bag.each { |i| @seen.add(Node.new) }
    nil
  end
end

Seen.new.fill(Bag.new)
p Set["a"].include?("a")
