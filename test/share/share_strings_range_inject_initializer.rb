# spinel: gc-minor
# An empty fold retains its initializer handle.
s = +"a"
r = (1..2).inject(s) { |memo, i| memo }
r << "!"
p [s, r]

r = (1..3).inject(+"") { |memo, i| memo << i.to_s << "," }
p r
s = +"z"
r = (1...1).inject(s) { |memo, i| memo }
r << "?"
p [s, r]

# The memo is one value even when the Range has many elements.
r = (1..1_000_000).inject(+"") { |memo, i| memo << "x" if i % 1000 == 0; memo }
p r.length
p((2...5).reduce(+"") { |memo, i| memo << i.to_s })
p((5..2).inject(+"empty") { |memo, i| memo << i.to_s })

# Each turn may replace the memo with a new handle.
p((1..3).inject(+"") { |memo, i| memo + i.to_s })

p((1..4).inject(+"") { |memo, i| next memo if i == 2; memo << i.to_s })
