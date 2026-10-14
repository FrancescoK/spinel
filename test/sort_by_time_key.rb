# sort_by with a Time key orders by the instant, as CRuby does, where the
# call raised NoMethodError for `sort_by` on an Array.
names = ["bb", "a", "dddd", "ccc"]
p names.sort_by { |s| Time.at(100 - s.size) }
p names.sort_by { |s| Time.at(s.size) }.reverse
sorted = names.dup
sorted.sort_by! { |s| Time.at(s.size, 5) }
p sorted
p [3, 1, 2].sort_by { |i| Time.at(i) }
