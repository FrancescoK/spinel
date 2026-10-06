# spinel: int64
# Float#divmod, and an Integer's divmod or modulo by a Float, answer as
# CRuby's flodivmod: a NaN divisor is tested before a zero one (so
# NaN.divmod(0.0) is a ZeroDivisionError), a zero modulus keeps the
# dividend's sign (-0.0), the quotient agrees with the modulus
# (1.0.divmod(0.1) is [9, 0.09999999999999995], not [10, 0.0]), and a
# boxed receiver's quotient no 64-bit Integer holds is a Bignum (a typed
# one's is pinned by promote_float_divmod_bignum). The typed arms computed
# floor(x / y) and x - q * y, which lost each of these; the probes run them
# on Float, Integer, Bignum and Rational operands and on boxed values.

def t(label)
  r = yield
  puts "#{label} => #{r.inspect}"
rescue => e
  puts "#{label} => #{e.class}"
end

nan = Float::NAN
inf = Float::INFINITY
t("(-0.0).divmod(1.0)") { (-0.0).divmod(1.0) }
t("0.0.divmod(-1.0)") { 0.0.divmod(-1.0) }
t("(-0.0).divmod(-1.0)") { (-0.0).divmod(-1.0) }
t("(-4.0).divmod(2.0)") { (-4.0).divmod(2.0) }
t("(-4.0).divmod(2)") { (-4.0).divmod(2) }
t("(-1.5).divmod(1/2r)") { (-1.5).divmod(1/2r) }
t("1.0.divmod(0.1)") { 1.0.divmod(0.1) }
t("1.0.divmod(1/10r)") { 1.0.divmod(1/10r) }
t("nan.divmod(0.0)") { nan.divmod(0.0) }
t("nan.divmod(0)") { nan.divmod(0) }
t("1.0.divmod(nan)") { 1.0.divmod(nan) }
t("inf.divmod(1.0)") { inf.divmod(1.0) }
t("(-1.0).divmod(inf)") { (-1.0).divmod(inf) }

t("-4.divmod(2.0)") { -4.divmod(2.0) }
t("0.divmod(nan)") { 0.divmod(nan) }
t("0.divmod(0.0)") { 0.divmod(0.0) }
t("-4.modulo(2.0)") { -4.modulo(2.0) }
t("4.modulo(0.0)") { 4.modulo(0.0) }
t("1.modulo(0.1)") { 1.modulo(0.1) }
t("-1.modulo(inf)") { -1.modulo(inf) }
t("(-1.5).modulo(1/2r)") { (-1.5).modulo(1/2r) }
t("(-(2**64)).divmod(3.0)") { (-(2**64)).divmod(3.0) }
t("(2**64).divmod(nan)") { (2**64).divmod(nan) }

x = -4
y = 2.0
t("x.divmod(y)") { x.divmod(y) }
t("x.modulo(y)") { x.modulo(y) }

a = [-0.0, 1, "s", nan, 1e20]
t("a[0].divmod(1.0)") { a[0].divmod(1.0) }
t("a[3].divmod(0.0)") { a[3].divmod(0.0) }
t("a[1].divmod(a[3])") { a[1].divmod(a[3]) }
t("a[4].divmod(1.0)") { a[4].divmod(1.0) }
t("(a[1] * -4.0).divmod(2.0)") { (a[1] * -4.0).divmod(2.0) }
t("a[1].divmod(0.1)") { a[1].divmod(0.1) }
