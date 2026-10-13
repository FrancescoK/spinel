# A callable handed to then as its block (`s.then(&keep)`) is called as a
# literal block would be, and its result is the receiver itself.
s = +"a"
keep = ->(value) { value }
r = s.then(&keep)
r << "!"
p [s, r, r.equal?(s)]
