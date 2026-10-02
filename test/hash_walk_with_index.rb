# A Hash walk's Enumerator with with_index: the walk's own answer, with the
# index beside each pair (or value)
h = { "a" => 1, "b" => 2, "c" => 3 }
p h.select.with_index { |(k, v), i| i == 0 }
p h.select.with_index { |kv, i| i.odd? }
p h.filter.with_index(1) { |(k, v), i| i == 3 }
p h.reject.with_index { |(k, v), i| i == 0 }
p h.filter_map.with_index { |(k, v), i| "#{k}#{i}" if i > 0 }
h.each_pair.with_index(10) { |kv, i| p [kv, i] }
p h.transform_values.with_index { |v, i| v * 10 + i }
p h.transform_keys.with_index { |k, i| "#{k}#{i}" }
p [10, 20, 30].filter_map.with_index { |x, i| x if i > 0 }
n = 0
p h.select.with_index { |(k, v), i| n += 1; next false if i == 1; true }, n

# a blockless transform is an Enumerator over the values (keys)
e = h.transform_values
p e.class, e.size, e.to_a, h.transform_keys.to_a
