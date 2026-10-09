# spinel: not-cruby
# A callable block has no supported result-identity route; refuse at compile time.
s = +"a"
keep = ->(value) { value }
r = s.then(&keep)
r << "!"
p [s, r, r.equal?(s)]
