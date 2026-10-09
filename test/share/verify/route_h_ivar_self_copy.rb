class Node
  attr_reader :name
  def initialize(name) = (@name = name)
  def rename = (@name << "!")
  def twin = Node.new(@name)
end
n = Node.new(+"n")
t = n.twin
t.rename
p n.name
