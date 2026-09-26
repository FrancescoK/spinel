# A genuine Hash reaching `slice` boxed keeps Hash#slice when a user class
# owns the name and answers either an object or an element, the shape of
# Nokogiri's NodeSet#slice(i, len = nil).
class NodeSet
  include Enumerable
  def initialize(list = []) = @list = list
  def each(&block) = @list.each(&block)
  def [](i, len = nil)
    if len
      NodeSet.new(@list[i, len])
    else
      @list[i]
    end
  end
  def slice(i, len = nil) = self[i, len]
end

ns = NodeSet.new([1, 2, 3])
p ns.slice(0)
p ns.slice(1, 2).to_a
k = { a: { "x" => 1, "y" => 2 }, b: [7, 8, 9] }
p k[:a].slice("x")
p k[:a].slice("x", "y")
p k[:b].slice(1)
p k[:b].slice(0, 2)
