# spinel: not-cruby
# A callable block has no supported result-identity route; refuse at compile time.
s = +"a"
keep = proc { s }
r = s.yield_self(&keep)
r << "!"
p [s, r, r.equal?(s)]
