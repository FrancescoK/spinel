# --share-strings: a String Range's endpoint handed to a yield
# (`yield(r.begin)`, `yield(r.last)`, `yield(r.min)`) is the String the
# Range keeps, as in CRuby, so a block that changes it changes the
# endpoint, and one that keeps it sees a later change. The yield bound the
# block's parameter to a copy of the endpoint's bytes, so such a program
# was refused once the endpoint was changed in place (#6765). Covered: a
# spliced block, a recursive method's, a proc, a lambda and a symbol's
# block, a block parameter of no static class, several arguments, and an
# argument that runs before a later one changes the endpoint.
# spinel: gc-stress

def y1(r) = yield(r.begin)
f = (+"a").."c"
y1(f) { |x| p x }
b = f.begin
b << "z"
p b, f

# the block changes the endpoint, or keeps it
y1(f) { |x| x << "q" }
k = nil
y1(f) { |x| k = x }
f.begin << "y"
p f, k, k.equal?(f.begin)

# several arguments, the end and min / max
def two(r) = yield(r.first, r.last)
e = +"e"
g = (+"b")..e
two(g) { |x, z| x << "2"; z << "3" }
def ext(r) = yield(r.min, r.max)
ext(g) { |lo, hi| lo << "4"; hi << "5" }
p g, e

# a recursive method's block, a proc, a lambda, a symbol
def rec(r, n, &blk)
  return yield(r.begin) if n == 0
  rec(r, n - 1, &blk)
end
rec(f, 2) { |x| x << "1" }
pr = proc { |x| x << "P" }
y1(f, &pr)
y1(f, &->(x) { x << "L" })
h = (+"m")..(+"n")
y1(h, &:upcase!)
p f, h

# a block parameter of no static class
def ys(r, k) = k ? yield(r.begin) : yield(1)
ys(f, true) { |v| v << "x" if v.is_a?(String) }
ys(f, false) { |v| p v }
kept = nil
ys(f, true) { |v| kept = v }
f.begin << "w"
p f, kept

# an argument that runs before a later one changes the endpoint
def bump(r) = (r.begin << "!"; 1)
def yb(r) = yield(r.begin, bump(r))
yb(f) { |v, n| v << "v" }
def yp(r, k) = k ? yield(r.begin, bump(r)) : yield(3, 4)
yp(f, true) { |v, n| v << "p" if v.is_a?(String) }
yp(f, false) { |v, n| p v }
p f

# an Enumerable class whose each yields a kept Range's endpoints
class W
  include Enumerable
  def initialize(r) = @r = r
  def each
    yield @r.begin
    yield @r.end
  end
end
w = W.new(g)
w.each { |x| x << "!" }
p g, w.map(&:upcase)
