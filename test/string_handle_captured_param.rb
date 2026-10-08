# A String parameter a proc captures is the caller's String. A proc that can
# outlive the call holds the parameter in a heap cell, so the caller cannot
# lend it its slot, and the method's whole name group kept the value ABI: a
# `super` handing the parameter on, a call handing it to an appending method
# and the method's own appends all grew a copy, and the parent that shares
# the name appended to a copy too. The group takes the shared handle instead
# (#6179). Each probe appends LONG, which always reallocates, and prints what
# the caller's name sees.
# spinel: gc-minor
LONG = "!" * 100

def seen(s) = [s[0], s.size]

class Par
  def m(s) = (s << LONG; nil)
  def kw(s, k: 1) = (s << LONG; k)
  def two(a, b) = (b << LONG; a.size)
end
module Mod
  def mm(s) = (s << LONG; nil)
end
class Chi < Par
  include Mod
  # a bare super, super(s), a keyword beside it, a later position, and into
  # an included module's copy
  def m(s) = (f = -> { s.size }; super; [s.size, f.call])
  def kw(s, k: 1) = (f = proc { s.size }; super(s, k: 2); [s.size, f.call])
  def two(a, b) = (f = -> { b.size }; super; [b.size, f.call])
  def mm(s) = (f = -> { s.size }; super; [s.size, f.call])
end
c = Chi.new
s = +"A"; p c.m(s), seen(s)
s = +"B"; p c.kw(s), seen(s)
s = +"C"; t = +"c"; p c.two(t, s), seen(s), seen(t)
s = +"D"; p c.mm(s), seen(s)

# the parent reached on its own, and through a poly receiver over the group
s = +"E"; Par.new.m(s); p seen(s)
[Chi.new, Par.new].each { |o| v = +"F"; o.m(v); p seen(v) }

# no super: the captured parameter handed to an appending method, appended
# to by the method, and by the proc after the call returned
class Own
  def via(s) = (f = -> { s.size }; grow(s); [s.size, f.call])
  def grow(s) = s << LONG
  def keep(s) = (@f = -> { s << LONG; s.size }; s << "?"; nil)
  def later = @f.call
end
o = Own.new
s = +"G"; p o.via(s), seen(s)
s = +"H"; o.keep(s); p seen(s); p o.later, seen(s)

# procs that outlive the calls, each holding its caller's String while the
# collector runs
KEPT = []
class Keeper < Par
  def m(s) = (KEPT << -> { s.size }; super)
end
bufs = []
i = 0
while i < 8
  b = +"k#{i}"
  Keeper.new.m(b)
  bufs << b
  junk = Array.new(50) { |j| "j#{j}" * 20 }
  i += 1
end
p bufs.map(&:size).uniq, KEPT.map(&:call).uniq, bufs[5][0, 3]
