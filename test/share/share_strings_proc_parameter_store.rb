# spinel: gc-minor
# A proc's boxed parameter stores the caller's String handle.
kept = []
store = proc { |i, v| kept[i] = v }
store.call(0, +"a")
store.call(1, 2)
kept[0] << "b"
p kept
s = +"shared"
store.call(2, s)
kept[2] << "!"
p [s, kept[2], s.equal?(kept[2])]
frozen = "fixed"
store.call(3, frozen)
begin
  kept[3] << "!"
rescue FrozenError
  puts "frozen"
end
p frozen.equal?(kept[3])
store.call(4, "allocated#{ARGV.size}")
kept[4] << "?"
p kept[4]
other = []
f = ->(v) { other << v }
f.call(+"lambda")
f.call(7)
other[0] << ":"
p other

optional = []
opt = proc { |v = (+"default")| optional << v }
opt.call
opt.call(+"provided")
opt.call(9)
optional[0] << "!"
optional[1] << "?"
p optional
post = []
last = proc { |*before, v| post << v }
last.call(1, +"post")
last.call(2, 8)
post[0] << "!"
p post
keywords = []
kw = proc { |v: (+"keyword")| keywords << v }
kw.call
kw.call(v: +"provided")
key_shared = +"key shared"
kw.call(v: key_shared)
kw.call(v: 6)
keywords[2] << "."
p [key_shared, keywords[2], key_shared.equal?(keywords[2])]
keywords[0] << "!"
keywords[1] << "?"
p keywords
captured = []
cap = proc do |v|
  captured << v
  -> { v }
end
read = cap.call(+"captured")
cap.call(4)
captured[0] << "!"
p [read.call, read.call.equal?(captured[0])]
store.call(5, "literal")
begin
  kept[5] << "!"
rescue FrozenError
  puts "literal frozen"
end
p kept[5].frozen?

# Frozen literals keep their original interned identity through the box.
store.call(6, "same")
store.call(7, "same")
p kept[6].equal?(kept[7])
