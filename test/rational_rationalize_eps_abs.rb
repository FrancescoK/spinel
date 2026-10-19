# Rational#rationalize(eps) with an epsilon that is no number raises the
# NoMethodError naming abs that CRuby's call of eps.abs raises, not a Float
# conversion's TypeError
def t(label)
  p yield
rescue NoMethodError, TypeError => e
  puts "#{label}: #{e.class}: #{e.message}"
end
r = Rational(1, 3)
t("nil") { r.rationalize(nil) }
t("true") { r.rationalize(true) }
t("string") { r.rationalize("x") }
t("symbol") { r.rationalize(:e) }
a = [nil, 0.01, Rational(1, 100), 1]
t("boxed nil") { r.rationalize(a[0]) }
t("boxed float") { r.rationalize(a[1]) }
t("boxed rational") { r.rationalize(a[2]) }
t("float") { r.rationalize(0.01) }
t("rational") { r.rationalize(Rational(1, 100)) }
t("integer") { r.rationalize(1) }
t("negative") { r.rationalize(-0.01) }
t("none") { r.rationalize }
log = []
t("order") { (log << :r; r).rationalize((log << :e; nil)) }
p log

# a boxed Complex epsilon is its abs; a nilable Rational one that is nil
# has no abs
c = [Complex(0.01, 0.01), 1]
t("boxed complex") { r.rationalize(c[0]) }
def maybe_r(x) = x > 0 ? Rational(1, 100) : nil
t("nilable rational") { r.rationalize(maybe_r(1)) }
t("nilable rational nil") { r.rationalize(maybe_r(-1)) }
