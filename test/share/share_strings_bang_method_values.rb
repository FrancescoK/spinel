# Under --share-strings a method whose value is a bang method on a shared
# String (`def m(a) = a.upcase!`) answers that String, or nil when the bang
# changed nothing: its call hands on the receiver itself, also through a
# conditional, a case or a rescue modifier around the bang, and on a
# receiver that is a box (one an is_a? guard narrows too) or an instance
# variable.
def up(a) = a.upcase!
def guarded(a) = (a.gsub!("b", "B") if a.is_a?(String))
def picked(a, k)
  case k
  when 1 then a.upcase!
  when 2 then a.downcase!
  end
end
def shout(a) = (a.capitalize! unless a.empty?)
def quiet(a) = (a.swapcase! rescue nil)
def squeezed(s) = s.squeeze!
def log(v) = (puts "arg"; v)

x = +"ab"
r = up(log(x))
r << "1"
p x, r.equal?(x), up(x)
g = +"abc"
t = "#{guarded(g)}|#{guarded(1)}|#{guarded(g).inspect}"
q = guarded(+"bb") || "none"
g << "!"
p t, q, g
res = []
3.times { |i| res << guarded(+"ab#{i}") }
res[0] << "?"
p res, [guarded(g), guarded(2)]
y = +"Qr"
w = picked(y, 2)
w << "2"
p y, w.equal?(y), picked(y, 2), picked(y, 3)
z = +"mn"
s = shout(z)
s << "3"
p z, s.equal?(z), shout(+"")
v = +"Ab"
u = quiet(v)
u << "4"
p v, u.equal?(v)
xs = [+" ab ", 1, +"cd", +"eef "]
e = squeezed(xs[3])
e << "5"
p xs, e.equal?(xs[3]), squeezed(xs[2])
class H
  def initialize(v) = (@s = +v)
  attr_reader :s
  def bang = @s.upcase!
end
h = H.new("ab")
b = h.bang
b << "i"
p h.s, b.equal?(h.s), h.bang
def narrowed(a) = (a.downcase! if a.is_a?(String))
nx = +"NB"
nr = narrowed(nx)
nr << "?"
p nx, nr.equal?(nx), narrowed(:s), narrowed(nx)
