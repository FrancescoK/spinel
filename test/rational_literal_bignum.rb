# spinel: int64
# spinel: gc-stress
# A Rational literal whose numerator or denominator is past 64 bits keeps
# its exact value: it is the big Rational CRuby builds, not a pair of
# saturated integers.

a = 123456789012345678901234567890r
p a
p 0.1234567890123456789012345r
p 1.0000000000000000000001r
p(-98765432109876543210r)
p 9223372036854775808r
p 3r
p 0.25r

# arithmetic and comparison against a small Rational, an Integer and a big one
b = Rational(1, 3)
p a + b
p a - 1
p a * 2
p a / 3
p a > b
p b < a
p a == 123456789012345678901234567890r
p a == 123456789012345678901234567891r
p a <=> 123456789012345678901234567891r
p 0.1234567890123456789012345r * 10
p a.to_s
p (a * 0.0000000000000000000000000001r)

# as a constant, an element and a method's argument and value
BIG = 99999999999999999999999r
p BIG
xs = [1r, 22222222222222222222222r]
p xs
def twice(r) = r * 2
p twice(55555555555555555555555r)
def tiny = 1/100000000000000000000000r
p tiny

# a case over an Integer that a big literal cannot match
case 5
when 123456789012345678901234567890r then p :big
when 5r then p :five
end
case 123456789012345678901234567890
when 123456789012345678901234567890r then p :big
else p :other
end
case 0.1234567890123456789012345r
when 0.1234567890123456789012345r then p :same
else p :other
end
