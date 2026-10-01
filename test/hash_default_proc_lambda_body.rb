# A lambda assigned as a Hash's default_proc runs as the lambda it is: its
# parameters take what the hash passes, its `return` leaves the lambda, and
# a statement prelude in its value stays inside it.
s = Hash.new
s.default_proc = ->(hh, k) { hh[k] = k.upcase }
p s["ab"]
p s

w = Hash.new
w.default_proc = ->(hh, k) { [1, 2].map { |i| i * 10 }.sum }
p w[:z]

r = Hash.new
r.default_proc = ->(hh, k) { return 9 if k == :r; 1 }
p r[:r]
p r[:q]

base = 100
c = Hash.new
c.default_proc = ->(hh, k) { hh[k] = base + k.size }
p c["abc"], c
