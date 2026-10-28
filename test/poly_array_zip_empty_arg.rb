# zip with an empty [] argument on a general (mixed) Array builds and pads with nil.
def pk(n) = n > 0 ? [1, "a"] : [2]
v = pk(1)
p v.zip([])
p v.zip([], [1, 2])
p v.zip([], [])
p v.zip([]).size
q = [v, 3].first
p q.zip([])
p [1.5, 2.5].zip([])
p ["a"].zip([])
p v.product([])
p v + []
p v - []
p v | []
p v & []
p v.concat([])
p v.union([])
p v.difference([])
p v.intersection([])
p v.push(*[])
x = v.zip([]) { |a| p a }
p x
def zz(a) = a.zip([])
p zz([1, :s])
p zz([2])
