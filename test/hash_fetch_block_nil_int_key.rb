# Hash#fetch with a block hands a missing key to the block. An Integer key
# that can be nil reaches the block as nil: the typed block parameter
# unwrapped it with a TypeError ("no implicit conversion from nil to
# integer"), and under --int-overflow=promote with another TypeError.
def ni(x) = x > 0 ? x : nil

h = { 1 => "a", 2 => "b" }
k = ni(-1)
p h.fetch(k) { |key| "none #{key.inspect}" }
p h.fetch(k) { |key| key.nil? }
p h.fetch(ni(2)) { |key| "none #{key.inspect}" }
p h.fetch(ni(7)) { |key| key.nil? ? :nil : key * 10 }
p h.fetch(ni(-7)) { |key| key.nil? ? :nil : key * 10 }
p h.fetch(k, "dflt")
