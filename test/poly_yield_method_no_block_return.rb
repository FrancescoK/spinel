# A yielding method that answers something else when no block is given,
# called on a boxed receiver. The dispatch calls its proc form, whose body
# answers the Array; the call was typed by the yield form, which answers
# self alone, and the Array was unboxed as the class (TypeError).

class Node
  def initialize(name) = @name = name
  def name = @name

  def each_node
    list = [self]
    return list unless block_given?

    list.each { |d| yield d }
    self
  end
end

def count(x)
  c = 0
  x.each_node { |_d| c += 1 }
  c
end

def names_of(x) = x.each_node.map(&:name)

v = [Node.new("a"), "not a node"].first
p count(v)
p names_of(v)
p v.each_node.size
p(v.each_node { |_d| nil }.name)
