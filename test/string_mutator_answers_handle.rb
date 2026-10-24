# A String mutator in value position that answers its receiver (insert,
# concat, a bang that changed it) answers the String itself: the shim that
# runs it on a shadow and writes the shadow back answered the shadow's
# bytes, a copy, so `[s.insert(0, "<")]` stored a String that was not s.
s = +"nm"
a = [s.insert(0, "<")]
a[0] << ">"
p s
t = +"ab"
b = [t.upcase!]
b[0] << "!"
p t
u = +"AB"
p [u.upcase!]
x = +"q"
y = x.concat("r")
y << "s"
p x, y.equal?(x)
z = +"z"
w = z.slice!(0)
p w, z

# (and where the answer is read as bytes: a local, an argument, a method's value)
def show(x) = p(x)
s = +"ab"
x = s.insert(0, "<")
p x
show(s.insert(0, "["))
puts "v=#{s.insert(0, "{")}"
y = s.upcase!
p y
z = s.upcase!
p z
h = { k: s.prepend("-") }
p h
class K
  def initialize = @t = +"t"
  def m = @t.insert(0, "*")
  def n = @t.squeeze!
  def t = @t
end
k = K.new
w = k.m
w << "!"
p k.t, k.n
p s.length, s.replace("r"), s
