# The proc handed to yield_self answers s itself, which r then changes in
# place: under --share-strings r and s are one String.
s = +"a"
keep = proc { s }
r = s.yield_self(&keep)
r << "!"
p [s, r, r.equal?(s)]
