# Calls that answer a container or a new value do not demand handles for
# a literal's Strings. The share target also checks their generated stores.
p({item: "value", count: 1}.freeze)
p(["a", "b"].freeze)
p(%w[x y].include?("x"))
p(["a"].join)
p(["a", "b"].size)
p({item: "value"}.size)
p([1, 2].max)

# A temporary's freshly made elements need no handle at the store. An
# alias made after the read can lift the result, as it did before.
a = [+"a", 1][0]
b = a
b << "!"
p a, b, a.equal?(b)
c = [1, "c".dup].last
c << "!"
p c
p [1, "frozen"].fetch(1)
p ["first", 1].first
p ["at", 1].at(0)
p ["dig", 1].dig(0)
p ["sample"].sample
p({item: "hash", count: 1}.fetch(:item))
p [1, "range", 3][0..1]
p [1, nil, "count"].first(1)

# A plain box must be written back by every link of a narrowed append
# chain. Reading a temporary handle would leave the original box unchanged.
x = [+"a", 1][0]
if x.is_a?(String)
  x << "b" << "c"
end
p x
