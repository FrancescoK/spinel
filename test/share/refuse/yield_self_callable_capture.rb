# spinel: not-cruby
# The proc handed to yield_self answers s itself, which r then changes in
# place: the String is shared with another name, refused at compile time.
s = +"a"
keep = proc { s }
r = s.yield_self(&keep)
r << "!"
p [s, r, r.equal?(s)]
