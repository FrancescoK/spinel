# A dispatch arm calls a method whose rest takes the call's argument.
# The arm passes the argument in an Array, as a direct call does.
class Tag
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def ==(*others)
    others.size == 1 && @name == others[0].name
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
p [Tag.new("a"), Tag.new("b")].index(Tag.new("c"))

items = [Money.new(100), "note", 3]
m = items[0]
p (m + Money.new(5)).cents
