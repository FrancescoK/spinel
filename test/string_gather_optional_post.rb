# A String written ahead of a splat, into an optional parameter before the
# rest of a method that also has a required parameter after it (`def g(a =
# nil, *r, z)`): the arguments written outside the splat fill the required
# one, so the String's parameter is fixed however long the splat runs, but
# the binder lent that parameter a copy out of the gathered Array, and the
# method's append never reached the caller. Each method has one call, so
# no other call site changes how its parameter binds; each probe appends
# LONG, which always reallocates.
# spinel: gc-minor
LONG = "!" * 100

def seen(s) = [s[0], s.size]
e = []
f = [7]

def g1(a = nil, *r, z) = (a << LONG if a.is_a?(String); [r, z])
s1 = +"a"; p g1(s1, *[], 1), seen(s1)
def g2(a = nil, *r, z) = (a << LONG if a.is_a?(String); [r, z])
s2 = +"b"; p g2(s2, *e, 2), seen(s2)
def g3(a = nil, *r, z) = (a.concat(LONG) if a.is_a?(String); [r, z])
s3 = +"c"; p g3(s3, *f, 3), seen(s3)
def g4(a, b = 1, *r, z) = (b << LONG if b.is_a?(String); [a, r, z])
s4 = +"d"; p g4(0, s4, *e, 4), seen(s4)
def g5(a = 1, *r, y, z) = (a << LONG if a.is_a?(String); [r, y, z])
s5 = +"e"; p g5(s5, *f, 5, 6), seen(s5)

# the shared String read before a later argument rebinds the variable
def g6(a = nil, *r, z) = (a << LONG if a.is_a?(String); z)
s6 = +"F"; o6 = s6; o6 << ""; p g6(s6, *e, (s6 = +"f"; 9)), seen(s6), seen(o6)

# the bytes survive, and a frozen String still raises
def g7(a = nil, *r, z) = (a << LONG if a.is_a?(String); z)
s7 = +"g\0h"; g7(s7, *e, 7); p s7.bytesize
def g8(a = nil, *r, z) = (a << LONG if a.is_a?(String); z)
begin
  g8("i".freeze, *e, 8)
rescue FrozenError => x8
  p x8.class
end
