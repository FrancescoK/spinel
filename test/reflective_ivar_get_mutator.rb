# A String an object holds in an ivar, changed in place through the
# reflective read of the ivar (`obj.instance_variable_get(:@name) << x`):
# the change is the ivar's own, as it is through an attribute reader. The
# pass that promotes an ivar a reader's mutator reaches asks the same
# question of the reflective read, whose one argument names the ivar.
class Box
  attr_reader :name
  def initialize(n) = @name = n
end
class Holder
  def initialize(n) = (@items = [n]; @title = n)
  def show = @title
end
s = +"base"
b = Box.new(s)
b.instance_variable_get(:@name) << "!"
p s
puts(b.instance_variable_get(:@name) << "?")
p s, b.name.equal?(s)

t = +"title"
h = Holder.new(t)
h.instance_variable_get(:@title) << "?"
h.instance_variable_get(:@title).upcase!
p t, h.show

list = [Box.new(+"in")]
list[0].instance_variable_get(:@name) << "x"
p list[0].name

def grab = Box.new(+"gg")
g = grab
g.instance_variable_get(:@name).insert(0, "<")
p g.name

c = Box.new(+"cc")
x = c.instance_variable_get(:@name)
x.concat("+")
p c.name, x.equal?(c.name)

class Box2
  def initialize = @v = "lit"
end
begin
  Box2.new.instance_variable_get(:@v) << "!"
rescue FrozenError
  p :frozen
end

# an ivar that holds nil: the mutator's receiver is nil, as through a reader
class Maybe
  def set(x) = (@k = x)
end
m = Maybe.new
begin
  m.instance_variable_get(:@k) << "!"
rescue NoMethodError => e
  p e.class
end
begin
  m.instance_variable_get(:@k).upcase!
rescue NoMethodError => e
  p e.class
end
k = +"abc"
m.set(k)
m.instance_variable_get(:@k) << "?"
p k
