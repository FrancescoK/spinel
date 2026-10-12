# --share-strings: a String Range's #min and #max answer its endpoint
# Strings themselves, as CRuby's range_min and range_max do: #min the
# begin, #max an inclusive Range's end. They answered a copy of the
# endpoint's bytes, so every route that hands one on to another name (a
# write, an argument, an Array or Hash element, an attribute, a global)
# was refused once the endpoint was changed in place (#6765). An excluded
# end's #max walks the members and answers a new String; an empty Range
# answers nil; a frozen literal endpoint stays the literal.
# spinel: gc-stress

s = String.new("a")
e = String.new("c")
r = s..e

# a variable's write, changed through it
lo = r.min
hi = r.max
lo << "1"
hi << "2"
p r, lo.equal?(s), hi.equal?(e)

# Array and Hash elements, held and changed through the container
a = [r.min, r.max]
a[0] << "3"
h = {lo: r.min, hi: r.max}
h[:hi] << "4"
b = []
b << r.min
b.push(r.max)
b[1] << "5"
p r, a, h, b

# a method's argument, an attribute, a global
def bump(v) = v << "!"
bump(r.min)
bump(r.max)
class Box
  attr_accessor :v
end
bx = Box.new
bx.v = r.min
bx.v << "6"
$g = r.max
$g << "7"
p r

# a later change to the endpoint shows through the answer
t = r.min
s << "8"
p t

# an excluded end: #min is the begin, #max a new String
x = (+"ab")...(+"ad")
xl = x.min
xh = x.max
xl << "?"
xh << "!"
p x, xl, xh

# empty, and a frozen literal's endpoints
z = (+"z")..(+"a")
p z.min, z.max
lit = "k".."m"
p lit.min.frozen?, lit.max.equal?(lit.end)

# #min walks nothing: nil where the begin is past the end by <=>, or at an
# excluded end; else the begin itself, an endless Range's too
def ends(b, e, excl)
  s = String.new(b)
  f = String.new(e)
  r = excl ? (s...f) : (s..f)
  lo = r.min
  hi = r.max
  s << "x"
  f << "y"
  p [lo, hi, lo.equal?(s), hi.equal?(f)]
end
ends("9", "11", true)
ends("9", "11", false)
ends("10", "9", false)
ends("1", "10", true)
ends("c", "c", true)
ends("c", "c", false)
ends("y", "zz", true)
ends("a", "ab", true)
u = String.new("p")
m = (u..).min
u << "!"
p m, m.equal?(u)
