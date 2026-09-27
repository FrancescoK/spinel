# A Struct/Data member set by a custom initialize's super takes its type
# from what super passes, so a nil default reads back as nil.

Options = Data.define(:song) do
  def initialize(song: nil)
    super
  end
end
default = Options.new
chosen = Options.new(song: 3)
p default.song
p default.song.nil?
puts(default.song ? "has song" : "no song")
p chosen.song
p Options.new == Options.new, chosen == Options.new(song: 3)
p chosen.to_h, default.to_h, default

S = Struct.new(:song, keyword_init: true) do
  def initialize(song: nil)
    super
  end
end
p S.new.song, S.new(song: 3).song

D = Data.define(:song) do
  def initialize(song: nil) = super(song:)
end
p D.new.song, D.new(song: 3).song

E = Data.define(:a, :b) do
  def initialize(a:, b: nil) = super
end
p E.new(a: 1).b, E.new(a: 1, b: 2.5).b

J = Data.define(:v) do
  def initialize(v: nil) = super
end
p J.new.v, J.new(v: 1.5).v

K = Data.define(:v) do
  def initialize(v: nil) = super(v: v)
end
p K.new.v, K.new(v: 1.5).v

P = Struct.new(:x, :y) do
  def initialize(x, y = nil)
    super
  end
end
p P.new(1).y, P.new(1, 2).y

L = Struct.new(:x, :v) do
  def initialize(x, v = nil)
    super(x, v)
  end
end
p L.new(1).v, L.new(1, 2.5).v

class M < Struct.new(:n)
  def initialize(n = nil)
    super
  end
end
p M.new.n, M.new(4).n

# a default of another type than the call sites pass
F = Data.define(:song) do
  def initialize(song: "x") = super
end
p F.new.song, F.new(song: 3).song

G = Data.define(:s, :a) do
  def initialize(s: nil, a: nil) = super
end
p G.new.s, G.new.a, G.new(s: "hi", a: [1]).s, G.new(s: "hi", a: [1]).a

# super converts the argument
N = Struct.new(:n) do
  def initialize(s)
    super(s.to_s * 2)
  end
end
p N.new(3).n

# keywords declared in another order than the members
I = Data.define(:a, :b) do
  def initialize(b: nil, a: 0) = super
end
p I.new.a, I.new.b, I.new(a: 1, b: 2).a, I.new(a: 1, b: 2).b

# a bare super forwarding a rest parameter
class R < Struct.new(:a, :b, :c)
  def initialize(a, *r)
    super
  end
end
x = R.new(1, "s")
p x.a, x.b, x.c
y = R.new(1, "s", 2.5)
p y.a, y.b, y.c
