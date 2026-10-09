# spinel: share
# spinel: gc-minor
# equal? and object_id read a frozen literal as one object whichever face
# each side holds: the bytes, a handle, or a box of either.
SRC = +"src"
S = Struct.new(:a)
class Holder
  attr_reader :r
  def initialize(v) = @r = v
  def iv = @r
  def lit = "lit"
  def pick(k) = k == 0 ? "lit" : SRC
end
x = S.new("lit")
z = S.new(SRC)
k = Holder.new("lit")
kz = Holder.new(SRC)
z.a << "!"
kz.r << "?"
p x.a.equal?("lit"), "lit".equal?(x.a), x.a.equal?(x.a), x.a.object_id == "lit".object_id
p k.r.equal?("lit"), "lit".equal?(k.r), k.iv.equal?("lit"), k.r.equal?(k.lit), k.lit.equal?(k.r)
v = k.r
p v.equal?("lit"), v.equal?(k.r), k.r.equal?(v), v.equal?(k.lit)
p k.pick(0).equal?("lit"), k.pick(0).equal?(k.pick(0)), k.pick(0).equal?(v)
p z.a.equal?(SRC), SRC.equal?(z.a), kz.r.equal?(SRC), k.r.equal?(SRC), SRC.equal?(k.lit)
h = { "k" => "lit", "j" => SRC }
p h["k"].equal?("lit"), "lit".equal?(h["k"]), h["k"].equal?(v), v.equal?(h["k"])
a = ["lit", SRC]
p a[0].equal?("lit"), "lit".equal?(a[0]), a[0].equal?(v), v.equal?(a[0]), a[1].equal?("lit"), "lit".equal?(a[1])
p "lit".freeze.equal?("lit"), (-"lit").equal?("lit"), "lit".freeze.equal?(k.r), k.r.equal?(-"lit")
p SRC, kz.r, z.a
# adjacent literals and a squiggly heredoc of mixed indents fold to one
# literal each, and are the same object as any equal literal
adj = S.new("a" "b")
adj2 = S.new("p" 'q' "r")
hd = S.new(<<~T)
  ab
    cd
  ef
T
hd2 = <<~T
  ab
    cd
  ef
T
tail = S.new(+"k")
tail.a << "!"
p adj.a.equal?("a" "b"), adj.a.equal?("ab"), "ab".equal?(adj.a), adj2.a.equal?("pqr"), adj2.a
p hd.a.equal?(hd2), hd2.equal?(hd.a), hd.a.equal?("ab\n  cd\nef\n"), hd.a
p tail.a
