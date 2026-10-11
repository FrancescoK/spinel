# A String bang on a call's answer that is the shared handle (a method
# returning its parameter) holds that handle in a temp of the statement.
# gsub!/sub!'s block form runs its loop ahead of the statement, and a
# safe-navigation call's nil guard read the receiver there too: both read
# the temp before the statement declared it, and the C build stopped
# under --share-strings. The loop now reads a temp held ahead of it, and
# `&.` answers nil for a nil receiver, as in CRuby, where the held
# receiver raised NoMethodError.
def g(x) = x
def pick(v, m)
  return nil if m == 0
  v
end
r = g(+"ab").gsub!(/b/) { "B" }
p r
r = g(+"ab").gsub!(/z/) { "B" }
p r
r = g(+"ab").sub!(/a/) { |m| m.upcase }
p r
g(+"xy").gsub!(/x/) { "X" }
q = +"kq"
r = g(q).gsub!(/q/) { "Q" }
p r, q, r.equal?(q)
g(q).sub!(/k/) { "K" }
p q

o = +"o"
x = pick(+"ab", 2)&.upcase! || o
p x
x = pick(+"ab", 0)&.upcase! || o
p x, x.equal?(o)
x = pick(+"AB", 2)&.upcase! || o
p x, x.equal?(o)
x = pick(+"ab", 1)&.upcase!
p x
x = pick(+"ab", 0)&.upcase!
p x
pick(+"ab", 0)&.upcase!
s = +"st"
r = pick(s, 2)&.upcase! || o
p r, s, r.equal?(s)
r = pick(+"ab", 0)&.gsub!(/a/) { "A" }
p r
r = pick(+"ab", 2)&.gsub!(/a/) { "A" }
p r
r = pick(+"ab", 0)&.gsub!(/a/) { "A" } || o
p r, r.equal?(o)
r = pick(+"ab", 2)&.gsub!(/a/) { "A" } || o
p r

# a reader call's handle
class C
  def initialize = @s = +"ab"
  def s = @s
end
c = C.new
r = c.s.gsub!(/b/) { "B" }
p r, c.s, r.equal?(c.s)
r = c.s.gsub!(/z/) { "Z" }
p r
r = c.s&.insert(0, "<")
p r, c.s, r.equal?(c.s)
