# spinel: share
# spinel: gc-minor
# An Array of shared Strings an instance variable holds is held as their
# handles, as the methods that read, change and answer it see one Array.
class Log
  def initialize
    @rows = []
  end
  def add(s)
    @rows << s
    self
  end
  def bang
    @rows.each { |r| r << "!" }
    @rows[0] << "?"
  end
  def size = @rows.size
  def dump = p(@rows)
  def rows = @rows
end
l = Log.new
t = +"t"
l.add(t).add(+"u")
l.bang
l.dump
p t, l.size
r = l.rows
r << +"v"
r[0] << "."
r.each { |x| x << "," }
p l.rows, t, r.size

# a base class's slot reached from its subclass
class Base
  def initialize(s)
    @items = [s]
  end
  def add(s) = @items << s
  def items = @items
end
class Sub < Base
  def bang = @items.each { |i| i << "S" }
end
s = Sub.new(t)
s.add(+"x")
s.bang
s.items << +"y"
s.items[0] << "z"
p s.items, t

# a slot per object
class Cell
  def initialize(s) = @list = [s]
  def add(s) = @list << s
  def bang = @list.each { |e| e << "c" }
  def list = @list
end
a = Cell.new(+"a")
b = Cell.new(+"b")
a.add(t)
b.add(t)
a.bang
p a.list, b.list, t

# built on first use
class Lazy
  def rows = (@rows ||= [])
  def add(x) = rows << x
end
lz = Lazy.new
lz.add(t)
lz.rows.each { |e| e << "L" }
p lz.rows, t

# allocation while it grows
class Grow
  def initialize = @all = []
  def push(i)
    s = +"g"
    @all << s
    s << i.to_s
  end
  def total = @all.sum { |x| x.size }
end
g = Grow.new
400.times { |i| g.push(i); GC.start if i % 100 == 0 }
p g.total
