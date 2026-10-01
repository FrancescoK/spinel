# A block that yields its parameter on to the block of the method it is
# written in (`def run2(x) = run(x) { |u| yield u }`) hands that block the
# caller's String in CRuby. With both methods inlined, Spinel bound the
# inner block's parameter, and the inner method's own parameter, as copies,
# since neither is appended to where it is bound: the appending block one
# level out grew a copy. Each probe appends LONG, which always reallocates.

LONG = "!" * 100

def run(x) = yield(x)
def run2(x) = run(x) { |u| yield u }
s = +"a"; run2(s) { |w| w << LONG }; p s.size
s = +"b"; run2(s) { |w| w.upcase! }; p s
s = +"c"; run2(s) { |w| w.size }; p s.size

# two values, handed on in another order; a later read in the block; an
# append before the hand-on; the &block called by name; a value after
def two(x, y) = yield(x, y)
def two2(x, y) = two(x, y) { |a, b| yield b, a }
s = +"d"; t = +"e"; two2(s, t) { |p1, p2| p2 << LONG }; p [s.size, t.size]
def runr(x) = run(x) { |u| yield u; u.size }
s = +"f"; p runr(s) { |w| w << LONG }; p s.size
def run4(x) = run(x) { |u| u << "-"; yield u }
s = +"g"; run4(s) { |w| w << LONG }; p s.size
def runb(x, &b) = run(x) { |u| b.call(u) }
s = +"h"; runb(s) { |w| w << LONG }; p s.size
def rund(x) = run(x) { |u| yield(u, 1) }
s = +"i"; rund(s) { |w, i| w << LONG }; p s.size

# instance methods, and a String a closure also holds
class K
  def each_buf(b) = yield(b)
  def wrap(b) = each_buf(b) { |q| yield q }
end
s = +"j"; K.new.wrap(s) { |w| w << LONG }; p s.size
s = +"k"; f = -> { s }; run2(s) { |w| w << LONG }; p f.call.size

# the bytes survive, and a frozen String still raises
s = +"l\0m"; run2(s) { |w| w << LONG }; p s.bytesize
begin
  run2("n".freeze) { |w| w << LONG }
rescue FrozenError => e
  p e.class
end
