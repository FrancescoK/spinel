# A bare `break` leaves a lambda with nil, beside a tail of another type (#8277).
f = ->(x) { break if x; :tail }
p f.call(true)
p f.call(false)
g = ->(n) { break if n > 2; n * 10 }
p g.call(1)
p g.call(3)
