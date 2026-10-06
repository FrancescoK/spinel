# Rational(n, d) of a boxed nil raises TypeError, "can't convert nil into
# Rational", and a Rational operator with a boxed nil operand the
# coercion TypeError. The nil read as the integer 0: Rational(x, 1) was
# (0/1) and Rational(1, x) a ZeroDivisionError.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue TypeError, ZeroDivisionError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

src = [1, nil, "s", 0.5]
x = src[1]
t("Rational(x, 1)") { Rational(x, 1) }
t("Rational(1, x)") { Rational(1, x) }
t("Rational(x)") { Rational(x) }
t("r + x") { Rational(1, 2) + x }
t("r * x") { Rational(1, 2) * x }
t("r == x") { Rational(1, 2) == x }
t("Rational(n, 2)") { Rational(src[0], 2) }
t("Rational(f)") { Rational(src[3]) }
