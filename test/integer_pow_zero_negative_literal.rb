# Integer#pow with a literal negative exponent is the Rational
# 1 / base**|exp|, and a zero base raises ZeroDivisionError, as `**` does.
# The pow arm built the Rational with sp_rational_new(1, base**|exp|),
# which answered (1/0) for a zero base; it now computes it as `**` does.
# The probes cover a literal, a local, a computed and an Array-read zero
# base, beside bases whose answer must not move.

def t(label)
  r = yield
  puts "#{label} => #{r.inspect}"
rescue => e
  puts "#{label} => #{e.class}: #{e.message}"
end

z = 0
a = [3, 0]
t("0.pow(-1)") { 0.pow(-1) }
t("z.pow(-1)") { z.pow(-1) }
t("z.pow(-4)") { z.pow(-4) }
t("(z * 5).pow(-2)") { (z * 5).pow(-2) }
t("Integer.sqrt(0).pow(-2)") { Integer.sqrt(0).pow(-2) }
t("a[1].pow(-1)") { a[1].pow(-1) }
t("0 ** -1") { 0 ** -1 }
t("z ** -3") { z ** -3 }

t("2.pow(-2)") { 2.pow(-2) }
t("(-2).pow(-3)") { (-2).pow(-3) }
t("a[0].pow(-2)") { a[0].pow(-2) }
t("z.pow(2)") { z.pow(2) }
t("0.pow(0)") { 0.pow(0) }
