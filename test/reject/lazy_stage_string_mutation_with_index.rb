# A lazy stage after with_index that changes its String element in place:
# with_index pairs the element with its index and does not replace it, so
# the stage's `|x, i|` is the String the source holds. Refused, naming the
# line, as a stage ahead of with_index is.
# spinel: reject-lazy-mutation
s = +"abc"
p [s].each.lazy.with_index(5).select { |x, i| x.upcase! }.first
p s
