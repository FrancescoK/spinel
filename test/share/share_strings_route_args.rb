# Flag-only: without the flag (as on master) each call hands its parameter
# a copy, and the append through the parameter misses the caller's String.
# An argument that is no variable's read but hands on a shared String --
# `s << x`, `+s`, `String(s)`, `s.then { |v| v }` -- reaches a parameter
# the method appends to as that String's handle: in a plain call, with a
# count beside it, as a keyword, with a block, on an object, and through a
# dispatch over two classes. A route whose block makes a new String still
# hands over a String of its own. A nil one (a nil variable, or a route
# that answers nil, its tail or a `next` of its block) binds the parameter
# nil, and the append raises NoMethodError, as on any nil. A route that
# answers a String of its own (`+` of a frozen String, a `then` that makes
# one) stays rooted while a mutator's arguments allocate.
def grow(u) = u << "!"
def grow2(u, n)
  n.times { u << "+" }
  u
end
def growk(u:) = u << "k"
def growb(u) = (yield; u << "b")
class G; def grow(u) = u << "g"; end
class H; def grow(u) = u << "h"; end
s = +"a"
t = s
grow(s << "x")
grow(+s)
grow(s.then { |v| v })
grow(String(s))
grow2(s << "y", 2)
growk(u: +s)
growb(+s) { 1 }
G.new.grow(+s)
[G.new, H.new][s.size % 2].grow(s.then { |v| v })
r = grow(s.then { |v| v + "f" })
p s, t, r
z = "lit"
begin; grow(+z); p z; rescue => e; p e.class; end
n = nil
n = +"n" if ARGV.size > 5
def grow3(u)
  u << "3"
  nil
end
[-> { grow(n) }, -> { grow(n.then { |v| v }) }, -> { grow3(n.then { |v| v }) }, -> { grow(+n) }].each do |l|
  l.call
  p :no_error
rescue NoMethodError => e
  p e.class
end
c = s.size > 0
begin; grow(s.then { |v| next n if c; v }); p :no_error; rescue NoMethodError => e; p e.class; end
def ix = ([1, 2, 3].map(&:to_s).join.size - 3)
def vx = ([4, 5].map { |x| x.to_s * 400 }.join.size - 730)
fz = "frozen-literal-text"
tot = 0
50.times { tot += (+fz).setbyte(ix, vx) }
50.times { tot += String(s.then { |v| v + "zz" * 50 }).setbyte(ix, vx) }
50.times { (+fz) << ix.to_s * 300 }
p tot, fz
def al(x)
  t = +x
  t << "!"
  t
end
p al(+"k")
[-> { al(ENV["SPINEL_NO_SUCH_VARIABLE_X"]) }, -> { al("abc"[10, 2]) }].each do |l|
  l.call
  p :no_error
rescue NoMethodError => e
  p e.class
end
