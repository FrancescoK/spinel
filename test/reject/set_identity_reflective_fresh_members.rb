# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A new Set written by reflection into the place that holds an identity Set
# brings its members in as the same write by assignment does, in
# parentheses or not: a member whose identity Spinel does not keep (an
# Integer here) is refused, as it is for `@s = Set[2**70, n]`. Refused at
# compile time.
require "set"

class H
  def initialize = @s = Set.new.compare_by_identity
  def reset(n) = instance_variable_set(:@s, (n += 1; Set[2**70, n]))
  def size = @s.size
end

h = H.new
h.reset(1)
p h.size
