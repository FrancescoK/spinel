# compare_by_identity is accepted only where every key is an object compared
# by pointer or a Symbol, nil, true or false (#9171). A String key may be one
# object here (the frozen literal pool) where CRuby has two, so a hash that
# may see one is refused, naming why.
h = Hash.new.compare_by_identity
h[[1, 2]] = 1
h["a"] = 2
p h.size
