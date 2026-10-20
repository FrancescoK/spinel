# `keys` on a boxed String-keyed Hash (Integer, String or mixed values) answers
# a fresh Array of the keys in insertion order; changing it leaves the Hash
# alone, and a deleted key is gone from the next one.
hs = [{ "a" => 1, "b" => 2 }, { "x" => "y" }, { "m" => 1, "n" => "two", "o" => nil }, {}, { 1 => 2 }]
hs.each { |h| p h.keys }
h = hs[2]
ks = h.keys
ks << "zz"
ks[0] = "changed"
p [ks, h.keys]
h.delete("n")
p h.keys
p h.keys.frozen?
