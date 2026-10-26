# An attr_reader on a boxed receiver runs no code, so `@h[node.name]` reads
# @h in place; a reader another class defines with `def` still runs after
# the read of @h.
class Var
  attr_reader :name, :key
  def initialize(n) = @name = @key = n
end
class Call
  attr_reader :name
  def initialize(n) = @name = n
end
class Swap
  def initialize(t) = @t = t
  def key
    @t.reset
    "b"
  end
end

class Interp
  def initialize = reset
  def reset = @fns = { "a" => 1, "b" => 2 }
  def look(node) = @fns[node.name]
  def look2(node) = @fns[node.key]
  def drop = @fns = { "a" => 10, "b" => 20 }
end

ip = Interp.new
nodes = [Var.new("a"), Call.new("b"), nil]
sum = 0
10.times { |i| sum += ip.look(nodes[i & 1]) }
p sum
begin
  ip.look(nodes[2])
rescue NoMethodError => e
  p e.class
end
ip.drop
p [Var.new("b"), Swap.new(ip)].map { |n| ip.look2(n) }
p ip.look(Call.new("a"))
