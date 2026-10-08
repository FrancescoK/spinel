# A String a proc, a lambda or a Method appends to is the caller's String
# (#6179): the caller's variable becomes the shared handle when a target the
# call can reach appends to the parameter it binds, and the call boxes the
# handle, which the target's parameter reads. Each append is 100 bytes, so it
# always outgrows the buffer and a copy could not pass by capacity.
# spinel: gc-minor
X = "x" * 100
KEEP = []

# proc and lambda: .call, .(), [], ===, .yield, a literal receiver
s = +"a"; f = proc { |t| t << X; nil }
f.call(s); f.(s); f[s]; f === s; f.yield(s)
l = ->(t) { t.concat(X); nil }; l.call(s)
proc { |t| t.insert(0, X) }.call(s)
p s.size

# a block kept as &blk and called later; a method handing its parameter on
class H
  def on(&b) = (@b = b; nil)
  def fire(x) = (@b.call(x); nil)
end
h = H.new; h.on { |t| t << X }; s = +"b"; h.fire(s); p s.size
def via(v, g) = g.call(v)
s = +"c"; via(s, l); p s.size

# method(:m) / obj.method(:m) / public_method, to_proc, a kept &method(:m)
def app(t) = (t << X; nil)
class K
  def app2(t) = (t << X; t.size)
end
s = +"d"; m = method(:app); m.call(s); m.(s); m[s]; method(:app).to_proc.call(s)
p s.size
s = +"e"; p K.new.method(:app2).call(s), K.new.public_method(:app2).call(s), s.size
h2 = H.new; h2.on(&method(:app)); s = +"f"; h2.fire(s); p s.size
s = +"g"; app(s); p s.size   # a direct call into a method a Method names
def grow(b) = (b << X; nil)   # a lent slot beside a proc call takes the handle
s = +"m"; grow(s); f.call(s); p s.size

# a splat of an Array literal or of a local holding one, and argument order
s = +"h"; e = [2]; ->(t, u) { t << X }.call(*[s], *e); p s.size
s = +"l"; a = [s, 2]; ->(t, u) { t << X }.call(*a); p s.size, a[0].size
s = +"i"; s0 = s; ->(t, u) { t << X }.call(s, (s = +"j"; 1)); p s0.size, s.size

# a proc handing its String on to a method that appends: through an ivar
# receiver, a local object, a class constant, past a splat and beside a
# keyword; and a single-element Array local splatted into a proc
class Log
  def write(buf) = (buf << X; nil)
  def self.cwrite(buf) = (buf << X; nil)
end
class Holder
  def initialize = (@log = Log.new)
  def fn = ->(t) { @log.write(t) }
end
s = +"n"; Holder.new.fn.call(s); p s.size
lg = Log.new; s = +"o"; ->(t) { lg.write(t) }.call(s); p s.size
s = +"p"; ->(t) { Log.cwrite(t) }.call(s); p s.size
def wr(a, b, buf) = (buf << X; nil)
def wk(buf, n: 0) = (buf << X; nil)
s = +"q"; ->(t) { wr(*[1, 2], t) }.call(s); ->(t) { wk(t, n: 1) }.call(s); p s.size
s = +"r"; a1 = [s]; proc { |t| t << X }.call(*a1); p s.size, a1[0].size

# a reading proc and a storing one see the bytes, never freed memory
s = +"k"; keep = proc { |t| KEEP << t.upcase; KEEP << t; t.size }
f.call(s); keep.call(s)
20.times { s << X }
GC.start
p KEEP[0], KEEP[1][0, 2], s.size

# a literal or a temporary goes over as a String nobody else holds, and
# outgrows its first buffer through insert, prepend and replace as well
p m.call(+"ab"), f.call("tmp".dup), K.new.method(:app2).call(+"cd")
def ins(t) = (t.insert(0, X); t.prepend("<"); t.replace(t + ">"); t.size)
p method(:ins).call(+"ab"), method(:ins).call("cd".dup)

# a block parameter a proc in the body captures: the block is wrapped in a
# lambda called at once (desugar_block_capture_wrap), whose parameter is the
# block's String; a frozen one raises, an unfrozen one is changed, in the
# block and in the Array it came from, by an append that outgrows it too
["", "Hello", "hello"].each do |a|
  a.freeze
  begin; -> { a.capitalize! }.call; p :changed; rescue FrozenError => ex; p ex.class; end
end
[+"hello", +"world"].each { |a| -> { a.capitalize! }.call; p a }
[+"abcd"].each { |a| -> { a << "x" * 100 }.call; p a.size }
arr = [+"hi", +"yo"]; arr.each { |a| -> { a.upcase! }.call }; p arr
arr = [+"ab"]; arr.each { |a| -> { a << "y" * 100 }.call }; p arr[0].size

# a frozen String raises where CRuby raises
begin; f.call("fr".freeze); rescue FrozenError => ex; p ex.class; end
begin; m.call("fr".freeze); rescue FrozenError => ex; p ex.class; end

# binary content with a NUL keeps its length and bytes
s = +"a\0b"; f.call(s); m.call(s); p s.size, s.bytes.first(4)
b = "\xff\0".b; p K.new.method(:app2).call(b.dup), b.size

# a `<<` taken back into its slot keeps a user object whose #<< answers
# something else: only a plain String's append answers the new String
class ShlAnswers
  def <<(x) = 42
end
[ShlAnswers.new, +"s"].each { |a| -> { a << "x" }.call; p a.class }
shl = [ShlAnswers.new, +"s"][ARGV.size]
shl << "x"
p shl.class
