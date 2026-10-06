# A String pushed into an Array whose element is appended to later
# (`@a << +"x"`, then `@a[0] << "!"`) is stored as a shared handle, wrapped
# around the String where the element is stored. When the push's operands
# are held in temps in Ruby's order (an ivar receiver, or a sibling call
# that can run code), the String's temp was declared as the handle, an
# sp_String *, for the const char * it holds, and the C did not build.

@a = []
@a << +"x"
@a[0] << "!"
p @a

# other in-place mutators on the element
@b = []
@b << +"x"
@b[0].upcase!
@b[0].concat("y")
@b[0].insert(0, "-")
@b[0].sub!("X", "x")
p @b

# several values, chained pushes, push and append
@c = []
@c.push(+"p", +"q")
@c.push(+"r").push(+"s")
@c.append("t".dup)
@c[0] << "!"
@c[2] << "!"
@c[4] << "!"
p @c

# the push's value, a method's String
def mk = +"m"
@d = []
v = (@d << mk)
@d.first << "!"
@d.last << "?"
p v, @d

# a local Array beside a call that can run code
def f = +"f"
a = []
a.push(f, +"x")
a[1] << "!"
a[0] << "?"
p a

# an ivar Hash's value
@h = {}
@h[:k] = +"x"
@h[:k] << "!"
@h.store(:j, +"y")
@h[:j].upcase!
p @h

# the same inside a class
class Log
  def initialize = (@lines = [])

  def add(s) = (@lines << s.dup)

  def stamp(i) = (@lines[i] << " ok")

  attr_reader :lines
end
l = Log.new
l.add("one")
l.add("two")
l.stamp(1)
p l.lines
