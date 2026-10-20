# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An identity Set answered by a block whose iterator yields from inside a
# lambda and keeps what the lambda answers: the Set leaves its place, and
# every Set's calls are checked. Refused at compile time.
require "set"
class Node; end
class Bag
  def each
    @kept = -> { yield 1 }.call
    self
  end
end
B = Bag.new
class Seen
  def initialize = @seen = Set.new.compare_by_identity
  def fill
    B.each { |i| @seen.add(Node.new) }
    nil
  end
end
Seen.new.fill
p Set["a"].include?("a")
