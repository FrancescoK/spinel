# Struct#values_at truncates a Float offset to an Integer; an offset past
# either end raises IndexError naming that Integer.
S = Struct.new(:a, :b, :c)
s = S.new(1, 2, 3)

def t(label)
  r = yield
  puts "#{label}: #{r.inspect}"
rescue => e
  puts "#{label}: #{e.class}: #{e.message}"
end

f = 1.9
n = -0.5
neg = -1.5
t("0.5") { s.values_at(0.5) }
t("1.9") { s.values_at(1.9) }
t("variable") { s.values_at(f) }
t("-0.5") { s.values_at(n) }
t("-1.5") { s.values_at(neg) }
t("2.99") { s.values_at(2.99) }
t("mixed") { s.values_at(0, 1.5, 2.0) }
t("3.0") { s.values_at(3.0) }
t("-4.0") { s.values_at(-4.0) }

# other offsets, as before
t("string") { s.values_at("a") }
t("symbol") { s.values_at(:a) }
t("integer") { s.values_at(1) }
t("range") { s.values_at(0..1) }
t("none") { s.values_at }

# a Struct read out of a container
x = [s, 0][0]
t("boxed 0.5") { x.values_at(0.5) }
t("boxed variable") { x.values_at(f) }
