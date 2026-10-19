# A base class's method calls a method only its subclasses define (a
# template method). The call dispatches on self's class, so it answers the
# subclass's String itself: kept, handed on and changed in place, it is
# that String.

class Base
  attr_reader :kept

  def keep
    @kept = label
    self
  end

  def hand_on(sink)
    sink << label
    sink
  end

  def built = header + "|"
end

class One < Base
  def initialize(s) = (@s = s)
  def label = @s
  def header = ["ONE", 1].pack("a3C")
end

class Two < Base
  def initialize(s) = (@s = s)
  def label = @s
  def header = "TWO" + @s
end

a = +"one"
b = +"two"
x = One.new(a).keep
y = Two.new(b).keep
x.kept << "!"
y.kept << "?"
p a, b, x.kept.equal?(a), y.kept.equal?(b)

sink = x.hand_on([])
y.hand_on(sink)
sink[0] << "1"
sink[1] << "2"
p a, b, sink[0].equal?(a), sink[1].equal?(b)

p x.built, y.built
