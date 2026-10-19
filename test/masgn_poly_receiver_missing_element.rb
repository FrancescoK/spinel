# spinel: gc-stress
# A multiple assignment from an Array shorter than its targets leaves nil in
# the targets past the end when the receiver is a boxed value, as it does for
# a receiver of a known class: the writer the box dispatches to is handed the
# nil, an attribute's, a user writer's that stores what it is given and one
# that tells nil apart, for an Integer and a Float Array, a splat, a
# post-splat target and a boxed Array's index.
class K
  attr_accessor :x, :y
end

class W
  attr_reader :a, :b
  def a=(v); @a = v; end
  def b=(v); @b = v; end
end

class Z
  attr_reader :a, :b
  def a=(v); @a = v.nil? ? :none : v; end
  def b=(v); @b = v.nil? ? :none : v; end
end

def short = [4]

v = [6]
f = [2.5]

o = [K.new, 1][0]
o.x, o.y = v
p [o.x, o.y]

o = [K.new, 1][0]
o.x, o.y = f
p [o.x, o.y]

o = [K.new, 1][0]
o.x, o.y = [6]
p [o.x, o.y]

o = [K.new, 1][0]
o.x, o.y = short
p [o.x, o.y]

o = [K.new, 1][0]
o.x, *r, o.y = v
p [o.x, o.y, r]

o = [K.new, 1][0]
o.x, o.y = 1, *v
p [o.x, o.y]

o = [K.new, 1][0]
o.x, o.y = v + [7]
p [o.x, o.y]

o = [K.new, 1][0]
o.x, o.y = []
p [o.x, o.y]

w = [W.new, 1][0]
w.a, w.b = v
p [w.a, w.b]

z = [Z.new, 1][0]
z.a, z.b = v
p [z.a, z.b]

z = [Z.new, 1][0]
z.a, z.b = f
p [z.a, z.b]

a = [[0, 0], 1][0]
a[0], a[1] = v
p a
