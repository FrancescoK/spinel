# A second name for a String is the same object in CRuby, so an append
# through any name shows through all of them. Spinel shares a local and its
# alias only when one of the two is appended to directly: a chain of
# aliases (`t = s; u = t; u << x`), a method parameter as the source
# (`t = y; t << x`), a chained assignment (`u = t = s`) and an alias handed
# to an appending method (`t = s; grow(t)`) left the first name with its
# old bytes. Each probe appends LONG, which always reallocates.
# spinel: gc-minor
LONG = "!" * 100

def seen(s) = [s[0], s.size]
def grow(x) = (x << LONG; nil)

# a chain of locals, appended at its end or handed on from its end
s = +"a"; t = s; u = t; u << LONG; p seen(s), seen(t)
s = +"b"; t = s; u = t; w = u; w.concat(LONG); p seen(s)
s = +"c"; t = s; grow(t); p seen(s)
s = +"d"; t = s; u = t; grow(u); p seen(s), seen(t)
s = +"e"; u = t = s; u << LONG; p seen(s), seen(t)
s = +"f"; t = (s << "g"); u = t; u << LONG; p seen(s)

# the method's own parameter as the source: a literal, a local, through
# method(:m) and send, a default, a keyword, a class's method
def m(y) = (t = y; t << LONG; seen(y))
p m(+"h")
v = +"i"; p m(v), seen(v)
v = +"j"; p method(:m).call(v), seen(v)
v = +"k"; p send(:m, v), seen(v)
def md(y = +"l") = (t = y; u = t; u << LONG; y.size)
p md
v = +"m"; p md(v), seen(v)
def mk(k:) = (t = k; t << LONG; k.size)
v = +"n"; p mk(k: v), seen(v)
def mh(y) = (t = y; grow(t); y)
p seen(mh(+"o"))
def mp(y) = (t = y; u = t; mh(u); nil)
v = +"p"; mp(v); p seen(v)
class Buf
  def add(y) = (t = y; t << LONG; nil)
end
v = +"q"; Buf.new.add(v); p seen(v)

# the bytes survive: a NUL, and a frozen String still raises
b = +"r\0s"; t = b; u = t; u << LONG; p b.bytesize
begin
  m("t".freeze)
rescue FrozenError => e
  p e.class
end

# a shared name that a later argument rebinds is still the String read
# first, packed into a rest or gathered around a splat
def rest(*r) = (r[0] << LONG; [seen(r[0]), r[1]])
def gath(a, b, *r, z) = (a << LONG; [seen(a), z])
xs = [+"y", +"w"]
s = +"T"; o = s; o << ""; p rest(s, (s = +"u"; 9)), seen(s), seen(o)
s = +"V"; o = s; o << ""; p gath(s, *xs, (s = +"v"; 9)), seen(s)
