# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# The values of a Hash made of pairs by to_h are the pairs' elements, one
# level below the Array's: a Float among them enters the identity Set, so
# the program is refused at compile time.
require "set"

class Item; end

seen = Set.new.compare_by_identity
[[:a, Item.new], [:b, 2.5]].to_h.each_value { |v| seen << v }
p seen.size
