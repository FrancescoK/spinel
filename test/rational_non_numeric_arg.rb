# Kernel#Rational of one value with no conversion to Rational (no number,
# String or Time) raises TypeError "can't convert X into Rational", naming
# true and false and the class of the others, typed or boxed, after the
# argument runs
def t(label)
  p yield
rescue TypeError => e
  puts "#{label}: #{e.message}"
end
t("true") { Rational(true) }
t("false") { Rational(false) }
t("symbol") { Rational(:a) }
t("array") { Rational([1]) }
t("hash") { Rational({a: 1}) }
t("range") { Rational(1..2) }
t("object") { Rational(Object.new) }
t("class") { Rational(Integer) }
t("proc") { Rational(-> { 1 }) }
t("regexp") { Rational(/a/) }

def flag(x) = x > 0
t("bool param") { Rational(flag(1)) }

a = [true, false, :b, [2], 1, 2.5, Rational(1, 3), "3/4"]
t("boxed true") { Rational(a[0]) }
t("boxed false") { Rational(a[1]) }
t("boxed symbol") { Rational(a[2]) }
t("boxed array") { Rational(a[3]) }
t("boxed int") { Rational(a[4]) }
t("boxed float") { Rational(a[5]) }
t("boxed rational") { Rational(a[6]) }
t("boxed string") { Rational(a[7]) }

# an instance of a class with no to_r or to_int (none in this program)
class Plain; end
t("plain") { Rational(Plain.new) }
pa = [Plain.new, 1]
t("boxed plain") { Rational(pa[0]) }

# a Time converts, through Time#to_r
tm = [Time.at(2), 1]
p Rational(tm[0])

log = []
t("order") { Rational((log << :arg; GC.start; :c)) }
p log
p Rational(3)
p Rational(0.5)
p Rational("2/3")
