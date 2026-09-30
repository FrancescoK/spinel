# A `next <value>` in a Hash#fetch block or a Hash.new default block
# answers the missing key; there is no loop for it to continue.

p({a: 1}.fetch(:b) { |k| next 5 if k; 6 })
d = Hash.new { |hh, k| next 7 if k == :x; 0 }
p d[:x]
p d[:y]
