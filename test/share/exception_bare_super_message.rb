# A bare super in an exception's initialize forwards its String parameter to
# Exception#initialize. When the program changes an exception message in
# place, that parameter holds the shared String, and the exception keeps it
# as its message: the String it was built with, changed through the message
# or through the variable it was handed from.
class E < StandardError
  def initialize(m = "dm") = super
end
class F < StandardError
  def initialize(m)
    super
  end
end
class N < StandardError
  def initialize(m = nil) = super
end

src = +"s"
begin; raise src; rescue => e; e.message << "!"; end
p src
p E.new.message, E.new.message.frozen?

a = +"a"
x = E.new(a)
x.message << "1"
p a, x.message, x.message.equal?(a)
a << "2"
p x.message

b = +"b"
begin
  raise E, b
rescue E => e2
  e2.message << "3"
end
p b

c = +"c"
y = F.new(c)
c.replace("C")
p y.message, y.to_s, y.message.equal?(c)

d = +"d"
begin
  raise F.new(d)
rescue => e3
  e3.message.upcase!
end
p d

def make(s) = E.new(s)
g = +"g"
z = make(g)
z.message << "!"
p g, z.message

def text(s) = F.new(s).message
h = +"h"
t = text(h)
t << "x"
p h, t, t.equal?(h)

p N.new.message
w = +"w"
n = N.new(w)
n.message << "?"
p w
