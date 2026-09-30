# A boxed Float array's blockless sum starts at the Integer 0 and only a Float
# element promotes it, so an EMPTY one answers 0 -- not 0.0 -- like CRuby.
empty = [1.5].select { false }
full = [1.5, 2.25]
box = [empty, full, 1]

def total(xs) = xs.sum

p box[0].sum
p box[0].sum.class
p box[1].sum
p box[1].sum.class
p box[0].sum(0.0)
p box[0].sum(0)
p box[1].sum(0)
p total(box[0])
p total(box[1])
p total([1, 2])
