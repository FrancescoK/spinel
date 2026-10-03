# Integer#=== on a Rational argument is Integer#==: it raised
# NoMethodError, since Integer <op> Rational typed and emitted == and !=
# but not ===, which Float <op> Rational already did.
r = Rational(1, 1)
p(1 === r)
p(2 === r)
p(1 === Rational(2, 2))
p(3 === Rational(7, 2))
v = (1 === r) ? "yes" : "no"
p v
