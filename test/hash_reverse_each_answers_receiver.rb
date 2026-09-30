# Hash#reverse_each with a block answers the Hash itself, not the array of
# pairs it walked; a `break` still answers its value.
h = {a: 1, b: 2}
r = h.reverse_each { |k, v| k }
p [r.equal?(h), r]
p h.reverse_each { |key, value| key }.class
seen = []
h.reverse_each { |k, v| seen << [k, v] }
p seen
q = {"x" => 1, "y" => 2}
p q.reverse_each { |k, v| }.equal?(q)
i = {1 => 10, 2 => 20}
p i.reverse_each { |k, v| }.equal?(i)
m = {a: 1, "b" => 2}
p m.reverse_each { |k, v| }.equal?(m)
p h.reverse_each { |k, v| break k }
p h.reverse_each { |k, v| next }.equal?(h)
p h.reverse_each { |pair| pair }.equal?(h)
p h.reverse_each.class
p h.reverse_each.to_a
x = [{a: 1}, 0][0]
p x.reverse_each { |k, v| }.equal?(x)
def go(hash) = hash.reverse_each { |k, v| k }
p go(h).equal?(h)
o = []
p (h.reverse_each { |k, v| o << k }).equal?(h), o
z = (h.reverse_each { |k, v| k })
p z
c = h.reverse_each.each { |k, v| k }
p [c.equal?(h), c]
p h.reverse_each { |k, v| k }.size
p h.reverse_each { |k, v| k }.keys

f = {}
f[:a] = 1
p f.reverse_each { |k, v| }.equal?(f)
g = Hash.new(0)
p g.reverse_each { |k, v| }.equal?(g)
y = {a: 1}.merge({b: 2})
p y.reverse_each { |k, v| }.equal?(y)
p({a: 1}.reverse_each { |k, v| })
class K
  def initialize = @h = {a: 1, b: 2}
  def go = @h.reverse_each { |k, v| k }
  def h = @h
end
k = K.new
p k.go.equal?(k.h)
