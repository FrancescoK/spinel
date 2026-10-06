# `recv&.a op= v`, `||=` and `&&=` do nothing and answer nil when recv is nil,
# evaluating it once. The op-write lowerings took the receiver as present:
# through a writer with a body (here a Class.new one) a nil receiver was
# called and the program segfaulted, and an accessor's read ran on nil.

class K
  attr_accessor :m
end
class W
  def m = @m || 0
  def m=(v)
    @m = v * 10
  end
end
def tk(o)
  o&.m += 3
  o&.m ||= 7
  o&.m &&= 1
  p o&.m
end
tk(nil)
k = K.new
k.m = 1
tk(k)
def tw(o)
  o&.m += 3
  o&.m ||= 7
  p o&.m
  x = (o&.m += 3)
  p x
end
tw(nil)
tw(W.new)
n = 0
def r(o, n) = o
r(nil, n += 1)&.m += 1
p n
w = Class.new { attr_reader :m; def m=(v); end }.new
w = nil
p(w&.m += 3)
