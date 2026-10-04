# A block forwarded through `&block` into instance_eval: a bare call in it
# answers on the receiver, whose method wins over a top-level def of the
# same name. It took the top-level def (ArgumentError for its arity, or the
# top-level's return type).
class World
  def fact(id, value) = "world-fact(#{id}, #{value})"
  def count(id, value) = value * 10
end

def fact(name) = "toplevel-fact(#{name})"
def count(name) = "top-#{name}"

def fleet(_name, &block)
  World.new.instance_eval(&block) if block
end

fleet "demo" do
  puts fact(:a, 1)
  p count(:b, 4) + 1
end
puts fact(:c)
p count(:d)
