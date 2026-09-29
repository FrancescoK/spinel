# A multiple assignment from a value that is not an array: the first
# target takes the value itself, the rest nil.
def one = 7
def str = "s"
def nothing = nil
def hsh = {k: 1}
class Pt; def initialize(x) = @x = x; def inspect = "Pt(#{@x})"; end
def pt = Pt.new(3)
a, b = one
p a, b
c, d = str
p c, d
e, f = nothing
p e, f
g, h = hsh
p g, h
i, j = pt
p i, j
k, *l = one
p k, l
*m, n = str
p m, n
o, (q, r) = one
p o, q, r
v = (s, t = one)
p v, s, t
p((u, w = {}))
p u, w
class Holder
  def run
    @a, @b = {}
    $ga, $gb = 5.0.floor
    [@a, @b, $ga, $gb]
  end
end
p Holder.new.run
x1, y1 = {}
x1[:z] = 1
p x1, y1
def pair = [1, 2]
x2, y2 = pair
p x2, y2
def maybe(f) = f ? [1, 2] : 3
x3, y3 = maybe(true)
x4, y4 = maybe(false)
p x3, y3, x4, y4
a5, b5 = {}, 1
p a5, b5
e5, f5 = [{}]
p e5, f5
