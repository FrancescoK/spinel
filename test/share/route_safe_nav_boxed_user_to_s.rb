# A box that may hold an object with its own to_s: a method ending in
# `s&.to_s` dispatches to that to_s beside the String's handle. Each user
# to_s of the program answers a new String, so the method publishes the
# handle the box holds, or clears the side channel for the String a user
# to_s makes, and the answer is the String the caller changes (it was
# refused as a copy of it).
class Label
  def initialize(x) = @x = x
  def to_s = @x + "?"
end

class Own
  def to_s = +"own"
end

def conv(s) = s&.to_s

src = +"abc"
b = conv(src)
b << "1"
l = conv(Label.new("a"))
l << "!"
o = conv(Own.new)
o << "#"
p src, b, l, o, conv(nil), conv(5), conv(:q)
[src, Label.new("k"), nil, 3].each { |e| p conv(e) }
