# A String that is the shared handle (an appending proc takes it too, so
# the variable holds the one sp_String) reaches a spliced block as the
# handle through a `yield` since #6444, but not through the other ways a
# spliced block is called: a `blk.call` on the method's own &block, a
# keyword yield, or a block yielding its parameter on to the block one
# level out (#6473). Each appended to a copy of the caller's String. Each
# probe appends LONG, which always reallocates, and has its own variable.
# spinel: gc-minor
LONG = "!" * 100
SH = proc { |x| x << "" }
KW = proc { |k:| k << "" }
def seen(s) = [s[0], s.size]

def run(x) = yield(x)
def run2(x) = run(x) { |u| yield u }
def bc(x, &b) = b.call(x)
def bc2(x, &b) = run(x) { |u| b.call(u) }
def yk(x) = yield(k: x)
def yk2(x) = run(x) { |u| yield(k: u) }
def bk(x, &b) = b.call(k: x)
def two(x, y) = yield(x, y)
def two2(x, y) = two(x, y) { |a, b| yield b, a }

a = +"a"; SH.call(a); run2(a) { |w| w << LONG }; p seen(a)
b = +"b"; SH.call(b); run2(b) { |w| w.upcase! }; p b
c = +"c"; SH.call(c); bc(c) { |w| w << LONG }; p seen(c)
d = +"d"; SH.call(d); bc2(d) { |w| w << LONG }; p seen(d)
e = +"e"; KW.call(k: e); yk(e) { |k:| k << LONG }; p seen(e)
f = +"f"; KW.call(k: f); yk(f) { |k:| k.upcase! }; p f
g = +"g"; SH.call(g); yk2(g) { |k:| k << LONG }; p seen(g)
h = +"h"; KW.call(k: h); bk(h) { |k:| k << LONG }; p seen(h)
i = +"i"; j = +"j"; SH.call(j); two2(i, j) { |p1, p2| p2 << LONG }; p seen(i), seen(j)
l = +"l"; SH.call(l); run2(l) { |w| w.size }; p seen(l)
class K
  def each_buf(b) = yield(b)
  def wrap(b) = each_buf(b) { |q| yield q }
end
m = +"m"; SH.call(m); K.new.wrap(m) { |w| w << LONG }; p seen(m)
n = +"n\0o"; SH.call(n); run2(n) { |w| w << LONG }; p n.bytesize
# and a variable that is no handle, through a keyword yielded on
def yk3(x) = run(x) { |u| yield(k: u) }
o = +"o"; yk3(o) { |k:| k << LONG }; p seen(o)

# a later value of the same yield rebinds the variable: the block gets the
# String the variable held when its value ran, by position and by keyword
def yr
  s = +"r"
  SH.call(s)
  yield(s, (s = +"new"; 1))
  s
end
q1 = nil; p yr { |w, _| q1 = w; w << LONG }, seen(q1)
def ykr
  s = +"k"
  KW.call(k: s)
  yield(k: s, j: (s = +"new"; 1))
  s
end
q2 = nil; p ykr { |k:, j:| q2 = k; k << LONG }, seen(q2)
