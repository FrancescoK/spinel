# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An identity Set reached through a Method of the method that answers it
# (`b.method(:seen).call`): the program names the reader by a Symbol, so
# the place is not followed and the Floats added are refused.
require "set"

class Box
  def initialize = @seen = Set.new.compare_by_identity
  def seen = @seen
  def size = @seen.size
end

b = Box.new
n = ARGV.size + 1
2.times { b.method(:seen).call << (1e300 * n) }
p b.size
