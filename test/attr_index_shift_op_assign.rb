# `obj.attr <<= n` / `>>= n` and `a[i] <<= n` / `>>= n` take the shift checks
# of the local / ivar form: a runtime count goes through the range-checked
# helper (a negative count shifts the other way), and a boxed attribute
# shifts in the tag-dispatching operator. A bare C shift wrapped
# (`a[0] <<= 70` was 64, `obj.v <<= -1` was 0 under promote).
class Box
  attr_accessor :v
  def initialize(v); @v = v; end
end
b = Box.new(3)
b.v <<= 4
p b.v
b.v >>= 2
p b.v
k = -1
b.v <<= k
p b.v
k = 3
b.v <<= k
p b.v

nb = Box.new(nil)
begin
  nb.v <<= 1
rescue NoMethodError => e
  p e.class
end

a = [1, 2, 3]
a[1] <<= 4
a[2] >>= 1
n = 5
a[0] <<= n
m = -2
a[1] <<= m
p a
c = [8, 16]
d = 2
c[0] >>= d
c[1] >>= 1
p c

h = { a: 1, b: 64 }
h[:a] <<= 3
h[:b] >>= n
p h
