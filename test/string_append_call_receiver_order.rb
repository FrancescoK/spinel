# A String append whose receiver is a call answering the String handle
# (`pick(b).buf << x`) runs that call once, before its arguments, as Ruby
# does. In statement position the receiver went into the C call beside the
# argument, so gcc ran the argument first; and every other place that named
# the receiver (a second link of a chain, an Integer's codepoint conversion,
# each part of an interpolation, the frozen check of a multi-argument concat)
# ran the call again.
class Box
  attr_reader :buf
  def initialize(s) = @buf = s
end

def pick(b) = (puts "recv"; b)
def arg(x) = (puts "arg #{x}"; x)
def num(n) = (puts "num #{n}"; n)

b = Box.new(+"s")
pick(b).buf << arg("a")
pick(b).buf.concat(arg("b"))
pick(b).buf.concat(arg("c"), arg("d"))
pick(b).buf << arg("e") << arg("f")
pick(b).buf << 33
pick(b).buf << num(64)
pick(b).buf << "#{arg("g")}h"
pick(b).buf << "i"
p b.buf

f = Box.new("frozen".freeze)
begin
  pick(f).buf.concat(arg("x"), arg("y"))
rescue FrozenError => e
  puts e.class
end
begin
  pick(f).buf << arg("z")
rescue FrozenError => e
  puts e.class
end
p f.buf
