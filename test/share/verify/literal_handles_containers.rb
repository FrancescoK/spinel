# A frozen literal held in a container, a struct field or an ivar is the one
# object its site names, beside a shared String in the same container.
SRC = +"src"
L = "lit"
S = Struct.new(:a)
class Box
  attr_reader :x
  def initialize(n, src) = @x = n.odd? ? "lit" : src
end

xs = [L, SRC, "lit", 1]
p xs[0].equal?(L), xs[2].equal?(L), xs[0].equal?(xs[2])
xs[1] << "!"
p SRC
ys = [1, "lit", SRC]
p ys[1].equal?(L), ys.first(2)[1].equal?(L), ys[1].frozen?
h = { a: "lit", b: SRC, c: 1 }
p h[:a].equal?(L), h[:a].equal?(h[:a]), h.values[0].equal?(L)
h[:b] << "?"
p SRC

zs = ys.dup
p zs[1].equal?(ys[1]), zs[1].equal?("lit")
zs[2] << "~"
p SRC
ws = ys.select { |y| y.is_a?(String) }
p ws[0].equal?(ys[1])
ws[1] << "^"
p SRC

a = S.new("lit")
b = S.new("lit")
c = S.new(SRC)
p a.a.equal?(b.a), a.a.equal?("lit"), a.a.frozen?
c.a << "#"
p SRC

src = +"s"
d = Box.new(1, src)
e = Box.new(3, src)
f = Box.new(2, src)
p d.x.equal?(e.x), d.x.equal?(L), d.x.frozen?
f.x << "&"
p src
begin
  d.x << "x"
rescue FrozenError => ex
  p ex.class
end

# adjacent literals and a squiggly heredoc of mixed indents fold to one
# frozen literal each, beside a String that is written through
T2 = Struct.new(:a, :b)
g = T2.new("a" "b", +"k")
g.b << "!"
p g.a.equal?("ab"), g.a, g.b
hd = T2.new(<<~T, +"k")
  ab
    cd
  ef
T
hd.b << "?"
p hd.a.equal?(hd.a), hd.a.frozen?, hd.a, hd.b
q = ["p" 'q' "r", SRC, 1]
p q[0].equal?("pqr"), q[0]
