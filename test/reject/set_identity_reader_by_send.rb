# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A reader of an identity Set called by a computed name: the call answers
# the Set where no place follows it, so every Set's calls are checked, and
# the String looked up in it is refused.
require "set"

class Seen
  def initialize = @seen = Set.new.compare_by_identity
  def seen = @seen
end

name = [:seen, :x][0]
p Seen.new.send(name).include?("a")
