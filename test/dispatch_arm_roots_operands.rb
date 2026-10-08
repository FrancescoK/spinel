# A dispatch arm that allocates before its call (an empty rest, a rest
# that takes the argument, a default that builds a String) keeps both
# operands alive. gc-stress-test runs this under SPINEL_GC_STRESS=2.
# spinel: gc-stress
class Tag
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def ==(other, *more)
    @name == other.name && more.empty?
  end
end

class Label
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def ==(other, note = "eq-#{@name}")
    @name == other.name && note.start_with?("eq-")
  end
end

class Money
  attr_reader :cents

  def initialize(cents)
    @cents = cents
  end

  def +(*terms)
    Money.new(@cents + terms.sum(&:cents))
  end
end

p [Tag.new("a"), Tag.new("b")].include?(Tag.new("b"))
p [Label.new("a"), Label.new("b")].index(Label.new("b"))
items = [Money.new(100), "note", 3]
p (items[0] + Money.new(5)).cents
