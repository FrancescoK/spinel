# Hash[[pairs]] and [pairs].to_h on an Array literal type the hash from
# every pair. The first pair alone fixed the value slot, and a later value
# of another class was stored raw: a String slot read an Integer (a
# segfault) and an Integer slot read a String's pointer (#8187).
h = Hash[[["a", "b"], ["c", 1]]]
puts h["c"]
p h
h2 = Hash[[["c", 1], ["a", "b"]]]
puts h2["a"]
p [["a", "b"], ["c", 1]].to_h
p [[1, "one"], [:two, 2]].to_h
p [[1, 2], [3, 4]].to_h
p [[:a, 1.5], [:b, nil]].to_h
