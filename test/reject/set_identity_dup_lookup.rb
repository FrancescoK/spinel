# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A String looked up in the copy of an identity Set (dup compares by
# identity as the Set does): the copy is the Set's alias, and its lookup
# is checked.
require "set"

class Seen
  def initialize = @seen = Set.new.compare_by_identity
  def go = @seen.dup.include?("x")
end

p Seen.new.go
