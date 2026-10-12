# Under --share-strings a bang method on a shared String handed on as an
# argument (`chk(x, x.upcase!)`, `chk(x, x.upcase! || x)`) is that String,
# or nil when the bang changed nothing: the parameter is the caller's
# String, whether the argument runs ahead of the others or in its place,
# on its own or as an arm of a conditional.
def chk(a, b) = p([b, a.equal?(b)])
def two(a, b, c) = p([a, b, c, a.equal?(b), b.equal?(c)])
def keep(s) = (s << "!"; s)
x = +"ab"
chk(x, x.upcase!)
chk(x, x.upcase!)
chk(x, x.upcase! || x)
chk(x, x.downcase! && x)
chk(x, (x.capitalize! if x.size > 1))
y = +"q"
two(y, y.upcase!, (y << "r"))
z = +"k"
two(z.upcase!, z, z.upcase!)
w = +"w"
keep(w.upcase!)
p w
class A; def take(s) = (s << "A"; s); end
class B; def take(s) = (s << "B"; s); end
[A.new, B.new].each { |o| o.take(w.downcase! || w) }
p w
class K
  def initialize(s) = (@s = s)
  def add = @s << "K"
end
k = K.new(w.upcase!)
k.add
p w
def kw(a:, b:) = (b << "k"; p a.equal?(b))
u = +"u"
kw(a: u, b: u.upcase!)
p u
