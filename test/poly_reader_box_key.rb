# A String reader called on a boxed receiver, whose arms box the field's
# handle, is used where a box is wanted (a key of a Hash with boxed keys, an
# element of a mixed Array): the dispatch's box is that value as it is. It
# is the field's String itself, and a reader's nil stays nil.
class Var
  attr_reader :name
  def initialize(name) = @name = name
end

class Call
  attr_reader :name
  def initialize(name) = @name = name
end

class Num
  def initialize(value) = @value = value
end

env = { "x" => 1, "f" => 2, 3 => 4 }
nodes = [Var.new(String.new("x")), Call.new("f"), Num.new(5), Var.new(nil)]
sum = 0
300.times do |i|
  node = nodes[i % 4]
  next if node.is_a?(Num)
  v = env[node.name]
  sum += v if v
end
p sum

kept = [1, :s]
nodes.each { |node| kept << node.name unless node.is_a?(Num) }
p kept
p kept[2].equal?(nodes[0].name)
kept[2] << "y"
p nodes[0].name
p env.key?(nodes[3].name)
env[nodes[1].name] = 9
p env
