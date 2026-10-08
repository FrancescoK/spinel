# A second name for a String is the same object in CRuby, so an append
# through it shows through every name. Spinel shared a local and its alias
# only for `t = s`: a conditional that can hand over a local (`h = c ? x :
# g`, if/unless, `||`, `&&`, case, `h ||= g`) and a multiple assignment
# (`t, u = s, 1`, a swap) gave the new name a copy, and the swap of two
# shared Strings did not compile. Each probe appends LONG, which always
# reallocates.
# spinel: gc-minor
LONG = "!" * 100

def seen(s) = [s[0], s.size]
def grow(x) = (x << LONG; nil)
c = ARGV.size > 5
d = ARGV.size < 5

# each arm that is a local hands that String over
g1 = +"a"; h1 = (c ? +"z" : g1); h1 << LONG; p seen(g1)
g2 = +"b"; x2 = +"y"; h2 = c ? x2 : g2; h2 << LONG; p seen(g2), seen(x2)
g3 = +"c"; h3 = if c then +"z" else puts("arm"); g3 end; h3 << LONG; p seen(g3)
g4 = +"d"; h4 = unless c then g4 else +"z" end; h4.concat(LONG); p seen(g4)
g5 = +"e"; x5 = +"y"; h5 = d ? (c ? x5 : g5) : +"z"; h5 << LONG; p seen(g5), seen(x5)
g6 = +"f"; h6 = g6 || +"z"; h6 << LONG; p seen(g6)
o7 = ARGV.first; g7 = +"g"; h7 = o7 || g7; h7 << LONG; p seen(g7)
g8 = +"h"; h8 = (d && g8); h8 << LONG; p seen(g8)
g9 = +"i"; h9 = case ARGV.size when 7 then +"z" else g9 end; h9 << LONG; p seen(g9)
g10 = +"j"; h10 = case ARGV.size when 0 then g10 when 1 then +"z" end; h10 << LONG; p seen(g10)
g11 = +"k"; h11 = c ? +"z" : g11; p h11.equal?(g11); grow(h11); p seen(g11)
g12 = +"l"; p((h12 = c ? +"z" : g12).size); h12 << LONG; p seen(g12)
def m13(y, c) = (h = c ? +"z" : y; h << LONG; y.size)
v13 = +"m"; p m13(v13, false), seen(v13)
g21 = +"w"; h21 = nil; h21 ||= g21; h21 << LONG; p seen(g21)
g22 = +"x"; h22 = d ? (t22 = g22) : +"z"; h22 << LONG; p seen(g22), seen(t22)
g23 = +"y"; h23 = c ? +"z" : +g23; h23 << LONG; p seen(g23)

# a multiple assignment names each element's String
s14 = +"n"; t14, u14 = s14, 1; t14 << LONG; p seen(s14)
s15 = +"o"; t15, u15 = s15, s15; t15 << LONG; p seen(s15), seen(u15)
s16 = +"p"; t16, *r16 = s16, 1; grow(t16); p seen(s16), r16
a17 = +"q"; b17 = +"r"; a17, b17 = b17, a17; b17 << LONG; p seen(a17), seen(b17)
t18, u18 = +"s", 1; v18 = t18; v18 << LONG; p seen(t18)
s24 = +"z"; t24, u24 = +s24, 1; t24 << LONG; p seen(s24)

# the bytes survive, and a frozen String still raises
g19 = +"t\0u"; h19 = c ? +"z" : g19; h19 << LONG; p g19.bytesize
g20 = "v".freeze
begin
  h20 = c ? +"z" : g20; h20 << LONG
rescue FrozenError => e20
  p e20.class
end
