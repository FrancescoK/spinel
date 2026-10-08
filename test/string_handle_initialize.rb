# spinel: share
# A String an `initialize` appends to is the caller's String (#6179): the
# parameter takes the shared handle, which every binder of the constructor
# hands over, and the caller's variable at each `new` and `raise` that can
# reach it becomes the handle. Each append is 100 bytes, so it always
# outgrows the buffer and a copy could not pass by capacity.
# spinel: gc-minor
X = "x" * 100

# C.new, a class value, `new` and `self.new` in a class method, a subclass,
# a `self.new` of the class's own that hands on to `super`
class Box
  def initialize(s) = (s << X)
  def self.make(s) = new(s)
  def self.make2(s) = self.new(s)
end
class Sub < Box; end
class Cat
  def initialize(s) = (s.concat(X); @n = s.size)
  def n = @n
end
class Made
  def self.new(s) = super
  def initialize(s) = (s << X)
end
s = +"a"; Box.new(s); Box.make(s); Box.make2(s); Sub.new(s); p s.size
s = +"o"; Made.new(s); p s.size
[Box, Cat].each { |k| t = +"b"; k.new(t); p t.size }
k = [Box, Cat][ARGV.size]; t = +"c"; k.new(t); p t.size

# a class value whose other class keeps the String: it keeps the caller's
class Keep
  def initialize(s) = (@s = s)
  def s = @s
end
kept = nil
[Box, Keep].each { |c| u = +"d"; o = c.new(u); kept = o if o.is_a?(Keep); u << "y" * 2000; p u.size }
p kept.s.size

# raise C, s and raise k, s, into an exception's initialize
class Oops < StandardError
  def initialize(msg)
    msg << X
    super(msg)
  end
end
m = +"boom"
begin; raise Oops, m; rescue Oops => e; p [e.message.size, m.size]; end
ek = [Oops, ArgumentError][ARGV.size]; m = +"bang"
begin; raise ek, m; rescue Oops => e; p [e.message.size, m.size]; end

# super: explicit, bare, from a local, and handed on to a helper that appends
class Parent
  def initialize(s) = fill(s)
  def fill(b) = (b << X; nil)
end
class Explicit < Parent
  def initialize(s, n) = (super(s); s << "!" * n)
end
class Bare < Parent
  def initialize(s) = super
end
class Local < Parent
  def initialize = (t = +"l"; super(t); @t = t)
  def t = @t
end
s = +"e"; Explicit.new(s, 3); Bare.new(s); p s.size, Local.new.t.size

# keywords, an optional, a nil default, a parameter handed on, an ivar
class Kw
  def initialize(n, k:, o: nil, opt: +"")
    k << "k" * n
    o << "o" * n if o
    opt << X
    @o = o
  end
  def o = @o
end
s = +"f"; t = +"g"; Kw.new(100, k: s); p Kw.new(10, k: s, o: t).o.size, [s.size, t.size], Kw.new(1, k: s).o
def via(v) = Box.new(v)
s = +"h"; via(s); p s.size
class Holder
  def initialize(b) = (@b = b)
  def into_box = Box.new(@b)
  def b = @b
end
h = Holder.new(+"i"); h.into_box; p h.b.size

# a Struct's and a Data's initialize, keyword_init included, appending
# before and after an explicit `super`
S = Struct.new(:a, :b) do
  def initialize(a, b) = (a << X; super)
end
K = Struct.new(:a, keyword_init: true) do
  def initialize(a:) = (a << X; super)
end
D = Data.define(:a) do
  def initialize(a:) = (a << X; super)
end
T = Struct.new(:a) do
  def initialize(a) = (super(a); a << X)
end
s = +"j"; x = S.new(s, 2); p [s.size, x.a.size]
s = +"i"; x = T.new(s); s << "!"; p [s.size, x.a.size]
s = +"k"; y = K.new(a: s); p [s.size, y.a.size]
s = +"l"; z = D.new(a: s); p [s.size, z.a.size]
E2 = Data.define(:a) do
  def initialize(a:) = (super(a: a); a << X)
end
s = +"n"; z = E2.new(a: s); p [s.size, z.a.size]

# argument order, a splatted Array literal, literals and temporaries, a
# frozen String, a NUL
class Two
  def initialize(s, n) = (s << "!" * n)
end
s = +"a"; Two.new(s, (s = +"q"; 100)); p s
class Pair
  def initialize(s, n) = (s << "!" * n)
end
s = +"b"; Pair.new(*[s, 100]); p s.size
Box.new(+"lit"); s = +"m"; Box.new(s + "n"); p s
begin; Box.new("fr".freeze); rescue FrozenError => e; p e.class; end
s = +"a\0b"; Box.new(s); p s.size, s[0, 3]

# the caller's String, once the handle, read by an initialize that only
# reads it (it goes over as its live bytes), then grown
class Len
  def initialize(s) = (@n = s.size + s.upcase.size)
  def n = @n
end
s = +"r"; Box.new(s); a = Len.new(s); s << "z" * 2000
p a.n, Len.new(s).n
