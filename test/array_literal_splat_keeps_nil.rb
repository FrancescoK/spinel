# spinel: share
# A splatted Integer or Float Array keeps its nils in the literal it spreads
# into: a nil lives in the array's bitmap, not in the slot, whose 0 is all a
# copy of the slots carries over.
ints = [1, 2, 3].map { |x| x == 2 ? nil : x }
p [*ints, 4]
p [0, *ints]
floats = [1.5, 2.5].map { |x| x > 2.0 ? nil : x }
p [*floats, 3.5]
p [*ints, *ints]
