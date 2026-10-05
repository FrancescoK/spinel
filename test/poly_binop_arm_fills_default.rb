# An operator on a boxed receiver runs through the binop dispatch.
# Each arm passes the default of an optional parameter, run on the
# receiver.
class Money
  attr_reader :cents

  def initialize(cents, scale)
    @cents = cents
    @scale = scale
  end

  def +(other, scale = @scale)
    Money.new(@cents + other.cents * scale, @scale)
  end

  def ==(other, scale = @scale)
    @cents * scale == other.cents * scale
  end

  def [](i, offset = @scale)
    i + offset
  end
end

items = [Money.new(100, 2), "note", 3]
m = items[0]
p (m + Money.new(5, 1)).cents
p m == Money.new(100, 9)
p m[10]
acc = items.reduce(nil) { |a, e| a.nil? ? e : a }
p acc == Money.new(100, 1)
