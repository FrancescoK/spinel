# A blockless reverse_each on an Enumerable whose class is only known at run
# time (read out of a mixed container) and whose own to_a answers the array
# it keeps leaves that array in its order, as the typed receiver does.
class Bag
  include Enumerable
  attr_reader :items
  def initialize(*a) = @items = a
  def each(&b) = @items.each(&b)
  def to_a = @items
end

class Words
  include Enumerable
  attr_reader :items
  def initialize = @items = ["x", "y", "z"]
  def each(&b) = @items.each(&b)
  def to_a = @items
end

class Copying
  include Enumerable
  attr_reader :items
  def initialize = @items = [1, 2, 3]
  def each(&b) = @items.each(&b)
  def to_a = @items.dup
end

class Plain
  include Enumerable
  attr_reader :items
  def initialize = @items = [4, 5, 6]
  def each(&b) = @items.each(&b)
end

b = [Bag.new(1, 2, 3), 0][0]
p b.reverse_each.to_a
p b.items
p b.reverse_each.to_a
p b.items
p b.reverse_each.first
p b.items
p b.to_a
p b.reverse_each.map { |x| x * 10 }
p b.items

w = [Words.new, 0][0]
p w.reverse_each.to_a
p w.items

c = [Copying.new, 0][0]
p c.reverse_each.to_a
p c.items

n = [Plain.new, 0][0]
p n.reverse_each.to_a
p n.items

t = Bag.new(7, 8, 9)
p t.reverse_each.to_a
p t.items

def rev(v) = v.reverse_each.to_a
p [rev(Bag.new(1, 2)), rev([3, 4]), rev({a: 1})]
