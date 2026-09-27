$a = [1, 2]
m = ->(x = ($a | [3])) { x }
p m.call
p m.call([9])

$n = 0
l = ->(x = [$n += 1, 2]) { x << 0; x }
p l.call
p l.call
p l.call([7])
p $n

pr = proc { |a, b = [5, 5], *r, c| [a, b, r, c] }
p pr.call(1)
p pr.call(1, 2, 3, 4, 5)

h = ->(x = {k: [1, 2]}) { x[:k].sum }
p h.call
p h.call({k: [5]})

k = ->(a:, b: [a, "s"], c: {z: 1}) { [a, b, c] }
p k.call(a: 1)
p k.call(a: 1, b: 2, c: 3)

s = ->(x = 1, y = 2.5) { x + y }
p s.call
p s.call(2)

acc = []
g = ->(x = Array.new(100) { |i| "s#{i}" }) { x }
2000.times { acc << g.call.last }
GC.start
p acc.size, acc[-1]
