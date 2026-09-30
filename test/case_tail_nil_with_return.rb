# A case at the end of a method whose arms return or answer nil has a nil
# value, held boxed; the method's own return slot -- an Array, from a
# `return a, b` in another arm -- takes it unboxed.
def pair_for(other)
  case other
  when Integer then return -other, other
  when String then nil
  end
end

class Infinity
  def initialize(d = 1) = @d = d
  def coerce(other)
    case other
    when Numeric then return -@d, @d
    else
      nil
    end
  end
end

p pair_for(3), pair_for("x"), pair_for(:y)
p Infinity.new.coerce(2), Infinity.new.coerce("s")
