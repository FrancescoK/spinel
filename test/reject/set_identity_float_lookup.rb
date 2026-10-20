# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A Float looked up in an identity Set a method is handed: the Set leaves
# the place it was made an identity one in, so every Set's lookups are
# checked, and a Float is held by value here where CRuby makes a new object
# of each non-flonum one. Refused at compile time.
require "set"

def look(set) = set.include?(0.1)

ids = Set[:a, :b].compare_by_identity
p ids.include?(:a)
p look(ids)
