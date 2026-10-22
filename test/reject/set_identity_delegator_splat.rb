# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An identity Set an instance variable holds, added to through a
# def_delegator: the forwarding method hands the Set its arguments in a
# splat, and each element is a member. The Floats are refused.
require "set"
require "forwardable"

class Box
  extend Forwardable
  def_delegator :@seen, :add, :put
  def initialize = @seen = Set.new.compare_by_identity
  def size = @seen.size
end

b = Box.new
n = ARGV.size + 1
2.times { b.put(1e300 * n) }
p b.size
