# An index or attribute target of a multiple assignment widens its
# container's key and element types, or the attribute's slot, as the
# single store does.

def cnt; [1, 1]; end
h = {}
h[cnt[0]], h[:k] = 1, "x"
p h

def pair = [1, "x"]
b = [0, 0, 0]
b[0], b[2] = pair
p b

a = [0, 0, 0]
a[0], a[2] = 1, "x"
p a

def two = [3, :t]
s = {}
s["a"], s[2] = two
p s

class O
  attr_accessor :x, :y
  def initialize; @x = 0; @y = 0; end
end
o = O.new
o.x, o.y = 1, "s"
p o.x, o.y

class K
  def initialize; @h = {}; @a = [0, 0]; end
  def fill
    @h[1], @h[:k] = 2, "v"
    @a[0], @a[1] = 1.5, :s
    [@h, @a]
  end
end
p K.new.fill

class P
  @@t = {}
  def self.go
    @@t[:a], @@t[1] = 1, "one"
    @@t
  end
end
p P.go

hh = {}
[1, 2].each { |i| hh[i], hh[:"k#{i}"] = i.to_s, i }
p hh

r = [0, 0, 0, 0]
r[0], *mid, r[3] = 1, 2, 3, "z"
p r, mid

def trip = [1, "two", :three]
g = [0, 0, 0]
g[0], *rest, g[2] = trip
p g, rest

c = [0, 0]
c[0], c[1] = 7
p c
