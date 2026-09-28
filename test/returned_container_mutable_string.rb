# A mutable string stored in a container that reaches its mutator through a
# method result, an ivar, a reader, a global or a block result is the
# container's own string: mutating the element read has to show up in the
# container, as it does when the container is a local literal.

def pair = [[3, 1], +"s"]
x = pair
x[1] << "q"
p x

def opts = {k: +"a"}
h = opts
h[:k] << "b"
p h

def row
  r = [1, "r".dup]
  r
end
y = row
y[1].concat("x", "y")
y[1].insert(0, "<")
y[1].upcase!
y[1][0] = "("
p y

def cleared = [1, String.new("c")]
z = cleared
z[1].replace("R")
p z
z[1].clear
p z

def ident = [1, 2.to_s]
w = ident
e = w[1]
w[1] << "!"
p e.equal?(w[1]), e, w

def alias_me = [+"a"]
v = alias_me
s = v[0]
s << "q"
p v

def each_me = ["b" * 2]
u = each_me
u.each { |t| t << "?" }
p u

class Holder
  attr_reader :items
  def initialize
    @items = {name: +"n", n: 1}
    @list = [1, +"l"]
  end
  def list = @list
  def bump
    @list[1] << "+"
    @list
  end
end
hd = Holder.new
hd.items[:name] << "!"
p hd.items
hd.list[1] << "-"
p hd.bump

gen = Array.new(2) { |i| "g#{i}" }
gen[0] << "*"
p gen

def build = yield
blk = build { [1, +"y"] }
blk[1] << "z"
p blk

$shared = [1, +"g"]
def global_list = $shared
gl = global_list
gl[1] << "!"
p $shared
