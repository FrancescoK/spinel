# A nested target of a multiple assignment stores into an instance, global
# or class variable, an index or an attribute, and a nested splat and
# post-splat targets take their share, whether the value comes from a method
# or a literal.
class C
  def pair = [[1, 2], 3]

  def go
    (@a, @b), c = pair
    p [@a, @b, c]
    (@x, @y), z = [4, 5], 6
    p [@x, @y, z]
    q, (@m, *@r) = 7, [8, 9, 10]
    p [q, @m, @r]
  end
end
C.new.go

def pair = [[1, 2], 3]
($g, $h), k = pair
p [$g, $h, k]

arr = [0, 0]
(arr[0], arr[1]), k = pair
p arr

S = Struct.new(:u, :v)
s = S.new
(s.u, s.v), k = pair
p [s.u, s.v]

class D
  def self.go
    (@@a, @@b), k = [[1, 2], 3]
    p [@@a, @@b]
  end
end
D.go

h = {}
(h[:a], h[:b]), k = [["x", "y"], 3]
p h

(a, b, c), d = [1, 2], 3
p [a, b, c, d]
(e, *f), g = [1, 2, 3], 4
p [e, f, g]
(i, *j, l), m = [1, 2, 3, 4], 5
p [i, j, l, m]
(n, (o, q)), r = [1, [2, 3]], 4
p [n, o, q, r]
(t, u), w = 7, 8
p [t, u, w]

def trip = [1, 2, [3, [4, 5]]]
aa, *bb, (cc, (dd, $i)) = trip
p [aa, bb, cc, dd, $i]
ee, (ff, *$rest, @z) = 1, [2, 3, 4, 5]
p [ee, ff, $rest, @z]

def ints = [1, 2, 3]
(gg, hh), ii = ints
p [gg, hh, ii]
