# A chained `<<` onto a string buffer, in value position, inside a block
# that is compiled as a real proc (the receiver may be a user `each`): the
# base is read through the proc's capture, not as the enclosing method's
# plain local, which the proc body does not have. Crass's
# Parser.stringify has this shape under Loofah.
class Bag
  def initialize(items)
    @items = items
  end

  def each(&block)
    @items.each(&block)
  end
end

def stringify(nodes)
  string = String.new
  nodes.each do |node|
    x = (string << "[" << node.to_s << "]")
  end
  string
end

def stringify_case(nodes)
  string = String.new
  nodes.each do |node|
    case node
    when Integer
      string << "<" << node.to_s << ">"
    end
  end
  string
end

p stringify([1, 2])
p stringify(Bag.new([3]))
p stringify_case([4, "x", 5])
p stringify_case(Bag.new([6]))
