# Hash#to_hash answers the receiver itself, as CRuby's does: a copy made a
# write through the result miss the Hash.
h = {a: 1}
r = h.to_hash
p r.equal?(h)
r[:b] = 2
p h
h2 = {"a" => 1}
p h2.to_hash.equal?(h2)
h3 = {1 => 2}
p h3.to_hash.equal?(h3)
h4 = {1 => "x", :b => 2}
p h4.to_hash.equal?(h4)
p({}.to_hash)
