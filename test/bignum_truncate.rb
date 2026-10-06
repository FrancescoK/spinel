# Integer#truncate on a Bignum, with and without a digit count: it had no
# arm (round, floor and ceil did) and was refused at compile time.
b = 2**70 + 123456
p b.truncate
p b.truncate(-2)
p b.truncate(2)
p b.truncate(-4).class
n = -(2**70) - 123456
p n.truncate
p n.truncate(-2)
p n.truncate(-5)
p n.floor(-5)
p n.ceil(-5)
d = -3
p b.truncate(d)
