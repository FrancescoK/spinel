# A Complex operator's TypeError names the operand as CRuby does: nil,
# true and false as themselves, a Symbol by its inspect, else its class
c = Complex(1, 2)
def t(label)
  yield
rescue TypeError => e
  puts "#{label}: #{e.message}"
end
t("+ nil") { c + nil }
t("- true") { c - true }
t("* false") { c * false }
t("/ str") { c / "s" }
t("** nil") { c ** nil }
t("quo sym") { c.quo(:sym) }
t("fdiv arr") { c.fdiv([1]) }
t("+ hash") { c + {a: 1} }
t("- range") { c - (1..2) }
class Foo; end
t("+ Foo") { c + Foo.new }
n = 0
t("side effect") { c + (n += 1; nil) }
p n
