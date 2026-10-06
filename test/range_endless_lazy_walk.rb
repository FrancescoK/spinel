# An endless Range answers the calls CRuby makes by pulling its members one
# at a time, where Spinel materialized the member array first and raised
# RangeError "cannot convert endless range to an array": an Integer range's
# blockless each / each_entry / each_with_index chains, find_index(v) and the
# blockless any? / none? / one?, and a String range's any? / none? / one?,
# count and each_entry. The range is a literal or a local only ever assigned
# one.

endless_ints = (1..)
p endless_ints.each.first(2)
p endless_ints.each_entry.first(2)
p endless_ints.each_with_index.first(2)
walk = endless_ints.each_with_index
p walk.first(3)
p endless_ints.find_index(3)
p endless_ints.find_index(1)
p [endless_ints.any?, endless_ints.none?, endless_ints.one?]
p (5..).each_entry.first(3)
p (5..).find_index(7)
p [(5..).any?, (5..).none?, (5..).one?]
p (1..).each_with_index.first(1)

endless_strs = ("a"..)
p [endless_strs.any?, endless_strs.none?, endless_strs.one?]
p endless_strs.count
p endless_strs.count.class
p endless_strs.each_entry.first(2)
p [("y"..).any?, ("y"..).none?, ("y"..).one?, ("y"..).count]
seen_strs = []
endless_strs.each_entry { |v| seen_strs << v; break if seen_strs.size == 3 }
p seen_strs

# bounded ranges keep their answers
p (1..3).each_with_index.first(2)
p (1..3).find_index(3)
p [(1..3).any?, (3..1).any?, (3..1).none?, (1..1).one?]
p [("a".."c").any?, ("c".."a").none?, ("a".."a").one?, ("a".."c").count]
