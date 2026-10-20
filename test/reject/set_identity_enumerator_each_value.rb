# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An identity Set answered by the block of an Enumerator's each: the
# Enumerator of map answers the block's values, so the Set leaves its
# place, and every Set's calls are checked. Refused at compile time.
require "set"
class Node; end
B = nil
class Seen
  def initialize = @seen = Set.new.compare_by_identity
  def fill
    @out = [1, 2].each_slice(1).map { |i| i }
    [3].map.each { |i| @seen.add(Node.new) }
    nil
  end
end
Seen.new.fill
p Set["a"].include?("a")
