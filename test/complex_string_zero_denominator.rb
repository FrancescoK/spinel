# A Complex string with a zero denominator raises ZeroDivisionError, as in
# CRuby, with `exception: false` and through String#to_c too.
p (Complex("1/0") rescue [$!.class, $!.message])
p (Complex("1/0", exception: false) rescue [$!.class, $!.message])
# the raise under exception: false leaves later strict parses strict
p (Complex("abc") rescue $!.class)
p (Rational("abc") rescue $!.class)
p ("1/0".to_c rescue [$!.class, $!.message])
p (Complex("2+1/0i") rescue [$!.class, $!.message])
p (Complex("1/0.0") rescue [$!.class, $!.message])
p Complex("3+4i")
