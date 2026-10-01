# `next v` in an Array.new block is that element's value -- the element is
# still stored -- as it is in map. The pure-Ruby Date builds its "-MM-DD"
# suffix table with a `next nil if m == 0 || d == 0`.
p Array.new(4) { |i| next nil if i == 0; i * 10 }
p Array.new(4) { |i| next if i == 1; i }
p Array.new(3) { |i| next "s#{i}" if i.odd?; "x#{i}" }
p Array.new(3) { |i| x = i * 2; next x + 1 if x > 1; x }
t = Array.new(3) { |m| Array.new(3) { |d| next nil if m == 0 || d == 0; "#{m}-#{d}" } }
p t, t[2][2], t[1].size
