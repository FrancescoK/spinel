# spinel: int64
# Integer#coerce answers [other, self] for an Integer operand and makes both
# Floats for any other, as CRuby converts them through Float(): a String is
# parsed and nil is a TypeError. A Bignum receiver pushed the operand and
# itself unchanged, so (2**70).coerce(2.5) answered
# [2.5, 1180591620717411303424] for [2.5, 1.1805916207174113e+21]. The probes
# cover Float, Rational, String, nil, Complex and boxed operands, beside the
# Integer ones whose answer must not move, and the boxed receiver.

def t(label)
  r = yield
  puts "#{label} => #{r.inspect}"
rescue => e
  puts "#{label} => #{e.class}: #{e.message}"
end

b = 2**70
f = 2.5
t("b.coerce(2.5)") { b.coerce(2.5) }
t("b.coerce(f)") { b.coerce(f) }
t("(-b).coerce(-0.5)") { (-b).coerce(-0.5) }
t("(b - 1).coerce(f)") { (b - 1).coerce(f) }
t("b.coerce(1/2r)") { b.coerce(1/2r) }
t("b.coerce('2.5')") { b.coerce("2.5") }
t("b.coerce(nil)") { b.coerce(nil) }
t("b.coerce(Complex(1, 0))") { b.coerce(Complex(1, 0)) }
a = [b, 1, 2.5, "s", 1/2r]
t("b.coerce(a[2])") { b.coerce(a[2]) }
t("b.coerce(a[4])") { b.coerce(a[4]) }
t("b.coerce(a[1])") { b.coerce(a[1]) }
t("a[0].coerce(2.5)") { a[0].coerce(2.5) }

t("b.coerce(3)") { b.coerce(3) }
t("b.coerce(b)") { b.coerce(b) }
t("7.coerce(b)") { 7.coerce(b) }
