# A Hash constant written as a literal of one key and value class, then given
# keys or values of another through a store or a merge!: the constant takes
# the general Hash, and its literal is built as one.

class Table
  EV = { a: [:x], b: %i[y z] }
  EV.merge!(EV.flat_map { |_, vs| vs.map { |v| [v, [v]] } }.to_h)
end
p Table::EV

NAMES = { a: [:x] }
NAMES["s"] = [:t]
NAMES[1] = [:u]
p NAMES
p NAMES["s"], NAMES[1], NAMES[:a]

module Codes
  T = { a: 1 }
  T.merge!([["k", 2]].to_h)
  T.update(3 => :three)
end
p Codes::T
p Codes::T.keys.map(&:class)

# a store of the literal's own classes leaves it as it was
SAME = { a: 1 }
SAME[:b] = 2
p SAME
