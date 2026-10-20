# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A send whose name is made at run time (to_sym) may reach any writer:
# the Float it writes is read back into the identity Set, so the program
# is refused at compile time.
require "set"
class Item
  attr_accessor :tag
end
s = Set.new.compare_by_identity
it = Item.new
it.tag = Item.new
it.send("tag=".to_sym, 1.5)
s << it.tag
p s.size
