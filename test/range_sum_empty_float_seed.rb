# spinel: share
# spinel: gc-minor
# Empty Ranges normalize a Float zero seed; Arrays keep the seed unchanged.
def empty_total(values, seed)
  values.sum(seed)
end
p (2..1).sum(-0.0)
p (2...2).sum(-0.0)
[(2..1), []].each { |values| p empty_total(values, -0.0) }
p (1..2).sum(0.5)
p empty_total((2..1), nil)
p empty_total((2..1), "kept")
p empty_total((2..1), 1r)
