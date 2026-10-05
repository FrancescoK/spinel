# A key that is a String the rule shares is read by its contents, stored
# as a frozen copy, and later changes to it do not move the entry.
k = +"key"; alias_k = k; alias_k << "1"
h = {}
h[k] = 1
p h[k], h["key1"], h.key?(k)
k << "2"
p h, h[k], h["key1"], alias_k
counts = Hash.new(0)
w = +"w"; w2 = w
["a", "b", "a"].each { |x| w << x; counts[w2] += 1 }
p counts
