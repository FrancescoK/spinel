# Flag-only. Kernel#String of a boxed value, whose #to_str or #to_s may be
# any of several classes': each one answers a String of its own (a dup, an
# interpolation, a frozen -@), so the call is a new String the caller may
# change, and a Symbol or an Integer in the box converts by the builtin.
class Dups
  def initialize(n) = @n = n
  def to_str = @n.dup
end
class Interp
  def initialize(n) = @n = n
  def to_s = +"#{@n}"
end
class Pair
  def initialize(n) = @n = n
  def to_str = [@n, @n].join
end
c = +"c"
vs = [Dups.new(c), Interp.new(c), Pair.new(c), 1, :sym, "str"]
vs.each do |v|
  z = String(v)
  z << "!" unless v.frozen?
  p z
end
p c
