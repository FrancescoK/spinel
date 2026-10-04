# Rational %/modulo/remainder/divmod, Complex <=> (real-valued compare,
# nil otherwise), slice! on literal receivers, and Hash#default after
# a default= on an un-narrowed empty hash.
p((+"hello").slice!(/l+/))
p((+"hello").slice!("ell"))
s = +"hello"
p(s.slice!(/l+/))
p s
a = {}; a.default = 9; c = (a.default); p c
p a[:missing]
b = {}
b.default = "d"
p b["nope"]
p(({}.default = 5))
v = Rational(7,2) % Rational(1,3); p v
p(Rational(7,2) % 2)
p(Rational(7,2).modulo(Rational(1,3)))
p(Rational(-7,2) % Rational(1,3))
p(Rational(7,2).remainder(Rational(1,3)))
p(Rational(-7,2).remainder(Rational(1,3)))
p(Rational(7,2).divmod(Rational(1,3)))
p(Complex(2, 0) <=> Complex(2, 0))
p(Complex(3, 0) <=> Complex(2, 0))
p(Complex(1, 0) <=> Complex(2, 0))
p(Complex(2, 0) <=> 3)
p(Complex(2, 3) <=> Complex(1, 1))
