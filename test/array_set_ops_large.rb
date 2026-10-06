# Array set operations past the 16 elements where they stop scanning and
# probe a hash set: uniq, uniq!, &, |, -, intersection, union, difference and
# intersect? over Integer and String arrays, each answer in the receiver's
# order with its first occurrence kept, beside the small cases that still
# scan. nil in a String array stays distinct from "" beside it.
ints = (0...200).map { |i| (i * 37) % 61 }
odds = (0...150).map { |i| (i * 11) % 90 }
p ints.uniq
p ints & odds
p ints | odds
p ints - odds
p ints.intersection(odds)
p ints.union(odds)
p ints.difference(odds)
p ints.intersect?(odds), ints.intersect?((1000...1100).to_a)
u = ints.dup
p u.uniq!, u.uniq!
p [3, 1, 3, 2].uniq, [3, 1] & [1, 3, 3], [1, 2] | [2, 4], [1, 1, 2] - [2]
big = (0...20).map { |i| i - 10 } * 3
p big.uniq.size, (big & [-10, 0, 9]).size, (big | big).size, (big - big).size

words = (0...120).map { |i| "w#{(i * 13) % 37}" }
more = (0...90).map { |i| "w#{(i * 7) % 50}" }
p words.uniq
p words & more
p words | more
p words - more
p words.difference(more, %w[w1 w2])
p words.intersect?(more), words.intersect?(%w[none nope] * 10)
v = words.dup
p v.uniq!, v.uniq!
p (%w[a b] * 10 + [""]).uniq, (%w[x y] * 9) - %w[y], (%w[q] * 20) | %w[q r]
na = (["x"] * 20) + [nil, "", nil, ""]
nb = [nil] + ["y"] * 20
p na.uniq, na & nb, na | nb, na - nb, na.intersect?(nb), (na - [""]).size
