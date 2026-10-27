# Kernel#Hash and Kernel#Array of a container that may be nil answer a new
# empty one for nil, and the container itself otherwise
def opt(x = nil) = Hash(x)
t = opt
t["s"] = 1
p t
p opt({u: 1}).keys
h = {a: 1}
p Hash(h).equal?(h)
def pick(n) = n > 0 ? {a: n} : nil
p Hash(pick(0)), Hash(pick(2))
r = Hash(pick(0)); r[:z] = 9; p r
class K
  def initialize(c) = (@h = c ? {k: 1.5} : nil)
  def h2 = Hash(@h)
end
p K.new(true).h2, K.new(false).h2
p Hash(nil), Hash([])
def oa(x = nil) = Array(x)
p oa, oa([1])
def os(x = nil) = String(x)
p os, os("q")
y = nil
y = {b: 2} if ARGV.size > 5
p Hash(y)
z = Hash(y)
z[:c] = 3
p z, y
