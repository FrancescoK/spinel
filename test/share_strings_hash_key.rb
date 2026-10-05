# A shared String used as a Hash key: CRuby dups and freezes the key as it
# is stored, so changing the String afterwards changes no key. Under
# --share-strings the key of a store or a lookup reads the live buffer and
# the store makes the one copy.
s = +"k"
t = s
h = {}
h[s] = 1
s << "!"
p h, h.keys, h.key?("k"), h.key?("k!"), h.keys[0].frozen?, t, t.frozen?
h2 = { t => 2 }
t << "?"
p h2, h2.keys[0], h2["k!"], h2.keys[0].frozen?
h3 = {}
h3.store(s, 3)
s.upcase!
p h3, h3.keys[0].frozen?, s
