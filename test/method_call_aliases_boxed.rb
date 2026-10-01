# A Method read out of a container that holds other values too is called
# by `[]` as by `.call`, whatever its arguments, and those type the
# Method's parameters (#6179): the container is an Array or Hash literal,
# a local or an instance variable holding one, or one a Method is stored
# into. A typed Method's `===` binds its arguments as `.call` does, and a
# Proc there is called by `.yield` too, where a Method has no `yield`.
def len(x) = x.size
def pick(n, s) = s.size + n
def cat(a, b) = a + b
def neg(n) = -n
p [method(:len), 1][ARGV.size]["abc"]
p [method(:pick), 1][ARGV.size][1, "abc"]
a = [method(:cat), :x]
p a[ARGV.size]["ab", "cd"], a.first["e", "f"]
h = { k: method(:pick), n: method(:neg) }
p h[:k][2, "xyz"], h.fetch(:k)[3, "wxyz"], h[:n][5]
s = {}
s[:p] = method(:pick)
q = []
q << method(:pick)
p s[:p][4, "ab"], q[0][5, "abc"]
class Table
  def initialize = (@t = { p: method(:pick) })
  def run(k, n, v) = @t[k][n, v]
end
p Table.new.run(:p, 6, "abcd")
t = method(:len)
p(t === "typed")
pr = [proc { |x| x * 2 }, 1][ARGV.size]
p pr.yield(21), pr[4], (pr === 5)
la = [->(x, y) { x * y }, nil][ARGV.size]
p la.yield(6, 7)
cu = [->(x, y) { x + y }.curry, 0][ARGV.size]
p cu.yield(1).yield(2)
m = [method(:neg), 1][ARGV.size]
begin; m.yield(1); rescue NoMethodError => e; p e.message; end
n = [1, pr][ARGV.size]
begin; n.yield(1); rescue NoMethodError => e; p e.message; end
