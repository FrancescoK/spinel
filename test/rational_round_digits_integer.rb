# Rational#round / #floor / #ceil / #truncate take an Integer digit count
# only: anything else raises TypeError "not an integer", after the receiver,
# the count and any keyword value run
def t(label)
  p yield
rescue TypeError => e
  puts "#{label}: #{e.message}"
end
r = Rational(7, 3)
t("round nil") { r.round(nil) }
t("floor true") { r.floor(true) }
t("ceil string") { r.ceil("1") }
t("truncate symbol") { r.truncate(:a) }
t("round float") { r.round(1.5) }
t("round rational") { r.round(Rational(3, 2)) }
class D
  def to_int = 1
end
t("round to_int") { r.round(D.new) }

a = [nil, 1, "x", 1.5]
t("boxed nil") { r.round(a[0]) }
t("boxed int") { r.ceil(a[1]) }
t("boxed string") { r.truncate(a[2]) }
t("boxed float") { r.floor(a[3]) }
def m(v) = v > 0 ? 1 : nil
t("nullable nil") { r.round(m(-1)) }
t("nullable int") { r.round(m(1)) }

t("half nil") { r.round((puts "count"; nil), half: (puts "mode"; :up)) }
t("half boxed") { r.round(a[0], half: :even) }
t("half int") { r.round(a[1], half: :even) }
n = 2
t("int") { r.round(n) }
t("literal") { r.floor(1) }
