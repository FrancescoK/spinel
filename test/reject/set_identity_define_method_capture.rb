# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A local identity Set read from a define_method body, another method's
# scope: the read is not followed, so every Set's calls are checked.
require "set"

class Seen
  def setup
    s = Set.new.compare_by_identity
    self.class.define_method(:look) { s.include?("x") }
  end
end

v = Seen.new
v.setup
p v.look
