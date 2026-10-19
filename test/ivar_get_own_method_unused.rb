# A class defines its own instance_variable_get, and no instance of it is
# ever made. A read of the same name on a receiver that can be of another
# class is still the builtin's, and answers the ivar's String itself, as an
# Array's element, a Hash's value and a block's value do.
class Own
  def instance_variable_get(x) = +"mine"
end
class Fr
  def initialize(x) = (@s = x)
  def s = @s
end

f = Fr.new(+"fr")
objs = [f, Fr.new(+"o2"), 3]
pr = objs[ARGV.size]
w = [pr.instance_variable_get(:@s), 1][0]
w << "#"
p f.s, w.equal?(f.s)

h = { k: pr.instance_variable_get(:@s) }
h[:k] << "?"
p f.s, h[:k].equal?(f.s)

r = "a".then { |q| pr.instance_variable_get(:@s) }
r << "T"
p f.s, r.equal?(f.s)

u = pr.instance_variable_get(:@s)
u << "!"
p f.s, u.equal?(f.s)

p Own.instance_method(:instance_variable_get).owner
