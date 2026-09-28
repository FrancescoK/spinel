# flat_map whose block answers an Array[String] builds beside a method whose
# Array answer comes from two paths and a user map(&block) that forwards to
# an Array's map (#5487).
class Node
  def classes; Node.keywords("a b"); end
  def remove_class(names = nil); Node.keywords(names); end
  def self.keywords(names)
    return names.map { |n| n.to_s } if names.is_a?(Array)
    names.to_s.split(" ")
  end
end
class NodeSet
  def initialize(nodes); @nodes = nodes; end
  def map(&block); @nodes.map(&block); end
end
NodeSet.new([]).map { |x| x }
p [Node.new, Node.new].flat_map { |n| n.classes }
