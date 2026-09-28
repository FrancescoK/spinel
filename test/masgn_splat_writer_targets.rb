# A multiple assignment's splat into a constant, an instance or class
# variable, an attribute or an index takes the collected array, and an
# attribute target whose writer is a `def x=` calls it.

A, *B = [1, 2, 3]
p A, B
M, *N, O = "a", :b, 3.0, 4
p M, N, O

class K
  def initialize; @b = nil; end
  def run(r)
    a, *@b = 1, 2, 3
    p a, @b
    x, *@b, y = [4, 5, 6, 7]
    p x, @b, y
    q, *@b = r
    p q, @b
    v = (m, *@b = 8, 9)
    p v, m, @b
    *@b = 7
    p @b
  end
end
K.new.run([10, 11, 12])

class C
  @@c = nil
  def self.run(r)
    a, *@@c = 1, 2, 3
    p a, @@c
    *@@c, b = r
    p @@c, b
  end
end
C.run(["x", "y"])

class D
  @@v, z = [1], 2
  p @@v, z
end

class W
  attr_reader :v
  def initialize; @v = 0; @log = []; end
  def v=(n); @log << n; @v = n; end
  def log; @log; end
end
w = W.new
w.v, z = "str", 1
p w.v, z
def pair; [10, 20]; end
w.v, z = pair
p w.v
z, *w.v = 1, 2, 3
p w.v
r = (w.v, z = 7, 8)
w2 = W.new
w.v, *w2.v = 9
p r, w.v, w.log, w2.log

class H
  def initialize; @h = {}; end
  def []=(k, v); @h[k] = v; end
  def h; @h; end
end
h = H.new
h[:a], h[:b] = 1, 2
p h.h
v = (h[:m], h[:n] = 7, 8)
p v, h.h
a, *h[:d], h[:e] = [1, 2, 3, 4]
p h.h
hs = [H.new]
i = 0
hs[i][:x], hs[0][:y] = 5, 6
p hs[0].h
