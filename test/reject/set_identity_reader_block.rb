# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A reader of an identity Set called with a block it ignores: the call
# still answers the Set, and the String looked up in it is checked.
require "set"

class Seen
  def initialize = @seen = Set.new.compare_by_identity
  def seen = @seen
  def go = seen { }.include?("x")
end

p Seen.new.go
