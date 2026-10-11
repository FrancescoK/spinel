require "strscan"

# A user class's attr_accessor :pos beside StringScanner#pos=, both reached
# through one boxed receiver.
class Cursor
  attr_accessor :pos
end

def assign(o, v) = (o.pos = v)

def assign_stmt(o, v)
  o.pos = v
  nil
end

def via_send(o, v) = o.public_send(:pos=, v)

c = Cursor.new
s = StringScanner.new("abcdef")
p assign(c, 1), assign(s, 2)
p [c.pos, s.pos]
assign_stmt(c, 3)
assign_stmt(s, 4)
p [c.pos, s.pos]
w = [5, "x"].first
p via_send(c, w), via_send(s, w)
p [c.pos, s.pos]
[c, s].each { |o| o.pos, _ = 1, 9 }
p [c.pos, s.pos]
p s.scan(/\w/)
