# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A boxed value that may be a Float enters an identity Set: a Float is held
# by value here, where CRuby makes an object of each one that is no flonum,
# so the identity Set would find it otherwise than CRuby's. Refused at
# compile time.
require "set"

class Item; end

seen = Set.new.compare_by_identity
[Item.new, 1.0e-300].each { |v| seen << v }
p seen.size
