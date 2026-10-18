# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A String added to a Set in a program that makes a Set compare by identity:
# equal-content Strings may be one object here where CRuby has two, so the
# identity Set would find it otherwise than CRuby's. Refused at compile time.
require "set"

s = Set.new.compare_by_identity
s << "a"
p s.include?("a")
