# Array#combination, #permutation and their repeated forms without a block
# answer an Enumerator labeled with the receiver and the call, as in CRuby,
# on an Array of mixed elements and on a boxed one too; spinel answered the
# Array of the tuples.
pa = [3, "a", :b]
b = [[3, 1, 2], 1][0]
p pa.combination(2), pa.permutation, b.combination(2), b.repeated_permutation(1)
p b.repeated_combination(2), b.permutation(2)
e = b.combination(2)
p e.next, e.next, e.size, e.class
p e.rewind.next, e.to_a
# a walk on the call answers as it did over the tuples
p pa.combination(2).map { |x, y| [y, x] }, pa.permutation(2).count
p b.combination(2).sum([]), b.combination(2).select { |x, y| x > y }
p b.combination(2).take(1), b.combination(2).first(2), b.combination(2).size
# a walk that answers its receiver answers the Array the tuples come from
p b.combination(2).each { |x| }, b.combination(2).each_with_index { |x, i| }
p pa.combination(1).each_with_index { |x, i| }
p b.combination(2).with_index.to_a
# the chains that read the tuples laid out answer as before
p b.combination(2).map.with_index { |x, i| [x, i] }, b.combination(2).any?([3, 1])
pa.combination(2).each { |x, y| p [x, y] }
pa.combination(2).each(&method(:p))
