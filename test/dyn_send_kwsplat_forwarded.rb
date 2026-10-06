class Coll
  def initialize = (@nodes = [1, "a", :b])
  def at(index) = @nodes[index]
end

class Obj
  def go = 7
  def two(a, b) = a + b
  def kw(a, b: 2) = [a, b]
  def opt(x = {}) = x
end

NAMES = %i[go at two kw opt]

def fire(object, name, *args, **kwargs) = object.send(name, *args, **kwargs)
def pfire(object, name, *args, **kwargs) = object.public_send(name, *args, **kwargs)

p fire(Obj.new, NAMES[0])
p fire(Coll.new, NAMES[1], 1)
p fire(Coll.new, NAMES[1], -1)
p fire(Obj.new, NAMES[2], 3, 4)
p fire(Obj.new, NAMES[3], 1)
p fire(Obj.new, NAMES[3], 1, b: 3)
p fire(Obj.new, NAMES[4])
p pfire(Coll.new, NAMES[1], 0)
p pfire(Obj.new, NAMES[2], 1, 2)

begin
  fire(Coll.new, NAMES[1])
rescue ArgumentError => e
  puts e.message
end
