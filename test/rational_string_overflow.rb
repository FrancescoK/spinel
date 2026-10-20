# spinel: not-cruby -- a literal past sp_int raises RangeError where CRuby answers a Bignum Rational
# Kernel#Rational(String) whose digits, scale or exponent do not fit an
# Integer is valued as String#to_r values it: exactly where the reduced
# value fits (100000000000000000000e-18 is 100), a RangeError where it
# does not, rather than the wrapped value it answered. Syntax errors and a
# zero denominator raise as before.
def t(label)
  p [label, yield]
rescue RangeError, ArgumentError, ZeroDivisionError => e
  puts "#{label}: #{e.class}"
end
t(:den) { Rational("1/12345678901234567890123") }
t(:num) { Rational("12345678901234567890123/7") }
t(:frac) { Rational("0.1234567890123456789012") }
t(:exp) { Rational("1e30") }
t(:negexp) { Rational("-1e-30") }
t(:huge_exp) { Rational("1e99999999999999999999") }
t(:fits) { Rational("100000000000000000000e-18") }
t(:fits_under) { Rational("-1_000_000_000_000_000_000_000e-21") }
t(:fits_frac) { Rational("2.50000000000000000000000/5") }
t(:small) { Rational("3/4") }
t(:dec) { Rational("-0.75") }
t(:zero) { Rational("1/0_0") }
t(:trail) { Rational("12345678901234567890123x") }
t(:empty) { Rational("") }
