# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An identity Set answered as the value of an Array's each block, where
# the program reopens Array with an each that keeps what its block
# answers: the Set leaves its place, so every Set's calls are checked,
# and the String looked up in a plain Set is refused.
require "set"

class Node; end

class Array
  def each(&blk) = map(&blk)
end

class Seen
  def initialize = @seen = Set.new.compare_by_identity

  def fill
    [1, 2].each { |i| @seen.add(Node.new) }
  end
end

p Seen.new.fill.size
p Set["a"].include?("a")
