# An element's nil bit goes with the element. A Float array emptied by a
# shift of its one nil element clears that bit, so the next push reads as
# the value it holds. combination / permutation pop each element they
# backtrack over with its bit, so a value pushed into that slot next is not
# read as nil. The arrays get their nil from a gap a write past the end
# fills, so they stay Integer and Float arrays.
n = ARGV.size
a = [1.5]
a[2 + n] = 2.5
a.pop
a.shift
p a
p a.shift
a << 3.5
p a
p a[0]

b = [5]
b[2 + n] = 7
p b
p b.combination(1).to_a
p b.combination(2).to_a
p b.repeated_combination(1).to_a
p b.permutation(1).to_a
p b.permutation(2).to_a
p b.repeated_permutation(1).to_a
