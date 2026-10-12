# A String Range's endpoint handed on as an argument is the endpoint
# String itself, as in CRuby: two reads of `f.begin` among one call's
# arguments are one String where the arguments run ahead of the call,
# into a Struct's members, boxed ones too, and so are #min and #max. Built
# --share-strings, each read ran into a new String. Covered: begin / end /
# min / max, a member of no static class, a Range that is no variable's, one
# a later argument replaces, a method's and a keyword's parameters, and a
# yield.
# spinel: gc-stress
S = Struct.new(:a, :b)
f = (+"a").."c"
st = S.new(f.begin, f.begin)
p st.a.equal?(st.b)
st = S.new(f.begin, f.end)
p st.a.equal?(f.begin), st.b.equal?(f.end)
st = S.new(f.min, f.min)
p st.a.equal?(st.b)
g = (+"a")..(+"c")
st = S.new(g.max, g.end)
p st.a.equal?(st.b)

# members of no static class
B = Struct.new(:a, :b)
bx = B.new(f.begin, f.begin)
B.new(1, 2)
p bx.a.equal?(bx.b), bx.a.equal?(f.begin)
bm = B.new(f.min, 3)
p bm.a.equal?(f.begin)

# a Range that is no variable's, and one a later argument replaces
$r = (+"q").."z"
def mk = $r
st = S.new(mk.begin, mk.begin)
p st.a.equal?(st.b)
h = (+"x").."z"
old = h
st = S.new(h.begin, (h = (+"m").."n").begin)
p st.a, st.b, st.a.equal?(old.begin)

# a method's and a keyword's parameters, and a yield
def same(a, b) = a.equal?(b)
n = 0
p same((n += 1; f.begin), (n += 1; f.begin))
def kw(a:, b:) = a.equal?(b)
p kw(b: f.begin, a: (n += 1; f.begin))
def y2(r) = yield(r.begin, r.begin)
y2(f) { |x, y| p x.equal?(y) }
