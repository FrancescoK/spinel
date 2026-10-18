# Flag-only. A subclass of StringIO takes the class's `string=`, which keeps
# the very String it is handed: a change to it through another name shows in
# the object, a write through the object shows in it, #string answers it, and
# the value of the assignment is that String, as for the class itself. The
# same for a subclass that defines a `string=` of its own that does not reach
# the class's, or reaches it with a new String.
require "stringio"

class Plain < StringIO; end

io = Plain.new
s = +"x"
io.string = s
s << "!"
p io.string
io.write("Z")
p s
t = io.string
t << "?"
p s, t.equal?(s)

io = Plain.new
s = +"x"
r = (io.string = s)
r << "!"
p s, r.equal?(s), io.string
(io.string = s) << "1" << "2"
p s, io.string
n = +"n"
r = (io.string = n)
n << "1"
p r, io.string
r = (io.string = +"new")
r << "2"
p io.string, r.equal?(io.string)
a = [io.string = s]
a[0] << "3"
p s, a[0].equal?(s), io.string
def tail(io, s)
  io.string = s
end
u = +"u"
r = tail(io, u)
r << "4"
p u, r.equal?(u), io.string

io = Plain.new(+"ab")
v = +"cd"
r = (io.string = v)
v << "e"
p io.read, io.string, r.equal?(v)

$calls = []
class Counting < StringIO
  def string=(v)
    $calls << v
  end
end

c = Counting.new
w = +"w"
r = (c.string = w)
w << "!"
p r, r.equal?(w), $calls, $calls[0].equal?(w)
c.string = w
p $calls.size, c.string

class Marking < StringIO
  def string=(v)
    super(v + "!")
    :ignored
  end
end

m = Marking.new
q = +"q"
r = (m.string = q)
q << "?"
p r, q, m.string, r.equal?(q)

# a subclass built with a String keeps it as the class does, also a subclass
# of a subclass and one opened with a mode
class Deeper < Plain; end
s = +"ab"
io = Plain.new(s)
s << "!"
p io.string
io.write("Z")
p s
t = +"cd"
d = Deeper.new(t)
d << "E"
p t, d.string.equal?(t)

# the attribute's reader and writer through `||=` on a subclass
pl = Plain.new(+"a")
q = +"q"
pl.string ||= q
p pl.string.equal?(q)
pl.string &&= q
q << "?"
p pl.string, pl.string.equal?(q)
