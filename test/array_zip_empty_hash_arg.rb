# Array#zip with an empty `{}` literal argument zips a column of nils,
# as a Hash with no pairs enumerates nothing.

p [1, 2].zip({})
p [1, "a"].zip({})
p ["a"].zip(({}))
p [1.5].zip({})
p [1, 2].zip({}, [3])
p [1, "a"].zip({}, {b: 2})
p [[1], [2]].map { |a| a.zip({}) }
[1, 2].zip({}) { |x| p x }
