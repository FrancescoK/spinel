# Hash#update on a hash whose keys are of several kinds reads the other
# hash's keys. Its order[] holds slot indices, not keys, and the merge
# loop read an index as the key, so the C did not compile.
h = { "x" => 1, y: "s" }
h.update({ "x" => 2, 3 => :z })
p h
g = { "x" => 1, y: "s" }
g.update({ "x" => 10, 4 => :w }) { |k, o, n| [k, o, n] }
p g
f = { "x" => 1, y: "s" }
f.merge!({ y: "t" })
p f
