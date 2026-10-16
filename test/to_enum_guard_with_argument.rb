# `return to_enum(:m) if arg.nil? && !block_given?` lets a blockless call
# that passes the argument run on to the body, so the method answers its
# Enumerator or its other value. Its result was typed the Enumerator
# alone: the other value's method was refused, or the Enumerator was
# stored into the slot of the other value and the C did not compile.

class Bag
  def initialize = @n = 0
  def bump!(by = nil, &blk)
    return to_enum(:bump!) if by.nil? && !block_given?
    @n += by || blk.call(@n)
    self
  end
  def n = @n
end

b = Bag.new
p b.bump!(2).n
p b.bump! { |x| x + 1 }.n
p b.bump!.class
x = b.bump!(4)
p x.class
p x.n
