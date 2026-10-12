# A push through a hand-written getter, in a program that also defines a
# user <<, types the backing array from what is pushed, as an attr_reader does

class Bag
  def <<(x) = self
end
class Box
  def items
    @items
  end
  def fill
    @items = []
    items << "a"
  end
end
class Sub < Box
  def more
    items << "b"
  end
end
b = Box.new
b.fill
p b.items
s = Sub.new
s.fill
s.more
p s.items
