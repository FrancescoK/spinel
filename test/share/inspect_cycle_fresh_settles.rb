# An inspect that calls inspect on a box which may hold its own object or a
# String (Rails::Env#inspect, `@name.inspect`) answers a new String: Set's
# inspect, which maps its elements by that call into the Array it builds,
# then hands on new Strings, kept and changed in place as in CRuby (#9258).
# Two things took the cycle as answering a held String:
# - a method no call reaches, answering its parameter or itself on a new
#   String (`scan` below), whose answer turned from round to round of the
#   fresh walk, so the walk never settled and its fallback took every cycle
#   as not fresh;
# - the walk listed every class's inspect as a target of `@name.inspect`,
#   Node's among them, which publishes its ivar but which no box of an Env
#   can hold.
require 'set'
class Env
  def initialize(name) = @name = name
  def inspect = @name.inspect
  def to_s = @name.to_s
end
class Leaf
  def inspect = "#<Leaf>"
end
class Node
  def initialize(label) = @label = label
  def inspect = @label
end
module W
  def self.wrap(text) = scan(text, "", 0, text.length).dup
  def self.scan(text, out, i, n)
    return out if i >= n
    scan(text, out + "\n", i + 1, n) if text[i] == "\n"
  end
end

all = []
e = Env.new("development")
nested = Env.new(Env.new("inner"))

# Set#inspect over the cycle beside a literal's inspect
r = Set.new([e, Leaf.new]).inspect
all << r; r << "!"
p r

# the box holding its own object
r2 = Set.new([nested, e]).inspect
all << r2; r2 << "?"
p r2

# Set#to_s (an alias of inspect), map(&:inspect) and a join
t = Set.new([nested]).to_s
all << t; t << "%"
m = [e, nested, Leaf.new].map(&:inspect)
all << m[1]; m[1] << "#"
j = [e, nested].map { |x| x.inspect }.join(", ")
all << j; j << "."
p t, m, j

# a Hash value
h = { env: nested }.inspect
all << h; h << "&"
p h

# beside a class whose inspect publishes its ivar
lab = +"leaf"
s = Set.new([Node.new(lab), e]).inspect
all << s; s << "*"; lab << "+"
p s, lab

p all, e.inspect, nested.inspect
