# String#scrub! replaces the invalid bytes in the receiver itself: a later
# read of the variable, an alias, a container holding it and an ivar all see
# the scrubbed text, and the call answers the receiver.

s = +"a\xffc"
s.scrub!("?")
p s

d = +"a\xffc"
d.scrub!
p d.bytes

h = +"x\xffy"; o = h; o << ""
h.scrub!("!")
p h, o

a = +"m\xffn"; arr = [a]
a.scrub!("-")
p arr

class Holder
  attr_reader :s
  def initialize = (@s = +"q\xffr")
  def go = (@s.scrub!("#"); @s)
end
k = Holder.new
t = k.s
p k.go, t
k2 = Holder.new
k2.s.scrub!("*")
p k2.s

r = +"ok"; r2 = r
p r.scrub!.equal?(r), r2

x = +"\xff\xfe"
y = x.scrub!("")
p x, y

f = "fine".freeze
p f.scrub!
g = "a\xffb".freeze
p((g.scrub! rescue $!.class))
