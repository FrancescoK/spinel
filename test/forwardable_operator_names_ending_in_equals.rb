# def_delegators of the operators whose names end in `=` (`[]=`, `==`) and
# of `<=>`: each is a forwarding def like any other name. The forwarding
# defs used to be source text, which wrote these as setter aliases and did
# not parse.
require "forwardable"
class Box
  extend Forwardable
  def_delegators :@items, :[], :[]=, :==, :size
  def_delegator :@items, :<=>, :cmp
  def initialize(items) = @items = items
end
b = Box.new([3, 4])
b[0] = 9
p b[0], b.size
p b == [9, 4]
p b == [9, 5]
p b.cmp([9, 5])
