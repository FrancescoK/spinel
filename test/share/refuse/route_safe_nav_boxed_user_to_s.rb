# spinel: not-cruby
# A box that may hold an object with its own to_s: a method ending in
# `s&.to_s` dispatches to that to_s beside the String's handle, which the
# return route does not publish, so the answer would be a copy of the
# String the caller changes.
class Label
  def initialize(x) = @x = x
  def to_s = @x + "?"
end
puts Label.new("a").to_s
def conv(s) = s&.to_s
src = +"abc"
b = conv(src)
b << "1"
p src, conv(nil)
