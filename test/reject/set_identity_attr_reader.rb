# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An identity Set in an instance variable that an attr_reader answers:
# the reader's calls are reads of the place, so the Floats added through
# it are checked and refused.
require "set"

class Box
  attr_reader :seen
  def initialize = @seen = Set.new.compare_by_identity
  def size = @seen.size
end

b = Box.new
n = ARGV.size + 1
2.times { b.seen << (1e300 * n) }
p b.size
