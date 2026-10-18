# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A Float looked up in a Set, beside an identity Set elsewhere in the
# program: a Float is held by value here where CRuby makes a new object of
# each non-flonum one. Refused at compile time.
require "set"

ids = Set[:a, :b].compare_by_identity
p ids.include?(:a)
values = Set[0.1, 0.2]
p values.include?(0.1)
