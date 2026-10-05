# with_index after a blockless group_by, partition, min_by, max_by, flat_map,
# find or find_index numbers the walk's block calls, as CRuby does, on an
# Array and on a value read out of a mixed Array.
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
a = [3, 1, 2]
t { a.group_by.with_index { |x, i| i.odd? } }
t { a.partition.with_index { |x, i| i == 0 } }
t { a.min_by.with_index { |x, i| -i } }
t { a.max_by.with_index { |x, i| -i } }
t { a.flat_map.with_index { |x, i| [x, i] } }
t { a.sort_by.with_index { |x, i| -i } }
t { a.filter_map.with_index { |x, i| x * i if i > 0 } }
t { a.select.with_index { |x, i| i > 0 } }
t { a.map.with_index { |x, i| x * i } }
t { a.reject.with_index { |x, i| i > 0 } }
t { a.find.with_index { |x, i| i == 1 } }
t { a.find_index.with_index { |x, i| i == 2 } }
t { a.take_while.with_index { |x, i| i < 2 } }
t { a.group_by.with_index(1) { |x, i| i.odd? } }
b = [[3, 1, 2], :a][0]
t { b.filter_map.with_index { |x, i| x * i if i > 0 } }
t { b.group_by.with_index { |x, i| i.odd? } }
t { b.partition.with_index { |x, i| i == 0 } }
t { b.min_by.with_index { |x, i| -i } }
t { b.find.with_index { |x, i| i == 1 } }
h = [{a: 1, b: 2}, :a][0]
t { h.group_by.with_index { |pair, i| i } }
t { h.min_by.with_index { |pair, i| -i } }
t { [5, :a][0].group_by.with_index { |x, i| i } }
