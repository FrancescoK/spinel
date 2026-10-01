# Integer#digits converts a Float or Rational radix through #to_int, as
# CRuby's rb_to_int does (3.9 and 7/2 are 3); nil and a String stay its
# TypeError, and the converted radix is checked as an Integer one is.
p 5.digits(Rational(7, 2))
p 5.digits(3.9)
p((5.digits(Rational(1, 2)) rescue $!.message))
p((5.digits(-2.5) rescue $!.message))
p 100.digits(10)
p((5.digits(-2) rescue $!.message))
p((5.digits(nil) rescue $!.message))
p((5.digits("3") rescue $!.message))
p (2**70).digits(Rational(17, 2)).size
p 1234.digits, 1234.digits(100)
i = 0
bb = [Rational(7, 2), 1][i]
p 5.digits(bb)
