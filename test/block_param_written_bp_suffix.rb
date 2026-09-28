def y = yield(k__bp12: 1)
y { |k__bp12: 5| p k__bp12 }
p proc { |x__bp3, y__bp4 = 1, *r__bp5| }.parameters
p proc { |a__bp1, k__bp2:, j__bp3: 4, **o__bp4, &b__bp5| }.parameters
p lambda { |(d__bp6, e__bp7), f__bp8| }.parameters

def m
  k__bp12 = 0
  x = 10
  y { |k__bp12: 5| p k__bp12 }
  [1, 2].each { |x| p x }
  pr = proc { |x, x__bp1 = 3| [x, x__bp1] }
  p pr.parameters
  p pr.call(7)
  p k__bp12, x
end
m

def kw_rest = yield(a__bp9: 1, b: 2)
kw_rest { |a__bp9: 0, **rest| p [a__bp9, rest] }
w = 1
kw_rest { |w: 0, **rest| p [w, rest] }
p w
