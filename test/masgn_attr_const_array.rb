# A multiple assignment from an Array shorter than its targets leaves nil in
# the targets past the end, an attribute's or a user writer's among them: a
# constant Array and a local one, a literal, a splat and a method's Array all
# give nil there, not the type's zero.
ONE = [6]
TWO = [1.5, 2.5]

class O
  attr_accessor :x, :y, :z
end

class D
  def x=(v); @x = v; end
  def y=(v); @y = v; end
  def x; @x; end
  def y; @y; end
end

class I
  def initialize; @h = {}; end
  def []=(k, v); @h[k] = v; end
  def [](k); @h[k]; end
end

def one = [6]

o = O.new
o.x, o.y = ONE
p [o.x, o.y]

a = [6]
o = O.new
o.x, o.y = a
p [o.x, o.y]

o = O.new
o.x, o.y = [7]
p [o.x, o.y]

o = O.new
o.x, o.y = *a
p [o.x, o.y]

o = O.new
o.x, o.y = one
p [o.x, o.y]

o = O.new
o.x, o.y, o.z = TWO
p [o.x, o.y, o.z]

o = O.new
o.x, *r, o.y = ONE
p [o.x, o.y, r]

o = O.new
*r, o.x, o.y, o.z = a + [4]
p [o.x, o.y, o.z, r]

d = D.new
d.x, d.y = ONE
p [d.x, d.y]

d = D.new
d.x, *r, d.y = ONE
p [d.x, d.y, r]

h = { a: 1, b: 2 }
h[:a], h[:b] = ONE
p h

i = I.new
i[0], i[1] = ONE
p [i[0], i[1]]

e = [1, 2]
e[0], e[1] = ONE
p e

# a writer that keeps its value in a Hash stores the nil, not 0.0 or a TypeError
FL = [1.5]

class UI
  def initialize; @h = {}; end
  def []=(k, v); @h[k] = v; end
  def vals = @h
end

class UJ
  def initialize; @h = {}; end
  def y=(v); @h[:y] = v; end
  def z=(v); @h["z"] = v; end
  def vals = @h
end

u = UI.new
u[0], u[1] = FL
p u.vals

j = UJ.new
j.y, j.z = FL
p j.vals

j = UJ.new
j.y, j.z = [1.5, 2.5]
p j.vals

# the same stores without a multiple assignment: a Float or an Integer value
# that can be nil into a Hash that also holds a String
class WF
  def initialize; @h = { 0 => "s" }; end
  def []=(k, v); @h[k] = v; end
  def vals = @h
end

class WI
  def initialize; @h = { 0 => "s" }; end
  def []=(k, v); @h[k] = v; end
  def vals = @h
end

wf = WF.new
wf[1] = 2.5
wf[2] = nil
p wf.vals

wi = WI.new
wi[1] = 3
wi[2] = nil
p wi.vals

# ... and as the value of the store
class WV
  def initialize; @h = { a: "s" }; end
  def put(v)
    x = (@h[:b] = v)
    x
  end
  def vals = @h
end

wv = WV.new
p wv.put(1.5)
p wv.put(nil)
p wv.vals

class WW
  def initialize; @h = { a: "s" }; end
  def put(v)
    x = (@h[:b] = v)
    x
  end
  def vals = @h
end

ww = WW.new
p ww.put(4)
p ww.put(nil)
p ww.vals

# a writer after a splat, fed from a constant Array shorter than the targets
PAIR = [1, 2]

class F
  def x=(v); @x = v; end
  def y=(v); @y = v; end
  def z=(v); @z = v; end
  def vals = [@x, @y, @z]
end

f = F.new
f.x, *r, f.y, f.z = PAIR
p [f.vals, r]

f = F.new
*r, f.y, f.z = ONE
p [f.vals, r]

f = F.new
f.x, *r, f.y, f.z = [1, 2, 3, 4]
p [f.vals, r]
