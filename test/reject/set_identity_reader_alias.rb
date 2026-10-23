# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An identity Set in an instance variable, reached through an alias of
# the method that answers it: the alias's calls are no read the place is
# followed through, so every Set's calls are checked, and the Floats
# added through the alias are refused.
require "set"

class Box
  def initialize = @seen = Set.new.compare_by_identity
  def seen = @seen
  def size = @seen.size
  alias_method :s2, :seen
end

b = Box.new
n = ARGV.size + 1
2.times { b.s2 << (1e300 * n) }
p b.size
