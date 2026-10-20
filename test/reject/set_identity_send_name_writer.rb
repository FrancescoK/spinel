# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A send whose name is read out of a table of Symbols reaches the writer
# the table names: the Float it writes is read back into the identity Set,
# so the program is refused at compile time.
require "set"
class Item
  attr_accessor :tag
end
NAMES = %i[tag=].freeze
s = Set.new.compare_by_identity
it = Item.new
it.tag = Item.new
it.send(NAMES[0], 1.5)
s << it.tag
p s.size
