# Integer#pow(e, m) on a Bignum takes the result into the modulus's sign, as
# Ruby's modulo does, whatever the signs of the base and the modulus. A
# negative modulus answered a positive result.
b = 2**70
p (-b).pow(3, 2**65 + 1), (-b).pow(2, 13), (-(2**70) - 1).pow(5, 2**66 + 3)
p (-b).pow(3, -(2**65 + 1)), b.pow(3, -(2**65 + 1))
p (2**100).pow(3, 2**70 + 5), (2**100).pow(3, -(2**70 + 5))
p (-(2**100)).pow(7, 2**130 + 3), (2**200).pow(65537, 2**127 - 1)
p b.pow(5, 1), b.pow(5, -1), b.pow(0, 2**65 + 1), (2**65).pow(3, 2**65)
p b.remainder(-3), (-b).remainder(3), (-b).remainder(-7)
