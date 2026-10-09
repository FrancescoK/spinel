# spinel: share
# spinel: gc-minor
# A box holding a String answers that String for to_str, as it does for
# to_s: a change through the answer shows through the String. An object in
# the box answers its own to_str, which is no String another name holds, and
# nil stays nil under `&.`.
class T
  def initialize(x) = @x = x
  def to_str = @x + "?"
end
def conv(s) = s.to_str
def conv_nil(s) = s&.to_str
src = +"abc"
t = T.new("t")
u = conv(src)
u << "1"
v = conv(t)
v << "2"
w = conv_nil(src)
w << "3"
x = conv_nil(t)
x << "4"
p src, u.equal?(src), v, x, conv_nil(nil)
begin
  conv(5)
rescue NoMethodError => e
  puts e.class
end

# a box read from an Array, and an instance variable that holds one
pool = [src, T.new("q"), nil]
a = pool[ARGV.size]&.to_str
a << "5"
b = pool[ARGV.size + 1]&.to_str
b << "6"
p src, b, pool[ARGV.size + 2]&.to_str
class Holder
  def initialize(s) = @s = s
  def str = @s&.to_str
  attr_reader :s
end
held = +"held"
h = Holder.new(held)
y = h.str
y << "7"
p held, h.s
Holder.new(nil)

# a frozen literal stays frozen
frozen = "lit"
z = conv(frozen)
p z.equal?(frozen), z.frozen?
