# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An Integer in an identity Set: an Integer is held by value here, where
# CRuby makes a new object of each Bignum, so 2**64 would be found where
# CRuby's identity Set finds nothing. Refused at compile time, as an Integer
# key of Hash#compare_by_identity is.
require "set"

s = Set.new.compare_by_identity
s << 2**64
p s.include?(2**64), s.include?(1)
