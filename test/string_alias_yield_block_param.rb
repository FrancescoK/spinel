# A second name for a String is the same object in CRuby, so an append
# through it shows through every name. Spinel appended to a copy when the
# String went through a yield or an iterator under a second name: a local
# yielded on as its alias (`z = x; yield z`), an alias handed to a method
# that yields it, and a block parameter appended to through a local that
# names it (`{ |x| t = x; t << y }`). Each probe appends LONG, which always
# reallocates.
# spinel: gc-minor
LONG = "!" * 100

def seen(s) = [s[0], s.size]
def grow(x) = (x << LONG; nil)
def run(v) = yield(v)

# an alias yielded, or handed to a method that yields it
def w1; x = +"a"; z = x; yield z; seen(x); end
p(w1 { |q| q << LONG })
def w2(x); z = x; yield z; seen(x); end
v2 = +"b"; p w2(v2) { |q| q << LONG }, seen(v2)
def w3; x = +"c"; y = x; z = y; yield z, 1; [seen(x), seen(y)]; end
p(w3 { |q, n| q.concat(LONG) })
def w4; x = +"d"; z = x; yield x; seen(z); end
p(w4 { |q| grow(q) })
x5 = +"e"; z5 = x5; run(z5) { |q| q << LONG }; p seen(x5)
x6 = +"f"; z6 = x6; run(z6) { |q| q.size }; p seen(x6)

# a block parameter appended to through a local that names it
[+"g"].each { |x| t = x; t << LONG; p seen(x) }
a8 = [+"h", +"i"]; a8.each { |x| t = x; t << LONG }; p a8.map(&:size)
a9 = [+"j"]; a9.each_with_index { |x, i| t = x; u = t; u.concat(LONG) }; p seen(a9[0])
a10 = [+"k"]; p a10.map { |x| t = x; t << LONG; x.size }, seen(a10[0])
a11 = [+"l"]; a11.each { |x| t = x; grow(t) }; p seen(a11[0])
a12 = [+"m"]; a12.each { |x| t = x; t << LONG; p x.equal?(t) }
s13 = +"n"; [s13].each { |x| t = x; t << LONG }; p seen(s13)
def it14 = yield(+"o")
it14 { |x| t = x; t << LONG; p seen(x) }
s15 = +"p"; run(s15) { |x| t = x; t << LONG }; p seen(s15)
pr16 = proc { |x| t = x; t << LONG }
s16 = +"q"; pr16.call(s16); p seen(s16)
a17 = [+"r"]; a17.each { |x| t = x; t = +"s"; t << LONG }; p seen(a17[0])

# the bytes survive, and a frozen String still raises
b18 = +"t\0u"; [b18].each { |x| t = x; t << LONG }; p b18.bytesize
def w19; x = "v".freeze; z = x; yield z; end
begin
  w19 { |q| q << LONG }
rescue FrozenError => e19
  p e19.class
end
begin
  ["w".freeze].each { |x| t = x; t << LONG }
rescue FrozenError => e20
  p e20.class
end
