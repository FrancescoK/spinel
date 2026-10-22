# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A member read through an attr_reader whose instance variable
# instance_variable_set writes: the write may hold any value, a Float
# here, so the reader's answer is of no static kind and refused.
require "set"

class Key; end
class Hold
  attr_reader :f
end

SEEN = Set.new.compare_by_identity
n = ARGV.size + 1
2.times do
  h = Hold.new
  h.instance_variable_set(:@f, 1e300 * n)
  [Key.new, h.f].each { |v| SEEN << v }
end
p SEEN.size
