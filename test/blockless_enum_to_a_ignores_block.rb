# Enumerator#to_a / #entries ignore a block: a blockless map, select, ...
# chained into to_a { } still answers the receiver's elements.

a = [10, 20]
p a.map.to_a { |x| 0 }
p a.collect.entries { |x| x * 2 }
p a.select.to_a { |x| false }
p a.filter.entries { |x| x > 10 }
p a.reject.to_a { |x| true }
p a.sort_by.to_a { |x| -x }
p a.find_index.to_a { |x| x == 20 }

words = ["b", "a"]
p words.map.to_a { |w| w.upcase }
p words.sort_by.entries { |w| w }

p (1..3).map.to_a { |n| n * n }
p (1..3).select.entries { |n| n.odd? }

r = a.map.to_a { |x| raise "not called" }
p r.size
p r.sum
