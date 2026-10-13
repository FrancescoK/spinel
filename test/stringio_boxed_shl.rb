# A StringIO reached through a box (an Array element beside other values, a
# block's or a method's parameter) takes `<<` through its binding, as a typed
# StringIO does, and answers itself: a chain appends each operand. Beside
# it in the same box a String appends, an Integer shifts, and a class with
# a `<<` of its own runs it.
require "stringio"
class Sink
  def initialize; @a = []; end
  def <<(x); @a << x; self; end
  def string = @a.join(",")
end
def log(io, m) = io << m << "\n"

o = [1, StringIO.new(+"ab")][1]
r = o << "x" << "y"
p r.equal?(o), o.string
o.rewind
p o.read
log(o, "m")
p o.string

x = [+"str", StringIO.new(+"io"), Sink.new]
x.each { |e| e << "+" }
p x[0], x[1].string, x[2].string
i = [3, StringIO.new][0]
p(i << 2)
os = [Sink.new, StringIO.new]
os.each { |e| log(e, "a"); log(e, "b") }
os.each { |e| p e.string }
