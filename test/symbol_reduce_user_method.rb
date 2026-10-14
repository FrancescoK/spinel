# A builtin that takes a method name as a Symbol (`reduce(:combine)`,
# `inject(init, :absorb)`, `reduce(&:plus)`, `each_with_object(x, &:add)`)
# calls that method of the program's class with an argument of its own. The
# only call the program writes passes another class, so the parameter must
# still hold what the builtin passes. Each form names its own method, so
# each form alone keeps its method's parameter open.

class Order
  attr_reader :total

  def initialize(total) = @total = total
  def combine(other) = Order.new(@total + other.total)
  def absorb(other) = Order.new(@total + other.total)
  def plus(other) = Order.new(@total + other.total)
end

class Refund
  attr_reader :total

  def initialize(total) = @total = total
end

class Coupon
  def label = "coupon"
end

class Item
  def label = "item"
end

class Cart
  attr_reader :labels

  def initialize = @labels = []

  def add(entry)
    @labels << entry.label
    nil
  end
end

orders = [Order.new(10), Order.new(20), Order.new(5)]
p orders.reduce(:combine).total
p orders.inject(Order.new(100), :absorb).total
p orders.reduce(&:plus).total
p Order.new(1).combine(Refund.new(-1)).total
p Order.new(2).absorb(Refund.new(-2)).total
p Order.new(3).plus(Refund.new(-3)).total

carts = [Cart.new, Cart.new]
carts.each_with_object(Coupon.new, &:add)
Cart.new.add(Item.new)
p carts.map(&:labels)
