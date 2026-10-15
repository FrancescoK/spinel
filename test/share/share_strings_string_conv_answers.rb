# Flag-only. Kernel#String answers what its argument's #to_str answers, or
# with none its #to_s, as it is. A conversion that answers a String of its own
# (a dup, an interpolation, a frozen -@) is a new String the caller may change;
# one that answers the String its object holds is that String
# (share_strings_string_conv_held.rb changes it). Here the answer is compared
# with the String held, or changed when it is a new String.
class Holds
  def initialize(n) = @n = n
  def to_str = +@n
end
class HoldsS
  def initialize(n) = @n = n
  def to_s = @n.itself
end
class Dups
  def initialize(n) = @n = n
  def to_str = @n.dup
  def to_s = +"#{@n}"
end
class Frozen
  def initialize(n) = @n = n
  def to_str = -@n
end
c = +"c"
p String(Holds.new(c)).equal?(c), String(HoldsS.new(c)).equal?(c)
x = String(Dups.new(c))
x << "?"
p c, x, x.equal?(c)
y = String(Frozen.new(c))
p y, y.frozen?
w = String(Holds.new(+"w"))
p w
