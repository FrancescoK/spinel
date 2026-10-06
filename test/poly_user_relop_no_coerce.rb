# A class that defines its own <, >, <= or >= -- and no coerce -- orders its
# instances when they arrive boxed (out of a mixed Array, a poly local or
# parameter): the comparison reaches the user method through the binop
# table, as `+` and `==` always did, where it raised "comparison of Money
# with Money failed". Numbers beside them keep comparing as numbers, and a
# subclass answers through the method it inherits.
class Money
  attr_reader :c
  def initialize(c)
    @c = c
  end
  def <(o) = c < o.c
  def >(o) = c > o.c
  def <=(o) = c <= o.c ? :le : nil
  def >=(o) = c >= o.c
end
class Euro < Money; end

vals = [Money.new(1), 3, Euro.new(5), 2.5]
p vals[0] < vals[2], vals[2] > vals[0], vals[0] <= vals[2], vals[2] <= vals[0], vals[2] >= Money.new(5)
p vals[1] < vals[3], vals[3] > vals[1]
def lt(a, b) = a < b
p lt(vals[0], vals[2]), lt(vals[1], 4)
p vals.select { |v| v.is_a?(Money) }.sort { |a, b| a > b ? -1 : 1 }.map(&:c)
