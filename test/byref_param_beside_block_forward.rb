# A method that appends to its String parameter is lent the caller's
# String, even when the program forwards a block parameter (`&b`) that the
# compiler turned into a literal block and holds a Method object of that
# method: the forward is no dynamic reach of a method name, and the append
# must not land in a copy (`:put` spells the writer's name).
module Walk
  def walker = method(:each_node)
end
class Graph
  include Walk
  def initialize(h) = @h = h
  def each_node(&b) = @h.each_key(&b)
end
class Writer
  def put(out) = out << "!"
end
g = Graph.new({1 => [2]})
g.each_node { |n| p n }
s = +"a"
Writer.new.put(s)
p s, :put
