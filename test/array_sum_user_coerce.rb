# spinel: share
# spinel: gc-minor
# An Integer seed reaches the element's operator through coerce.
class SumMoney
  attr_reader :c
  def initialize(c)
    @c = c
  end
  def +(other)
    SumMoney.new(@c + other.c)
  end
  def coerce(n)
    [SumMoney.new(n), self]
  end
end
ms = [SumMoney.new(1), SumMoney.new(2)]
p ms.sum(0).c
p ms.sum.c
p ms.sum(5) { |m| m }.c
