# A block parameter bound by destructuring, or a lambda's keyword, shadows
# an outer local of the same name instead of writing it.

j = 1
[[2, 3]].each { |(b, j)| p j }
p j

s = "outer"
[["a", "b"]].each { |(x, s)| p s }
p s

i = 9
[[1, 2]].each_with_index { |(a, i), n| p [a, i, n] }
p i

v = :v
{a: 1}.each { |(k, v)| p v }
p v

def pair
  yield [5, 6], 7
end
w = 0
pair { |(a, w), z| p w }
p w

g = 1
[[1, [2, 3]]].each { |a, (b, g)| p g }
p g

t = 1
[[1, [2, 3]]].each { |(a, (b, t))| p t }
p t

u = 1
f = ->((a, u)) { u }
p f.call([1, 2])
p u

k = "outer"
[1].each { |a| l = ->(k: 3) { k }; p l.call; p l.call(k: 4) }
p k

h = ->(k:) { k }
p h.call(k: 5)
p h.parameters
begin
  h.call
rescue ArgumentError => e
  p e.message
end

q = proc { |a, (b, k)| [a, b, k] }
p q.call(1, [2, 3])
p k
