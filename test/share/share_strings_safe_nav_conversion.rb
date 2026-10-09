# spinel: share
# spinel: gc-minor
# `s&.to_s`, `s&.to_str` and `s&.itself` answer the String s itself, or nil
# for a nil s, whether s is typed or held in a box. A box holding an object
# runs that object's own to_s, and its answer is not the String of another
# name.

# a typed receiver in a method's tail
def text_of(s) = s&.to_s
def str_of(s) = s&.to_str
def self_of(s) = s&.itself
u = +"abc"
a = text_of(u)
b = str_of(u)
c = self_of(u)
a << "1"
b << "2"
c << "3"
p u, a.equal?(u), b.equal?(u), c.equal?(u)

# a frozen literal stays the frozen String it is
l = "lit"
x = text_of(l)
p x.equal?(l), x.frozen?
begin
  x << "!"
rescue FrozenError => e
  puts e.message
end

# an instance variable receiver, nil or not
class Holder
  def initialize(s) = @s = s
  def text = @s&.to_s
  def itself_text = @s&.itself
  attr_reader :s
end
held = +"held"
h = Holder.new(held)
d = h.text
e2 = h.itself_text
d << "1"
e2 << "2"
p held, h.s, d.equal?(held), e2.equal?(held)

# a box holding a String, an object with its own to_s, or nil
class Label
  def initialize(x) = @x = x
  def to_s = @x + "?"
end
src = +"base"
pool = [src, Label.new("lab"), nil]
f = pool[ARGV.size]&.to_s
f << "+"
g = pool[ARGV.size + 1]&.to_s
g << "!"
p src, f, g, g.equal?(src), pool[ARGV.size + 2]&.to_s

# a nil receiver answers nil and raises for a mutator on the answer
m = ARGV.size > 5 ? +"never" : nil
p m&.to_s, m&.to_str, m&.itself
begin
  (m&.to_s) << "x"
rescue NoMethodError
  puts "NoMethodError"
end

# the conversion stored in a variable or an Array, nil or not
w = ARGV.size > 5 ? +"a" : nil
t = w&.to_s
t << "!" if t
p w, t
v = ARGV.size > 5 ? nil : +"b"
r = v&.to_s
r << "!" if r
p v, r
box = []
box << v&.to_s
box[0] << "?"
p v, box
