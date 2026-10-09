# spinel: not-cruby -- two different signatures for one method are refused
# Two openings annotate a method's parameter as Integer and as Integer?: a
# type and its nil-able form are different types.
class K
  #: (Integer) -> Integer
  def m(x) = x
end

class K
  #: (Integer?) -> Integer
  def m(x) = x || 0
end

p K.new.m(1)
