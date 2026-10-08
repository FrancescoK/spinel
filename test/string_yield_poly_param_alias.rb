# A method parameter that another call site makes boxed (`w(nil)`, `w(1)`)
# and that the method yields, directly or through a local written from it
# (`z = x; yield z`), into a block that appends: CRuby appends to the
# caller's String. Spinel followed the boxed parameter only by its own name
# and only into a proc passed with `&`, so a literal block, or the alias,
# appended to a boxed copy, and a String written in the call was boxed as a
# copy too. Each method has its own probes; each probe appends LONG, which
# always reallocates.
# spinel: gc-minor
LONG = "!" * 100

def seen(s) = [s[0], s.size]

def w1(x); z = x; yield z; x; end
w1(nil) { |q| q }
s1 = +"a"; p seen(w1(s1) { |q| q << LONG }), seen(s1)

def w2(x); z = x; u = z; yield u; x; end
w2(1) { |q| q }
s2 = +"b"; p seen(w2(s2) { |q| t = q; t.concat(LONG) }), seen(s2)

def w3(x); z = x; z = +"o" if ARGV.size > 9; yield z; x; end
w3(nil) { |q| q }
s3 = +"c"; p seen(w3(s3) { |q| q << LONG }), seen(s3)

def w4(x); yield x; x; end
w4(1) { |q| q }
s4 = +"d"; p seen(w4(s4) { |q| q << LONG }), seen(s4)
p seen(w4(+"e") { |q| q << LONG })

def w5(x, y); z = y; yield z; y; end
w5(1, nil) { |q| q }
s5 = +"f"; p seen(w5(1, s5) { |q| q << LONG }), seen(s5)

class K
  def w(x); z = x; yield z; x; end
end
K.new.w(nil) { |q| q }
s6 = +"g"; p seen(K.new.w(s6) { |q| q << LONG }), seen(s6)

def w7(x); z = x; yield z; x; end
pr7 = proc { |q| q << LONG }
w7(nil) { |q| q }
s7 = +"h"; p seen(w7(s7, &pr7)), seen(s7)

# a block that only reads, the bytes, and a frozen String still raises
def w8(x); z = x; yield z; x; end
w8(nil) { |q| q }
s8 = +"i"; p seen(w8(s8) { |q| q.size }), seen(s8)
s9 = +"j\0k"; w1(s9) { |q| q << LONG }; p s9.bytesize
begin
  w1("l".freeze) { |q| q << LONG }
rescue FrozenError => e
  p e.class
end
