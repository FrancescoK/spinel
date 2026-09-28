# each_with_index on a Hash, a Range or an Enumerator read out of a
# container walks its items with their indexes, as on a typed receiver:
# a Hash's [key, value] pairs, a Range's members, an Enumerator's values.
p [[1, 2, 3].each, 0][0].each_with_index.to_a
p [(1..3), 0][0].each_with_index.to_a
p [("a".."b"), 0][0].each_with_index.to_a
p [{ a: 1, b: 2 }, 0][0].each_with_index.to_a
p [(1..3), 0][0].each_with_index.map { |v, i| v * i }
p [(4..6), 0][0].each_with_index.select { |v, i| i > 0 }
p [{ a: 1, b: 2 }, 0][0].each_with_index.map { |kv, i| [kv[0], i] }
p [[4, 5], 0][0].each_with_index.to_a
acc = []
200.times { |i| acc << [(i..i + 1), 0][0].each_with_index.to_a }
p [acc.size, acc[199]]
