# union, intersection and difference with several operands whose kinds
# differ from the receiver's: a String or Float Array beside an Integer one,
# a mixed Array, a boxed operand (and, under --int-overflow=promote, an
# Array of a boxed Integer). Each runs over every operand, in order.

k = ARGV.size + 3
p [1].union([k], [2])
p [1].union(["a"], [2])
p [1, 2, 3].difference([2.0], [3])
p [1, 2, 3].intersection([1, 2], [2, "x"])
p ["a"].union([1], ["b"])
p [1.5].union([1], [2.5])
p [1, 2].union([], ["z"])

mixed = [1, "a"]
p mixed.union([2], ["b"])
p mixed.difference([1], ["a"])
p mixed.intersection(["a", 1], [1])

boxed = [[7], "s"][ARGV.size]
p [1].union(boxed, [5])
p [1, 7].difference([1.0], boxed)

log = []
r = [1].union((log << :a; [2]), (log << :b; ["c"]), (log << :c; [3]))
p r
p log

bad = [[1], 5][ARGV.size + 1]
begin
  [1].union(["a"], bad)
rescue TypeError => e
  puts e.message
end
