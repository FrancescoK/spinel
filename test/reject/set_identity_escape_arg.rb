# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An identity Set kept in an instance variable and handed to a method that
# looks a String up in it: the Set is no longer read only where it lives,
# so the check returns to every Set's calls, and the String's identity is
# not CRuby's. Refused at compile time.
require "set"

class Seen
  def initialize
    @nodes = Set.new.compare_by_identity
  end

  def nodes = @nodes
end

def has_name?(set) = set.include?("name")

s = Seen.new
p has_name?(s.nodes)
