# A reader the subclasses inherit is read through the struct of the
# ancestor that lays its field out the same way (#10549): subclasses that
# add ivars of their own, or hold another kind in the inherited ivar, keep
# reading their own field.
class Node
  attr_reader :doc, :line
  def initialize(d, l = 1) = (@doc = d; @line = l)
end
class Leaf < Node; end
class Wide < Node
  attr_reader :extra
  def initialize(d) = (super(d, 2); @extra = 7; @more = nil)
end
class Named < Node
  def initialize(d) = (@doc = d; @line = "three")
end
class Deep < Leaf
  def initialize(d) = (super(d, 4); @tag = 9)
end
nodes = [Node.new(1), Leaf.new(nil), Wide.new(3), Named.new("s"), Deep.new(5), 42]
nodes.each do |n|
  next p(:none) unless n.respond_to?(:doc)
  p [n.class, n.doc, n.line]
end
p nodes.select { |n| n.respond_to?(:extra) }.map(&:extra)
p nodes.map { |n| n.respond_to?(:line) ? n.line : nil }
