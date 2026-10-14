class Node
  attr_reader :kids, :parent
  def initialize(parent) = (@parent = parent; @kids = [])
  def add = (k = Node.new(self); @kids << k; k)
end
class Root < Node
  def initialize = (super(nil); @extra = 1)
end
r = Root.new
r.add.add
puts r.inspect.gsub(/0x\h+/, "X")
class Holder
  def initialize(n) = (@n = n)
end
h = Holder.new(Node.new(nil))
h2 = Holder.new(Root.new)
puts h.inspect.gsub(/0x\h+/, "X"), h2.inspect.gsub(/0x\h+/, "X")
m = Marshal.load(Marshal.dump(h2))
puts m.inspect.gsub(/0x\h+/, "X")
p r.kids[0].parent.class
