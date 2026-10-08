# A builtin iterator's block parameter is the String its receiver holds:
# the element of an Array literal (`[x].each { |u| ... }`), or the receiver
# itself for then, tap and yield_self. CRuby's block appends to the
# caller's String, directly or by yielding it on to a block that does.
# Spinel made the elements handles only for an Array held in a local, and
# only when the block appended to its parameter itself, so the block grew a
# copy; an Array literal handed to a method whose block appends did not
# build. Appends are LONG, which always reallocates.
# spinel: gc-minor
LONG = "!" * 100

# yielded on to the method's own block
def r_each(x) = [x].each { |u| yield u }
s1 = +"a"; r_each(s1) { |w| w << LONG }; p s1.size
def r_ewi(x) = [x].each_with_index { |u, i| yield u, i }
s2 = +"b"; r_ewi(s2) { |w, i| w << LONG }; p s2.size
def r_map(x) = [x].map { |u| yield u }
s3 = +"c"; r_map(s3) { |w| w << LONG }; p s3.size
def r_sel(x) = [x].select { |u| yield u }
s4 = +"d"; r_sel(s4) { |w| w << LONG }; p s4.size
def r_then(x) = x.then { |u| yield u }
s5 = +"e"; r_then(s5) { |w| w << LONG }; p s5.size
def r_tap(x) = x.tap { |u| yield u }
s6 = +"f"; p(r_tap(s6) { |w| w << LONG }.size); p s6.size
def r_pos(x) = [x].each { |u| yield 1, u }
s7 = +"g"; r_pos(s7) { |i, w| w << LONG }; p s7.size
def r_two(x, y) = [x, y].each { |u| yield u }
s8 = +"h"; t8 = +"i"; r_two(s8, t8) { |w| w << LONG }; p [s8.size, t8.size]
def r_up(x) = [x].each { |u| yield u }
s9 = +"j"; r_up(s9) { |w| w.upcase! }; p s9

# appended to in the block itself
s10 = +"k"; [s10].each { |w| w << LONG }; p s10.size
def q_lit(x) = [x].each { |u| u.concat(LONG) }
s11 = +"l"; q_lit(s11); p s11.size
s12 = +"m"; s12.then { |w| w << LONG }; p s12.size
s13 = +"n"; s13.tap { |w| w << LONG }; p s13.size

# an Array literal argument to a method whose block appends
def a_each(a) = a.each { |u| u << LONG }
s14 = +"o"; a_each([s14]); p s14.size
def a_yield(a) = a.each { |u| yield u }
s15 = +"p"; a_yield([s15]) { |w| w << LONG }; p s15.size
