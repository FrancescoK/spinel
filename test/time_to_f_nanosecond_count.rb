# Time#to_f and Time - Time answer the whole nanosecond count as a Float
# divided by 1e9, as CRuby does, so a value can sit just below its decimal
# form and epoch milliseconds (t.to_f * 1000).to_i match CRuby's.
t = Time.at(1790544731, 561000, :usec)
p t.to_f
p((t.to_f * 1000).to_i)
u = Time.at(1790544731, 999999999, :nsec)
p u.to_f
p(t - Time.at(0))
p(u - t)
b = [t, 1][0]
p b.to_f
p Time.at(-1, 250000, :usec).to_f
