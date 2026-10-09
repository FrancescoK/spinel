# spinel: share
# spinel: gc-minor
# A frozen literal answered through any boxing route is one object: every
# evaluation of its site, and every equal literal, hands on the same handle,
# beside the shared Strings the same routes carry.
SRC = +"src"

# a polymorphic dispatcher answering a String, a literal or nil
class Pick
  def initialize(x) = @x = x
  def get(k) = k > 1 ? @x : (k > 0 ? "lit" : nil)
  def fz(k) = k > 1 ? @x : (k > 0 ? "lit".freeze : @x + "n")
  def neg(k) = k > 1 ? @x : -"lit"
  def ens(f)
    begin
      f ? @x : "lit"
    ensure
      @n = 1
    end
  end
end
class Other
  def get(k) = 1
  def fz(k) = 1
  def neg(k) = 2
  def ens(f) = 3
end
src = +"s"
os = [Pick.new(src), Other.new]
a = os[0].get(1)
b = os[0].get(1)
p a.equal?(b), a.equal?("lit"), a.frozen?, os[0].get(0)
c = os[0].fz(1)
d = os[0].fz(1)
p c.equal?(d), c.equal?(a), c.frozen?
e = os[0].neg(1)
p e.equal?(os[0].neg(1)), e.equal?(a), e.frozen?
f = os[0].ens(false)
p f.equal?(os[0].ens(false)), f.equal?(a)
g = os[0].get(2)
g << "!"
p src, g.equal?(src)

# a typed String return: a literal answer, with and without an ensure
def odd_or_src(n) = n.odd? ? "odd" : SRC
def guarded(k)
  begin
    k == 0 ? "lit" : (k == 1 ? SRC : +"fresh")
  ensure
    nil
  end
end
v = [odd_or_src(1), odd_or_src(1), odd_or_src(2), 3]
p v[0].equal?(v[1]), v[0].equal?("odd"), v[2].equal?(SRC)
v[2] << "?"
p SRC
w = [guarded(0), guarded(0), guarded(1), 7]
p w[0].equal?(w[1]), w[0].equal?(a)
w[2] << "~"
p SRC

# the same sites inside a proc, and a block that leaves with a literal
l = ->(flag) { begin; flag ? src : "lit"; ensure; end }
xs = [l, 1]
h = xs[0].(false)
p h.equal?(xs[0].(false)), h.equal?(a), h.frozen?
m = [1, 2].map { |i| i > 1 ? src : "lit" }
m2 = [1, 2].map { |i| i > 1 ? src : "lit" }
p m[0].equal?(m2[0]), m[0].equal?(a)
m[1] << "m"
r = [1].each { break "blit" }
r2 = [1].each { break "blit" }
p r.equal?(r2), r.frozen?
n = [1, 2, 3].map { |i| next src if i == 1; "lit" }
p n[1].equal?(n[2]), n[1].equal?(a), n[1].frozen?
n[0] << "n"
p src, SRC

# a frozen literal stays frozen; +"lit" is a new String each evaluation
begin
  a << "x"
rescue FrozenError => ex
  p ex.class
end
u = [+"lit", +"lit", "lit"]
p u[0].equal?(u[1]), u[0].equal?(u[2]), u[0].frozen?
u[0] << "!"
p u[0], u[1], u[2]
t = "i#{1}"
p t.equal?("i1"), t.frozen?
