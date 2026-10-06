# A Time read out of a mixed Array answers round / ceil / floor (with or
# without a precision) and ctime, as a plain Time does.
t = Time.at(1700000000, 123456789, :nsec).utc
xs = [t, 1]
b = xs[0]
p b.round.nsec
p b.ceil.nsec
p b.floor.nsec
p b.round(3).nsec
p b.ceil(2).nsec
p b.floor(1).nsec
p b.round(0).to_i
p b.ceil.to_i
p b.floor.to_i
p b.round.class
p b.ctime
p b.asctime
p b.ctime == t.ctime
