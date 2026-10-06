# A Hash walk's each.with_index with a block answers the Hash, as each does,
# whether a variable names the Hash or a call makes it (evaluated once).
h = {"a" => 1, "b" => 2}
r = h.each.with_index { |(k, v), i| print k, v, i }
puts
p r
p h.each.with_index(1) { |kv, i| }
p h.each_pair.with_index { |(k, v), i| }
p h.each.each_with_index { |(k, v), i| }
p h.each_with_index { |(k, v), i| }
a = [1, 2]
p a.each.with_index { |x, i| }
q = {"x" => 9}
n = 0
p h.merge(q).each.with_index { |(k, v), i| n += i }, n
def hh = (puts "once"; {"z" => 1})
p hh.each.with_index(5) { |kv, i| p [kv, i] }
