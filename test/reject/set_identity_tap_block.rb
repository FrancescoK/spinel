# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An identity Set an instance variable holds, handed to a block by tap:
# the block parameter is no place the Set is followed to, so every Set's
# calls are checked, and a String's identity is not CRuby's.
require "set"

class Seen
  def initialize = @seen = Set.new.compare_by_identity
  def go = @seen.tap { |s| s.add("x") }.size
end

p Seen.new.go
