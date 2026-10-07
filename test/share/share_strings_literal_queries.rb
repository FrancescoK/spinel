# Calls that answer a container or a new value do not demand handles for
# a literal's Strings. The share target also checks their generated stores.
p({item: "value", count: 1}.freeze)
p(["a", "b"].freeze)
p(%w[x y].include?("x"))
p(["a"].join)
p(["a", "b"].size)
p({item: "value"}.size)
p([1, 2].max)
