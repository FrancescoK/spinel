# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A class-level identity Set a `class << self` attr_reader answers: the
# reader's calls are reads of the place, so the Floats added through it
# are refused.
require "set"

class Box
  class << self
    attr_reader :seen
  end
  @seen = Set.new.compare_by_identity
  def self.size = @seen.size
end

n = ARGV.size + 1
2.times { Box.seen << (1e300 * n) }
p Box.size
